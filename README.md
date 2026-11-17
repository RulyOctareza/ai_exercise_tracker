<p align="center">
  <img src="docs/preview/hero.svg" alt="AI Exercise Tracker — ilustrasi aplikasi latihan berbasis pose detection" width="100%">
</p>

<h1 align="center">AI Exercise Tracker</h1>

<p align="center">
  <b>Latihan jadi terukur dengan pose detection di perangkat.</b><br>
  GetX · Clean Architecture · Google ML Kit
</p>

<p align="center">
  <a href="https://flutter.dev"><img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white"></a>
  <a href="https://pub.dev/packages/get"><img alt="GetX" src="https://img.shields.io/badge/State-GetX-8E24AA"></a>
  <img alt="ML Kit" src="https://img.shields.io/badge/ML%20Kit-Pose%20Detection-4285F4?logo=google&logoColor=white">
  <a href="https://firebase.google.com"><img alt="Firebase" src="https://img.shields.io/badge/Auth-Firebase-FFCA28?logo=firebase&logoColor=black"></a>
</p>

---

## ✨ Preview

<p align="center">
  <img src="docs/preview/hero.png" alt="Mockup gelap AI Exercise Tracker" width="90%">
</p>

> **Catatan:** gambar di atas adalah *ilustrasi konsep*, bukan screenshot asli.

---

## 📖 Tentang

AI Exercise Tracker memakai kamera ponsel dan **Google ML Kit Pose Detection** untuk membaca
gerakan tubuh secara real-time. Hasil latihan dicatat, ditampilkan dalam grafik, dan disimpan
ke cloud — dibangun dengan **GetX** dan **Clean Architecture** agar tiap lapisan tetap terpisah.

---

## 🌟 Fitur

- 🎥 **Pose detection real-time** lewat kamera (`google_mlkit_pose_detection`)
- 🏋️ **Pelacakan latihan** dengan hitungan dan riwayat sesi
- 📊 **Grafik progres** menggunakan `fl_chart`
- 🔐 **Autentikasi** Firebase Auth
- ☁️ **Penyimpanan data** di Cloud Firestore
- ✨ Animasi Lottie dan ilustrasi SVG
- 📱 State management GetX + routing

---

## 🛠️ Tech Stack

| Area | Pilihan |
|---|---|
| Framework | Flutter |
| State management | GetX |
| Arsitektur | Clean Architecture |
| Computer vision | Google ML Kit Pose Detection |
| Backend | Firebase Auth + Cloud Firestore |
| Grafik | `fl_chart` |
| Penyimpanan lokal | `shared_preferences` |

---

## 🧱 Struktur

```text
lib/
├── core/          # Konstanta, error, utilitas
├── data/          # Model, datasource, repository implementation
├── domain/        # Entity, use case, repository interface
├── presentation/  # Screen, widget, controller GetX
├── routes/        # Definisi halaman
├── services/      # Layanan kamera, ML, dan Firebase
└── main.dart
```

---

## 🚀 Menjalankan

```bash
flutter pub get
flutter run
```

Butuh perangkat fisik dengan kamera; konfigurasi Firebase mengikuti `firebase.json` di repo.

---

## 🧪 Testing

```bash
flutter analyze
flutter test
```
