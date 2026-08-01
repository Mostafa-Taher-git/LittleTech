# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Comprehensive documentation (README, ARCHITECTURE, CONTRIBUTING, CODE_OF_CONDUCT)
- MIT License

---

## [2.0.0] - 2026-07-12

### Added
- **Complete rewrite** from v1.x with clean architecture
- 14 troubleshooting categories (400+ levels)
- RuleEngine procedural content generation
- RPG-style boss battles with abilities/strategies
- SupTech assistant system (hint/diagnose/explain/skip)
- Achievement system (30+ achievements)
- Deep customization (skins, frames, icons, titles, themes)
- Multi-user local auth with account switching
- Solutions reference library with search/save
- Daily/weekly quests and streak tracking
- Offline-first Isar database
- Full test coverage foundation

### Changed
- State management: Provider → flutter_bloc (Cubit)
- Database: SQLite → Isar
- Content: Static JSON → Procedural RuleEngine
- Architecture: Monolithic → Feature-modular

### Fixed
- Account switching race conditions
- Progress persistence error handling
- Boss battle HP scaling
- Reward duplication on level replay

---

## [1.2.0] - 2023-11-20

### Added
- Smart Home category (16 problems)
- Security category (16 problems)
- Networking category (16 problems)
- Weekly boss encounters
- Daily quest system
- Achievement notifications

### Fixed
- Audio category boss HP balance
- Storage level generation edge cases
- Settings screen navigation

---

## [1.1.0] - 2023-09-10

### Added
- Gaming category (16 problems)
- Mobile category (16 problems)
- Display category (16 problems)
- Customization screen (skins/frames)
- Theme system (light/dark + unlockable)
- Points shop (purchase unlocks)

### Changed
- Level progression: linear → world-based
- SupTech uses: global → per-level + extra

### Fixed
- RAM category level duplication
- OS boot loop level logic
- Points calculation on boss defeat

---

## [1.0.0] - 2023-07-01

### Added
- Initial release
- 6 categories: Core Components, RAM, OS, Audio, Peripherals, Software
- 174 levels (29 per category)
- Basic progression (points, levels cleared)
- Local auth (register/login)
- SQLite database
- Provider state management
- Basic UI (Material 3)

---

## Version History Summary

| Version | Date | Categories | Levels | Major Features |
|---------|------|------------|--------|----------------|
| 1.0.0 | 2023-07 | 6 | 174 | Core gameplay, auth, SQLite |
| 1.1.0 | 2023-09 | 9 | 261 | Gaming/Mobile/Display, themes, shop |
| 1.2.0 | 2023-11 | 12 | 348 | Smart Home/Security/Networking, quests |
| 2.0.0 | 2026-07 | 14 | 406 | Rewrite: Bloc, Isar, RuleEngine, bosses, achievements, customization |

---

## Release Process

1. Update `pubspec.yaml` version
2. Update `CHANGELOG.md`
3. Create release branch: `git checkout -b release/v2.1.0`
4. Run full test suite: `flutter test && flutter analyze`
5. Build release artifacts
6. Create GitHub Release with notes
7. Merge to `main`, tag: `git tag v2.1.0`
8. Deploy to stores