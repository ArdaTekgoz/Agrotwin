# Backend Developer Instructions - Setup & Collaboration

Bu dosyayı **kendi bilgisayarında** Copilot'a göster. Backend dev bunu yapmalı.

---

## 🎯 Senin (Backend Dev) Yapacakların

### 1️⃣ Projeyi Klonla

```bash
git clone https://github.com/ArdaTekgoz/agrotwin-mobile.git
cd agrotwin-mobile/Mobile
```

### 2️⃣ Environment Setup

**Kendi `.env` dosyasını oluştur** (`.gitignore` içinde gizli kalır):

```bash
# .env dosyası oluştur (proje root'unda)
touch .env
```

Açıp yaz (.env content):
```
# Backend API Configuration
BACKEND_API_URL=http://localhost:8000
BACKEND_API_VERSION=v1

# MQTT Broker
MQTT_BROKER=broker.hivemq.com
MQTT_TOPIC_SENSOR=agrotwin/sensorler
MQTT_TOPIC_COMMAND=agrotwin/komutlar
```

### 3️⃣ `lib/config/environment.dart` İnceleme

Bu dosyayı aç ve oku:
```dart
class Environment {
  // Frontend (Arda) bunları yaptı
  static const String mqttBroker = 'broker.hivemq.com';
  // ...

  // TODO: Backend developer buraya API endpoints ekleyecek
  // static const String backendApiUrl = 'http://localhost:8000';
}
```

**Senin Görevin:**
```dart
// Environment.dart'ta şunu uncomment et + backend URL'nizi ekle
class Environment {
  // ... existing MQTT config ...

  // Backend API Configuration
  static const String backendApiUrl = 'http://localhost:8000'; // Kendi server'ın
  static const String backendApiVersion = 'v1';
  
  // Eğer database URL vs varsa
  // static const String databaseUrl = 'mysql://...';
}
```

### 4️⃣ Dependencies Kur

```bash
cd agrotwin-mobile/Mobile
flutter pub get
flutter analyze          # Kontrol et
```

### 5️⃣ MQTT Bağlantısı Test Et (Opsiyonel)

```bash
flutter run -d chrome
# Dashboard'da "Sistem Sağlığı" görebilir misin? 
# (MQTT broker'ı kontrol etmek için)
```

---

## 🔑 Critical: Merge Conflict Avoid

### ❌ YAPMA

```dart
// KÖTÜ - Hardcote! Conflict riski!
const apiUrl = 'http://myserver.com:3000';
```

### ✅ YAP

```dart
// İYİ - Environment'dan oku
import 'config/environment.dart';

final apiUrl = Environment.backendApiUrl;
```

---

## 📝 Backend API Kodlarken

### Best Practice:
1. **Backend tarafını ayrı klasörde yaz** (backend/ folder)
   ```
   backend/
   ├── main.py (veya main.js, main.go, vb)
   ├── requirements.txt (Python) / package.json (Node)
   └── .env.example
   ```

2. **Kendi .env dosyasında port vs belirt**
   ```
   BACKEND_PORT=8000
   MQTT_BROKER=broker.hivemq.com
   DATABASE_URL=mysql://localhost:3306/agrotwin
   ```

3. **`environment.dart` güncellemesi PR açtırma**
   ```bash
   git checkout -b backend/api-endpoints
   # .../lib/config/environment.dart düzenle
   # backendApiUrl, databaseUrl, vb ekle
   git add lib/config/environment.dart
   git commit -m "config: Add backend API endpoints"
   git push -u origin backend/api-endpoints
   # GitHub'da PR aç → Arda'dan approve bekle
   ```

---

## 🧪 Test: Frontend & Backend Entegrasyonu

Sonra (API yazıldıktan) Flutter uygulamasında:

```dart
// Örnek: Sensor verisi almak
import 'config/environment.dart';
import 'package:http/http.dart' as http;

Future<void> fetchSensorData() async {
  final response = await http.get(
    Uri.parse('${Environment.backendApiUrl}/api/${Environment.backendApiVersion}/sensors'),
  );
  // Parse response...
}
```

---

## 🔐 Security Checklist

- [ ] `.env` dosyası `.gitignore` içinde (commit edilmez)
- [ ] API key'ler, credentials asla hardcode değil (environment'tan oku)
- [ ] HTTPS kullan (production'da)
- [ ] CORS ayarla (Flutter web tag backend'e erişmesi için)

---

## 📞 Communication Rules

Birbirinize yollamayacaklar listesi **GitHub PR comments'te**:
- API endpoint değişimi?  → PR aç, commemt yaz
- MQTT topic değişimi? → PR aç, comment yaz
- Database schema değişimi? → PR aç, document yaz

---

## 🚀 Push to GitHub

### Backend Dev tarafından
```bash
# Yukarıdaki adımları yaptıktan sonra

# 1. Feature branch
git checkout -b backend/initial-setup

# 2. Commit
git add .
git commit -m "docs: Backend setup instructions, local config"

# 3. Push
git push -u origin backend/initial-setup

# 4. GitHub'da PR aç, Arda'dan approval bekle
```

---

## 📚 Referans

- [CONTRIBUTING.md](CONTRIBUTING.md) — Collaboration rules
- [README.md](README.md) — Architecture
- [.env.example](.env.example) — Template

---

**Sorular?** Bu dokumentasyonda veya PR'da sor, Arda cevapla.

Last Updated: April 2026
