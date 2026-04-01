import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import '../core/app_state.dart';
import '../config/environment.dart';

class MqttService {
  /// Broker settings from Environment config (Frontend/Backend separation)
  /// Backend tarafında değişirse, lib/config/environment.dart'ta güncelle.
  static const String _broker = Environment.mqttBroker;
  static const String _topicSensor = Environment.mqttTopicSensor;
  static const String _topicCommand = Environment.mqttTopicCommand;
  static const Duration _connectTimeout = Environment.mqttConnectTimeout;
  static const bool _useWebSocket = Environment.mqttUseWebSocket;
  static const bool _secure = Environment.mqttSecure;
  static const String _websocketPath = Environment.mqttWebSocketPath;

  /// Web'de bazı ağlar 8884'ü keser; 443 çoğu zaman açıktır. Aynı host, aynı topic.
  static const List<int> _webWssPorts = Environment.mqttWebWssPorts;

  MqttClient? _client;
  final AppState state;

  /// Son başarılı bağlantı (log için).
  String _lastEndpointLabel = _broker;

  MqttService(this.state);

  String _newClientId() =>
      'AgroTwin_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1 << 20)}';

  /// Web: URI'de port yazıp `MqttBrowserClient(uri, id)` kullanma — paket içinde
  /// `uri.replace(port: this.port)` ile port **1883**'e ezilir; CONNACK gelmez.
  /// Doğrusu: host+path string + [withPort].
  MqttBrowserClient _makeBrowserClient(String serverNoPort, int port, String cid) {
    return MqttBrowserClient.withPort(serverNoPort, cid, port)
      ..logging(on: false)
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 15000
      ..autoReconnect = true
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected;
  }

  MqttServerClient _makeServerClient(String cid) {
    final serverClient = MqttServerClient(_broker, cid)
      ..port = _webWssPorts.first
      ..secure = _secure
      ..useWebSocket = _useWebSocket
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..logging(on: false);

    if (_secure) {
      serverClient.onBadCertificate = (_) => true;
    }
    return serverClient;
  }

  Future<void> connect() async {
    if (state.mqttConnecting || state.mqttConnected) {
      debugPrint(
        '[MQTT] connect atlandi: connecting=${state.mqttConnecting}, connected=${state.mqttConnected}',
      );
      return;
    }

    final cid = _newClientId();
    state.setMqttStatus(false, connecting: true);

    try {
      _client?.disconnect();
    } catch (_) {}

    if (kIsWeb) {
      final serverBase =
          '${_secure ? 'wss' : 'ws'}://$_broker$_websocketPath';
      Object? lastError;
      for (final port in _webWssPorts) {
        _lastEndpointLabel = '$_broker:$port$_websocketPath';
        final effectiveUri = Uri(
          scheme: _secure ? 'wss' : 'ws',
          host: _broker,
          port: port,
          path: _websocketPath,
        ).toString();
        debugPrint(
          '[MQTT] Web denemesi (gerçek hedef): $effectiveUri  clientId=$cid',
        );

        _client = _makeBrowserClient(serverBase, port, cid);

        _client!.connectionMessage = MqttConnectMessage()
            .withClientIdentifier(cid)
            .startClean();

        try {
          await _client!.connect().timeout(_connectTimeout);
        } on TimeoutException {
          debugPrint('[MQTT] Zaman aşımı: $_lastEndpointLabel');
          lastError = TimeoutException('timeout');
          _safeDisconnect();
          continue;
        } catch (e) {
          debugPrint('[MQTT] Bağlantı hatası ($_lastEndpointLabel): $e');
          lastError = e;
          _safeDisconnect();
          continue;
        }

        if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
          break;
        }
        debugPrint(
          '[MQTT] Reddedildi: $_lastEndpointLabel '
          'state=${_client!.connectionStatus?.state} '
          'code=${_client!.connectionStatus?.returnCode}',
        );
        lastError = _client!.connectionStatus;
        _safeDisconnect();
      }

      if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
        debugPrint(
          '[MQTT] Tüm web uçları başarısız. Son hata: $lastError\n'
          '[MQTT] İpucu: Kurum ağı / güvenlik duvarı WebSocket portlarını '
          'kesebilir. Telefon hotspot veya farklı Wi‑Fi deneyin.',
        );
        state.setMqttStatus(false);
        return;
      }
    } else {
      debugPrint(
        '[MQTT] Baglanma denemesi: $_broker:${_webWssPorts.first} '
        'path=$_websocketPath ws=$_useWebSocket tls=$_secure clientId=$cid',
      );
      _lastEndpointLabel = '$_broker:${_webWssPorts.first}';
      _client = _makeServerClient(cid);

      _client!.connectionMessage = MqttConnectMessage()
          .withClientIdentifier(cid)
          .startClean();

      try {
        await _client!.connect().timeout(_connectTimeout);
      } on TimeoutException {
        debugPrint('[MQTT] Zaman aşımı: $_broker:${_webWssPorts.first} yanıt vermedi.');
        _safeDisconnect();
        state.setMqttStatus(false);
        return;
      } catch (e) {
        debugPrint('[MQTT] Bağlantı hatası: $e');
        _safeDisconnect();
        state.setMqttStatus(false);
        return;
      }

      if (_client!.connectionStatus?.state != MqttConnectionState.connected) {
        debugPrint(
          '[MQTT] Bağlantı kurulamadı: '
          '${_client!.connectionStatus?.state} '
          'code=${_client!.connectionStatus?.returnCode}',
        );
        _safeDisconnect();
        state.setMqttStatus(false);
        return;
      }
    }

    debugPrint('[MQTT] Topic subscribe: $_topicSensor (bağlı: $_lastEndpointLabel)');
    _client!.subscribe(_topicSensor, MqttQos.atMostOnce);
    _client!.updates!.listen(_onMessage);
    state.setMqttStatus(true);
  }

  void _onConnected() {
    debugPrint('[MQTT] Bağlı: $_lastEndpointLabel');
    state.setMqttStatus(true);
  }

  void _onDisconnected() {
    debugPrint('[MQTT] Bağlantı kesildi');
    state.setMqttStatus(false);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final msg in messages) {
      final raw = msg.payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(raw.payload.message);
      debugPrint('[MQTT] <- ${msg.topic}: $payload');
      try {
        final json = jsonDecode(payload) as Map<String, dynamic>;
        state.updateSensor(SensorData.fromJson(json));
      } catch (e) {
        debugPrint('[MQTT] JSON parse hatası: $e');
      }
    }
  }

  /// [cihaz]: pompa | fan | isitici   [durum]: ON | OFF
  void publish(String cihaz, String durum) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      debugPrint('[MQTT] Bağlı değil, komut gönderilemedi.');
      return;
    }
    final payload = jsonEncode({'cihaz': cihaz, 'durum': durum});
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client!.publishMessage(_topicCommand, MqttQos.atLeastOnce, builder.payload!);
    debugPrint('[MQTT] → $_topicCommand : $payload');
  }

  void _safeDisconnect() {
    try {
      _client?.disconnect();
    } catch (_) {}
  }

  void disconnect() => _safeDisconnect();
}
