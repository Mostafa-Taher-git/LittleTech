# Contributing to LittleTech

Thank you for considering contributing! This guide will help you get started.

---

## 🎯 Ways to Contribute

| Type | Description |
|------|-------------|
| **Bug Reports** | Found a crash, visual glitch, or logic error? |
| **Feature Requests** | Have an idea for new content or mechanics? |
| **Code Contributions** | Fix bugs, add features, improve architecture |
| **Content** | New problem keys, boss designs, achievements, hints |
| **Localization** | Translate UI to your language |
| **Documentation** | Improve README, add code comments, write guides |
| **Testing** | Write unit/widget/integration tests |
| **Design** | UI polish, animations, accessibility, icons |

---

## 🛠 Development Setup

### Prerequisites

- Flutter **3.16+** (stable channel)
- Dart **3.2+**
- Git
- IDE: VS Code (recommended) or Android Studio

### Clone & Configure

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/LittleTech.git
cd LittleTech

# Add upstream remote
git remote add upstream https://github.com/Mostafa-Taher-git/LittleTech.git

# Install dependencies
flutter pub get

# Generate code (Isar models, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Verify setup
flutter analyze
flutter test
```

### Run the App

```bash
# Debug mode (hot reload)
flutter run

# Release profile (performance testing)
flutter run --profile

# Specific device
flutter run -d <device_id>
```

---

## 📝 Code Standards

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `flutter analyze` before committing — **zero warnings required**
- Format with `dart format .` (enforced by CI)
- **No `// TODO:` comments** — create GitHub issues instead

### Architecture Rules

| Rule | Description |
|------|-------------|
| **Feature-first** | All code lives in `lib/src/features/<feature>/` |
| **Clean layers** | `data/` (repository/models) → `domain/` (cubit/state) → `presentation/` (UI) |
| **Immutable state** | All Cubit states use `Equatable` + `copyWith` |
| **Repository pattern** | All Isar access via Repository — never in Cubit directly |
| **Safe persistence** | Use `_safePersist()` wrapper for all writes |
| **No logic in UI** | Widgets only render + dispatch events |

### Naming Conventions

```dart
// Files: snake_case
game_cubit.dart
player_progress.dart

// Classes: PascalCase
class GameCubit extends Cubit<GameState>

// Variables/Methods: camelCase
void solveStep() { }
final currentWorldId = 0;

// Constants: UPPER_SNAKE_CASE
static const maxSupTechUses = 3;

// Private: underscore prefix
void _safePersist() { }
```

### Git Commits

Use **Conventional Commits**:

```
feat(game): add weekly boss encounter system
fix(auth): resolve account switching race condition
docs: update README with architecture diagram
refactor(core): extract RuleEngine into separate package
test(game): add cubit state transition tests
chore: update dependencies
```

**Subject line ≤ 72 chars**, body explains *why*, not *what*.

---

## 🧪 Testing Requirements

### Before Submitting PR

```bash
# 1. Static analysis
flutter analyze

# 2. All tests pass
flutter test

# 3. Format check
dart format --output=none --set-exit-if-changed .

# 4. Build succeeds
flutter build apk --debug  # or your target platform
```

### Test Categories

| Type | Location | Command |
|------|----------|---------|
| **Unit** | `test/unit/` | `flutter test test/unit/` |
| **Widget** | `test/widget/` | `flutter test test/widget/` |
| **Integration** | `integration_test/` | `flutter test integration_test/` |

### Writing Tests

```dart
// test/unit/game_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('GameCubit', () {
    late MockGameRepository repo;
    late GameCubit cubit;

    setUp(() {
      repo = MockGameRepository();
      cubit = GameCubit(repo, 1);
    });

    blocTest<GameCubit, GameState>(
      'emits completed state when solveStep finishes level',
      build: () => cubit,
      act: (c) => c.solveStep(),
      expect: () => [isA<GameState>().having((s) => s.currentStepIndex, 'step', 1)],
    );
  }
}
```

---

## 📦 Pull Request Process

### 1. Create Feature Branch

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/issue-description
```

### 2. Make Changes

- Small, focused commits
- Update tests for new logic
- Update documentation if API changes
- No unrelated formatting changes

### 3. Push & Open PR

```bash
git push origin feat/your-feature-name
```

Open PR against `main` with:
- **Clear title** (conventional commit format)
- **Description**: What, Why, How
- **Screenshots/GIFs** for UI changes
- **Related issues**: `Closes #123`, `Relates to #456`

### 4. Review Checklist

PR must pass:
- [ ] All CI checks green
- [ ] `flutter analyze` — zero issues
- [ ] `flutter test` — 100% pass
- [ ] No merge conflicts
- [ ] Meaningful commit history (squash if needed)
- [ ] Documentation updated

### 5. Merge

Maintainers will:
- Review code & architecture
- Request changes if needed
- Squash & merge to `main`
- Delete feature branch

---

## 🎨 Content Contribution Guide

### Adding New Problem Keys

1. Edit `lib/src/core/constants/category_manager.dart`
2. Add to appropriate `CategoryDef.problemKeys`
3. RuleEngine auto-generates level content
4. Test: `flutter run` → select category → verify level appears

### Adding Boss Encounters

1. Edit `lib/src/features/game/constants/boss_encounter_data.dart`
2. Add `BossEncounterDef` to category's `bosses` list
3. Define: `abilities`, `diagnosis`, `strategies`, `visualType`
4. Test boss battle flow

### Adding Achievements

1. Edit `lib/src/features/game/constants/achievements.dart`
2. Add to `AchievementManager.all`
3. Define: `id`, `name`, `description`, `condition`, `rewards`
4. Test unlock condition

---

## 🌍 Localization

### Adding a Language

1. Create `lib/l10n/app_<locale>.arb` (e.g., `app_es.arb`)
2. Translate all keys from `app_en.arb`
3. Add locale to `supportedLocales` in `app.dart`
4. Test: `flutter run --locale=es`

### RTL Support

- Use `Directionality` widget for RTL languages
- Test layout mirroring
- Ensure icons flip correctly

---

## 🔒 Security

### Reporting Vulnerabilities

**Do not open public issues** for security bugs.

Email: **mostafa.taher.c1@gmail.com** (or GitHub Security Advisories)

Include:
- Description of vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

---

## 📞 Getting Help

| Channel | Purpose |
|---------|---------|
| **GitHub Discussions** | Questions, ideas, general chat |
| **GitHub Issues** | Bug reports, feature requests |
| **PR Comments** | Code review discussion |
| **Email** | [mostafa.taher.c1@gmail.com](mailto:mostafa.taher.c1@gmail.com) |

---

## 🏷 Labels Guide

| Label | Meaning |
|-------|---------|
| `good first issue` | Beginner-friendly, well-scoped |
| `help wanted` | Community assistance needed |
| `bug` | Confirmed defect |
| `enhancement` | New feature or improvement |
| `content` | Levels, bosses, achievements, text |
| `architecture` | Structural/refactoring changes |
| `testing` | Test-related work |
| `docs` | Documentation only |
| `blocked` | Waiting on external dependency |

---

## 📜 Code of Conduct

This project follows the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you agree to uphold this code.

**Be respectful, inclusive, and constructive.**

---

## 🙏 Recognition

All contributors listed in:
- `AUTHORS.md` (auto-generated from git)
- Release notes
- GitHub Contributors graph

---

**Thank you for making LittleTech better!** 🎮🔧