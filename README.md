<div align="center">

<br/>

# 📄 PECKPAPERS

### *Scan. Organize. Learn. Master.*

**The intelligent Flutter study companion that transforms handwritten notes into a complete learning experience — powered by OCR, AI-generated quizzes, and smart performance analytics.**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-F5C842?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge)](CONTRIBUTING.md)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-black?style=for-the-badge&logo=flutter)](https://flutter.dev)

<br/>

[**Features**](#-features) &nbsp;•&nbsp; [**Getting Started**](#-getting-started) &nbsp;•&nbsp; [**Tech Stack**](#-tech-stack) &nbsp;•&nbsp; [**Roadmap**](#-roadmap) &nbsp;•&nbsp; [**Contributing**](#-contributing)

<br/>

</div>

---

<br/>

## 🎯 Overview

**PECKPAPERS** is a cross-platform Flutter application that bridges the gap between physical note-taking and modern digital learning. Built for students and self-learners, it uses OCR technology to digitize handwritten or printed notes, converts them into structured PDF documents, and leverages AI to generate interactive flashcards and quizzes — all while tracking your performance to surface exactly what you need to study next.

No more re-reading everything. No more guessing what to review. PECKPAPERS tells you.

<br/>

---

<br/>

## ✨ Features

<br/>

### 📷 &nbsp; Smart Note Scanning
Point. Shoot. Done. PECKPAPERS uses on-device OCR to extract text from handwritten or printed notes with high accuracy — even from imperfect lighting or slightly tilted captures.

- Live camera capture with auto-edge detection and perspective correction
- Support for handwritten, typed, and mixed-content notes
- Batch image import from your gallery
- Multi-language text recognition

<br/>

### 📄 &nbsp; Instant PDF Generation
Every scan is automatically converted into a clean, well-structured PDF that lives in your personal study library — ready to download, share, or reference anytime.

- Auto-formatted PDFs with clear typography and layout
- Organize documents into subjects and custom folders
- Full-text search across your entire library
- One-tap sharing and export

<br/>

### 🃏 &nbsp; AI-Powered Flashcards
Stop making cards manually. PECKPAPERS reads your notes and generates intelligent question-and-answer flashcards automatically — then schedules them for review at exactly the right time using spaced repetition.

- Auto-generated flashcards from scanned note content
- Spaced Repetition System (SRS) for optimized review scheduling
- Edit, customize, and add your own cards
- Track mastery progress per deck

<br/>

### 📝 &nbsp; Interactive Quizzes
Put your knowledge to the test with dynamically generated quizzes drawn directly from your notes.

- Multiple formats: multiple choice, true/false, and fill-in-the-blank
- Timed mode for simulating real exam conditions
- Instant answer feedback with explanations
- Score history for every quiz attempt

<br/>

### 📊 &nbsp; Performance Analytics
See the full picture of your learning. PECKPAPERS tracks every session, identifies where you're struggling, and helps you focus your study time where it matters most.

- Visual dashboards for subject-by-subject mastery
- Weak topic detection — always know what to revisit
- Study streak tracking and session history
- Time-on-task metrics and progress trends over time

<br/>

---

<br/>

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | [Flutter 3.x](https://flutter.dev) — cross-platform iOS & Android from a single codebase |
| **Language** | [Dart 3.x](https://dart.dev) |
| **State Management** | [Riverpod](https://riverpod.dev) / [BLoC](https://bloclibrary.dev) |
| **Backend & Auth** | [Firebase](https://firebase.google.com) — Auth, Firestore, Storage, Cloud Functions |
| **OCR Engine** | [Google ML Kit](https://developers.google.com/ml-kit/vision/text-recognition) — on-device text recognition |
| **AI / Flashcard Generation** | OpenAI API via Firebase Cloud Functions |
| **PDF Generation** | [`pdf`](https://pub.dev/packages/pdf) + [`printing`](https://pub.dev/packages/printing) packages |
| **Local Storage** | [Hive](https://pub.dev/packages/hive) — offline-first caching and study history |
| **Navigation** | [GoRouter](https://pub.dev/packages/go_router) |
| **Camera & Scanning** | [`camera`](https://pub.dev/packages/camera) + [`image`](https://pub.dev/packages/image) packages |
| **Charts & Analytics UI** | [`fl_chart`](https://pub.dev/packages/fl_chart) |
| **Notifications** | [Firebase Cloud Messaging](https://firebase.google.com/products/cloud-messaging) |

<br/>

---

<br/>

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** `3.0+` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** `3.0+` — bundled with Flutter
- **Android Studio** or **Xcode** (for iOS) with emulators configured
- **Firebase project** — [Create one here](https://console.firebase.google.com)
- **Git**

Verify your environment is healthy:
```bash
flutter doctor
```

<br/>

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/your-org/peckpapers.git
cd peckpapers
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Firebase**

- Create a new project in the [Firebase Console](https://console.firebase.google.com)
- Add your Android and/or iOS app to the project
- Download and place the config files:

  | Platform | File | Location |
  |----------|------|----------|
  | Android | `google-services.json` | `android/app/` |
  | iOS | `GoogleService-Info.plist` | `ios/Runner/` |

- Enable the following Firebase services:
  - **Authentication** (Email/Password + Google Sign-In)
  - **Cloud Firestore**
  - **Firebase Storage**
  - **Cloud Functions**

**4. Set up app config**
```dart
// lib/config/app_config.dart

class AppConfig {
  static const String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String appName = 'PECKPAPERS';
  static const String supportEmail = 'support@peckpapers.app';
}
```

> ⚠️ Never commit API keys to version control. Use Firebase Remote Config or environment injection for production.

**5. Run the app**
```bash
flutter run             # default device
flutter run -d android  # Android
flutter run -d ios      # iOS
flutter run --release   # release mode
```

<br/>

---

<br/>

## 🔧 Build & Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release
```

For CI/CD with GitHub Actions, see [`.github/workflows/`](.github/workflows/).

<br/>

---

<br/>

## 🧪 Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests on device
flutter test integration_test/
```

- **Unit tests** — business logic, OCR parsing, data models
- **Widget tests** — UI component behavior
- **Integration tests** — full end-to-end flows on device

<br/>

---

<br/>

## 🛣️ Roadmap

| Status | Feature |
|--------|---------|
| ✅ | OCR scanning — handwritten & printed notes |
| ✅ | PDF generation & organized library |
| ✅ | AI-powered flashcard generation |
| ✅ | Interactive quiz engine |
| ✅ | Performance analytics & weak topic detection |
| 🔄 | Study Groups — share notes & decks with friends |
| 🔄 | Offline-first mode with full local sync |
| 📅 | AI-generated personalized study schedules |
| 📅 | Google Drive & Notion integration |
| 💡 | Voice-to-notes via audio transcription |
| 💡 | Public flashcard deck marketplace |

<br/>

---

<br/>

## 🤝 Contributing
```bash
git clone https://github.com/YOUR_USERNAME/peckpapers.git
git checkout -b feature/amazing-feature
git commit -m "feat: add amazing feature"
git push origin feature/amazing-feature
# then open a Pull Request
```

**Commit convention** — [Conventional Commits](https://www.conventionalcommits.org):

| Prefix | When to use |
|--------|------------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Docs only |
| `style:` | Formatting, no logic change |
| `refactor:` | Restructuring, no feature/fix |
| `test:` | Adding/updating tests |
| `chore:` | Build, dependencies |

Read [CONTRIBUTING.md](CONTRIBUTING.md) for full guidelines.

<br/>

---

<br/>

## 🔐 Security

Found a vulnerability? **Don't open a public issue.** Email **security@peckpapers.app** — we'll respond within 48 hours and coordinate a responsible disclosure together.

See [SECURITY.md](SECURITY.md) for the full policy.

<br/>

---

<br/>

## 📄 License

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.

<br/>

---

<br/>

## 💬 Support & Community

| | Channel |
|--|---------|
| 🐛 Bugs | [GitHub Issues](https://github.com/your-org/peckpapers/issues) |
| 💡 Features | [GitHub Discussions](https://github.com/your-org/peckpapers/discussions) |
| 📧 Email | support@peckpapers.app |
| 🌐 Website | [peckpapers.app](https://peckpapers.app) |
| 🐦 Twitter | [@peckpapers](https://twitter.com/peckpapers) |

<br/>

---

<div align="center">

Made with ❤️ by the **PECKPAPERS** team

*Helping students study smarter, one scan at a time.*

<br/>

**If PECKPAPERS has helped you — drop a ⭐, it means the world to us.**

</div>
