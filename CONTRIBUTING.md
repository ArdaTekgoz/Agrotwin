# CONTRIBUTING.md - Backend & Frontend Collaboration Guide

Bu dosya, AgroTwin projesinde frontend ve backend developer'larının clean collaboration yapmasını sağlar.

## 🎯 Collaboration Strategy

### Frontend yazan: Arda
### Backend yazan: [Backend Developer]

---

## 📋 Conflict-Free Workflow

### 1️⃣ Configuration is Everything (Yapılandırma Merkezi)

**Asla hardcode etme:**
```dart
// ❌ KÖTÜ - Hardcoded broker
const broker = 'mqtt.example.com:1883';

// ✅ İYİ - Environment'dan oku
import '../config/environment.dart';
final broker = Environment.mqttBroker;
```

**Merkezi config dosyası:**
```
lib/config/environment.dart
```

Buraya:
- MQTT broker detayları
- Backend API endpoints
- App-level constants

**Kuralı:** İki developer de bunu kontrol etmeden pull request yapmaz.

---

### 2️⃣ File Ownership (Dosyalar Kimin)

#### Frontend (Arda)
```
lib/screens/          ← UI Screens
lib/main.dart         ← Entry point
lib/core/constants.dart
lib/config/environment.dart   ← SHARED! (Backend de commit edebilir)
.gitignore
README.md
pubspec.yaml
```

#### Backend (Backend Developer)
```
Backend repo (ayrı)   ← Backend API, database, MQTT logic
lib/config/environment.dart   ← SHARED! (Frontend de commit edebilir)
```

---

### 3️⃣ Merge Conflict Minimum Koyul

**Risk alanları:**
- `pubspec.yaml` (dependency eklenirse)
- `lib/config/environment.dart` (config değişirse)
- `README.md` (documentation)

**Conflict Avoid Strategy:**

#### A. Branch naming (Clear Intent)
```bash
# Backend config değişikliği
git checkout -b config/mqtt-endpoint-update

# Frontend UI iyileştirmesi (conflict yok)
git checkout -b feature/dashboard-redesign

# API entegrasyon (Frontend & Backend birlikte)
git checkout -b feature/api-integration
```

#### B. `git rebase` vs `git merge`
```bash
# Merge kullan (simpler untuk collab)
git pull origin main --rebase=false

# VEYA: rebase (cleaner history, başa çıkması harder)
git pull origin main --rebase=true
```

**Recommendation:** Başında `merge` kullan, sonra ögren ve `rebase` geç.

#### C. Communication (Most Important)
```
❌ Doğru: Direkt `git push` + Pull Request
✅ Daha iyi:
   1. "Backend dev, ben MQTT port'unu 8883'ten 8884'e çevirmek istiyorum"
   2. Backend dev: "tamam, config'de güncelle"
   3. Arda: Config güncelle, PR aç, approve
   4. Merge et
```

---

### 4️⃣ Pull Request Checklist

Merge etmeden before:

- [ ] `flutter analyze` no errors
- [ ] `flutter pub get` success
- [ ] Tested on real device (or simulator)
- [ ] `lib/config/environment.dart` değiştiyse: Other dev @mention et
- [ ] Formatting: `dart format lib/`
- [ ] No hardcoded credentials/secrets

---

### 5️⃣ Resolving Conflicts (If They Happen)

```bash
# Conflict var diye warning aldınız
git status

# Conflict dosyasını aç
# VS Code'da: "<<< | === | >>>" göreceksin

# Birini seç veya manual merge et
# VS Code UI'ında: "Accept Current Change" / "Accept Incoming Change" / "Accept Both"

# Çözüm tamamlattınız
git add <file>
git commit -m "chore: Merge conflict resolved"
git push
```

---

## 🔄 Example: Backend Updates MQTT Endpoint

### Scenario
Backend dev: "MQTT broker'ı Eclipse'den HiveMQ'ye taşıyorum"

### Step 1: Backend Dev
```bash
git checkout -b config/hivemq-migration
# --- Edit environment.dart ---
# static const String mqttBroker = 'broker.hivemq.com';
git add lib/config/environment.dart
git commit -m "config: Switch MQTT broker to HiveMQ"
git push -u origin config/hivemq-migration
```

### Step 2: Arda (Frontend)
```bash
# PR'ı gör, review et
# "OK, HiveMQ'ye geçiyorsunuz. Test ediyorum..."

git fetch
git checkout config/hivemq-migration
flutter pub get
flutter run -d chrome

# Testler pass → Approve PR
# VEYA conflict varsa: "Bu line burada var, conflict var" yaz
```

### Step 3: Backend Dev
Conflict varsa → çöz, revert + redo, commit yap.

### Step 4: Merge
Backend dev → "Merge button"

---

## 🚀 Release / Deployment Checklist

### Before Every Release
```bash
# 1. Version bump
# pubspec.yaml: version: 1.0.1+2

# 2. Tag creation
git tag -a v1.0.1 -m "Release v1.0.1"
git push origin v1.0.1

# 3. Build
flutter build web    # Web release
flutter build apk    # Android release (prod keys)
```

---

## 📞 Communication Channels

- **Quick:** Discord / WhatsApp (code share)
- **Formal:** Pull Request comments
- **Scheduled:** Weekly sync (config changes, API updates)

---

## ⚠️ Golden Rules

1. **Config is Law** → `environment.dart` güncelle, PR aç, approve bekle
2. **Secrets Never in Git** → `.gitignore` içinde olmalı
3. **Message is King** → Clear commit messages, PR descriptions
4. **Test Locally** → Push etmeden before, `flutter run` veya `flutter test`
5. **Respect Others' Code** → review yapan'a saygılı reply yap

---

## 🎓 Learning Resources

- [Git Workflows](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Clean Code in Dart](https://pub.dev/packages/effective_dart)

---

**Last Updated:** April 2026
**Prepared By:** Frontend Developer (Arda)
