# AgroTwin Mobile Application

Merkezileştirilmiş tarım yönetim sistemi (Agro Twin) için Flutter tabanlı mobil uygulaması. Dashboard, analitik, MQTT kontrol ve AI asistan özelliklerini içerir.

## 🚀 Hızlı Başlangıç

### Sistem Gereksinimleri
- Flutter SDK: >= 3.11.4
- Dart: >= 3.11.4
- Chrome / Android emulator / iOS simulator

### Kurulum

```bash
# Projeyi klonla
git clone <repo-url>
cd Mobile

# Bağımlılıkları kur
flutter pub get

# Analiz et
flutter analyze

# Web üzerinde çalıştır
flutter run -d chrome

# Android / iOS
flutter run -d <device-id>
```

## 📁 Proje Yapısı

```
lib/
├── main.dart                 # Entry point
├── config/
│   └── environment.dart      # Configuration (MQTT broker, API endpoints)
├── core/
│   ├── app_state.dart        # Global state (AppState)
│   ├── constants.dart        # UI constants
│   └── chart_helpers.dart    # Chart utilities
├── services/
│   └── mqtt_service.dart     # MQTT broker connection (HiveMQ)
└── screens/
    ├── dashboard_screen.dart
    ├── analitik_screen.dart
    ├── control_screen.dart
    ├── ai_assistant_screen.dart
    ├── simulator_screen.dart
    └── user_settings_screen.dart
```

## 🔧 Konfigürasyon (Frontend/Backend Separation)

### MQTT Broker Konfigürasyonu

`lib/config/environment.dart` dosyasında tüm ağ ayarları merkezi olarak tanımlanır:

```dart
class Environment {
  static const String mqttBroker = 'broker.hivemq.com';
  static const String mqttTopicSensor = 'agrotwin/sensorler';
  static const String mqttTopicCommand = 'agrotwin/komutlar';
  // ... diğer ayarlar
}
```

**Backend değişikliği yapıldığında:**
1. `lib/config/environment.dart` güncelle
2. `git push` et
3. Frontend developer (veya kendisi) `flutter pub get` → `flutter run` çalıştır

### Backend API Endpoints (Hazırlanıyor)

Backend developer tarafından `.env.example` dosyasından yola çıkarak eklenecek:

```dart
// TODO: Backend developer bunu lib/config/environment.dart'ta uncomment edecek
static const String backendApiUrl = 'https://api.agrotwin.com';
static const String backendApiVersion = 'v1';
```

## 🌍 Deployment

### Web
```bash
flutter build web
# build/web/ klasörü Netlify/Firebase Hosting/etc. üzerine deploy et
```

### Android
```bash
flutter build apk    # APK
flutter build appbundle   # Play Store bundle
```

### iOS
```bash
flutter build ios
# iOS Simulator veya TestFlight üzerinde test et
```

## 🤝 Collaboration - Merge Conflict Önleme

### Kritik Kurallar

1. **Asla MQTT/API endpoints'i hardcode etme**
   - **Kötü ❌:** `const broker = 'mqtt.example.com'` (doğrudan kod içinde)
   - **İyi ✅:** `Environment.mqttBroker` (config'den oku)

2. **`lib/config/environment.dart` merkezi yapılandırma**
   - Backend tarafında değişirse: backend developer bunu günceller → Pull Request
   - Frontend tarafında değişirse: frontend developer bunu günceller → Pull Request
   - **Merge conflict riski minimum** (sadece bir dosya)

3. **Local configs asla commit etme**
   - `.env`, `.env.local`, `local.properties` → `.gitignore` içinde
   - Credential'lar, API key'ler → `.gitignore` içinde

4. **Backend ve Frontend ayrı branch'lerde çalış**
   ```bash
   # Backend
   git checkout -b backend/mqtt-upgrade
   
   # Frontend
   git checkout -b frontend/ui-improvements
   ```

### Typical Workflow

```bash
# 1. Ana branch'ten pull et
git pull origin main

# 2. Kendi feature branch'ini oluştur
git checkout -b feature/sensor-dashboard

# 3. Kod yaz, test et
flutter analyze
flutter run -d chrome

# 4. Commit et (sadece ilgili dosyaları)
git add lib/screens/dashboard_screen.dart
git commit -m "feat: Add real-time sensor visualization"

# 5. Pull Request oluştur
# (Backend dev conflict görmezse, merge safe'dir)

git push -u origin feature/sensor-dashboard
```

## 🔍 Testing

### Analyzer
```bash
flutter analyze
```

### Format
```bash
dart format lib/
```

### Integration Test (Coming Soon)

## 📚 API Documentation

[Backend API docs akan backend repo'da yer alacak]

## 🛠️ Troubleshooting

### MQTT Connection Timeout
- Broker adres/port kontrol et → `environment.dart`
- Internet bağlantısı kontrol et
- Firewall/proxy kurallarını kontrol et

### Build Errors
```bash
flutter clean
flutter pub get
flutter analyze
```

### Hot Reload Başarısız
```bash
# Hot restart yap (daha yavaş ama güvenilir)
# CLI'da: R tuşu
```

## 📝 License

[License TBD]

## 👥 Maintainers

- Frontend: [Arda]
- Backend: [Backend Developer]

---

**Son Güncelleme:** April 2026
