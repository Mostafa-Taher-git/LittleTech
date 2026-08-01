# LittleTech — Expert Troubleshooting Gamified Learning App

![LittleTech Banner](assets/icon/banner.png)

> **Learn tech troubleshooting through RPG-style gameplay.** Master 14 real-world IT domains, defeat boss battles, unlock rewards, and build genuine diagnostic skills — all offline, all free.

---

## 🎮 What is LittleTech?

LittleTech transforms technical troubleshooting into an engaging progression game. Instead of reading dry manuals, you **play through realistic scenarios** — diagnosing high CPU usage, fixing boot loops, resolving DNS issues, defeating malware infections — across 14 categories with 400+ levels.

Each level teaches a **real diagnostic methodology** powered by a procedural **Rule Engine** that generates context-aware troubleshooting steps from problem keywords.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| **14 Troubleshooting Worlds** | Core Components, RAM, OS, Audio, Peripherals, Software, Internet, Storage, Display, Mobile, Gaming, Smart Home, Security, Networking |
| **400+ Procedural Levels** | Real problems → algorithmic solutions via Rule Engine |
| **Boss Battles** | RPG encounters with HP, abilities, phase shifts, diagnostic puzzles |
| **SupTech Assistant** | Hint / Diagnose / Explain / Skip — limited uses, strategic choices |
| **Progression System** | Points, streaks, daily/weekly quests, 30+ achievements |
| **Deep Customization** | 50+ skins, frames, icons, titles, themes — earned, not bought |
| **Multi-User Support** | Local accounts, progress isolation, account switching |
| **100% Offline** | No login required, no data leaves device, Isar database |
| **Reference Library** | Searchable solutions database with save/bookmark |

---

## 📱 Screenshots

| Splash | Home / Worlds | Level Play | Boss Battle | Customization |
|--------|---------------|------------|-------------|---------------|
| ![Splash](docs/screenshots/splash.png) | ![Home](docs/screenshots/home.png) | ![Level](docs/screenshots/level.png) | ![Boss](docs/screenshots/boss.png) | ![Customize](docs/screenshots/customize.png) |

> *Add screenshots to `docs/screenshots/` and they'll render automatically.*

---

## 🏗 Architecture

```
lib/
├── main.dart                 # App entry, Isar + Auth init
├── app.dart                  # MultiBlocProvider, routing, theme
└── src/
    ├── core/
    │   ├── constants/        # Colors, design tokens, CategoryManager
    │   ├── navigation/       # Route definitions
    │   ├── services/         # RuleEngine (77KB procedural solver)
    │   └── widgets/          # Shared UI components
    └── features/
        ├── auth/             # Login/Register/Forgot, local auth
        ├── game/             # Core gameplay (Cubit + Repository + Isar)
        │   ├── data/         # Models, Repositories, Services
        │   ├── domain/       # Cubits, Domain Models
        │   └── presentation/ # Screens, Widgets
        ├── home/             # World selection, progress overview
        ├── onboarding/       # First-run tutorial
        ├── solutions/        # Reference library (search, save, categories)
        ├── settings/         # Account, theme, data management
        └── splash/           # Boot sequence, auth check
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x (Dart 3) |
| **State** | `flutter_bloc` (Cubit pattern) |
| **Database** | `isar` (offline-first, reactive) |
| **Persistence** | `shared_preferences` (auth), `path_provider` |
| **Fonts** | `google_fonts` (Inter, JetBrains Mono) |
| **Animations** | `flutter_animate` |
| **Utils** | `equatable`, `gap`, `crypto`, `url_launcher` |

### State Management Pattern

```dart
// Feature cubits emit immutable Equatable states
// Repository handles all Isar transactions
// _safePersist() wraps writes with error handling + UI feedback
class GameCubit extends Cubit<GameState> {
  final GameRepository _repository;
  
  void solveStep() {
    // 1. Validate state
    // 2. Compute changes
    // 3. Persist via repository (async, non-blocking)
    // 4. Emit new state
    _safePersist([() => _repository.addPoints(progress, points)]);
    emit(state.copyWith(progress: updatedProgress));
  }
}
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK **3.16+** (Dart 3.2+)
- Android Studio / VS Code with Flutter extension
- Android SDK / Xcode for device testing

### Installation

```bash
# Clone
git clone https://github.com/Mostafa-Taher-git/LittleTech.git
cd LittleTech

# Install dependencies
flutter pub get

# Generate Isar models (required after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run
```

### Build Commands

```bash
# Debug APK
flutter build apk --debug

# Release APK (signed)
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

---

## 🧪 Testing

```bash
# Unit + widget tests
flutter test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 Project Structure Deep Dive

### Game Data Flow

```
User Action (tap "Solve Step")
       │
       ▼
GameCubit.solveStep()
       │
       ├─► Validate current level/step
       ├─► Award points (if first attempt)
       ├─► Check level completion
       │       │
       │       ├─► Calculate streak bonus
       │       ├─► Draw reward (skin/theme/points)
       │       ├─► Update play dates, daily quest
       │       └─► Check achievements
       │
       ├─► _safePersist() → GameRepository → Isar writeTxn
       │
       └─► emit(GameState.copyWith(...))
               │
               ▼
       UI rebuilds (BlocBuilder listeners)
```

### Rule Engine (Procedural Content)

The `RuleEngine` (`core/services/rule_engine.dart`) is the **expert system brain**. It maps problem keywords → diagnostic steps:

```dart
// Input: "high cpu usage"
// Output: Structured solution with steps, hints, verification
final solution = RuleEngine.solve('high cpu usage');
// Solution.steps = [
//   "Open Task Manager (Ctrl+Shift+Esc)",
//   "Sort by CPU column",
//   "Identify top consuming process",
//   "Research process legitimacy",
//   "Apply appropriate fix..."
// ]
```

This enables **400+ unique levels** from ~200 problem keys across 14 categories.

---

## 🎨 Customization System

| Slot | Type | Unlock Method |
|------|------|---------------|
| **Skin** | Character appearance | Level progression, rewards, achievements |
| **Frame** | Nickname border | Achievements, weekly boss |
| **Icon** | Profile badge | Special rewards |
| **Title** | Display name prefix | Milestones (100 levels, 50 bosses, etc.) |
| **Theme** | App color scheme | Rare reward drops |

All items are **earned through gameplay** — no IAP, no ads, no dark patterns.

---

## 🔐 Privacy & Data

- **Zero network requests** — fully offline
- **Local-only storage** — Isar DB in app documents directory
- **No analytics, no tracking, no telemetry**
- **Multi-user isolation** — each account = separate encrypted progress
- **Account deletion** — wipes all associated data instantly

---

## 🗺 Roadmap

- [ ] **Cloud sync (optional)** — encrypted backup to user's Drive/iCloud
- [ ] **Community levels** — import/export custom problem packs
- [ ] **AR mode** — overlay diagnostics on real hardware (camera + ML)
- [ ] **Desktop companion** — sidecar app for PC troubleshooting
- [ ] **Localization** — ES, FR, DE, AR, ZH, HI, PT, RU, JA, KO

---

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

### Quick Start for Contributors

1. Fork & clone
2. Create feature branch: `git checkout -b feat/amazing-feature`
3. Make changes, add tests
4. Run `flutter analyze && flutter test`
5. Submit PR with clear description

### Areas Seeking Help

- 🎨 **UI/UX polish** — animations, transitions, accessibility
- 🌍 **Localization** — translations, RTL support
- 🧪 **Test coverage** — widget, integration, golden tests
- 📚 **Content** — new problem keys, boss designs, achievements
- ⚡ **Performance** — Isar query optimization, frame budget

---

## 📄 License

**MIT License** — see [LICENSE](LICENSE) for details.

```
MIT License

Copyright (c) 2024 Mostafa Taher

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- **Flutter Team** — for an incredible framework
- **Isar Team** — for the fastest local database
- **Rule Engine Inspiration** — expert systems, diagnostic reasoning literature
- **Community** — testers, bug reporters, feature requesters

---

## 📞 Contact & Links

| Platform | Link |
|----------|------|
| **GitHub** | [Mostafa-Taher-git](https://github.com/Mostafa-Taher-git) |
| **Issues** | [Bug Reports & Features](https://github.com/Mostafa-Taher-git/LittleTech/issues) |
| **Discussions** | [Q&A, Ideas, Showcase](https://github.com/Mostafa-Taher-git/LittleTech/discussions) |

---

<div align="center">

**Built with ❤️ for troubleshooters everywhere**

*LittleTech v2.0.0 — Learn by doing. Fix by thinking.*

</div>