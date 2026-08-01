# LittleTech Architecture Documentation

> Technical deep-dive for contributors and maintainers.

---

## 📐 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
├─────────────────────────────────────────────────────────────┤
│  main.dart  ──►  App (MultiBlocProvider)  ──►  Screens      │
├─────────────────────────────────────────────────────────────┤
│                     FEATURE MODULES                         │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │
│  │  Auth  │ │  Game  │ │ Home   │ │ Solutions│ Settings│    │
│  └────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘ └────┬───┘    │
├───────┼───────────┼───────────┼───────────┼───────────┤     │
│       ▼           ▼           ▼           ▼           ▼     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    CORE LAYER                        │   │
│  │  Constants │ Navigation │ Services │ Widgets       │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│                     DATA LAYER                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │    Isar DB   │    │SharedPrefs   │    │  Assets/Files │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎮 Game Module Architecture (Core)

### Layer Responsibilities

```
lib/src/features/game/
├── data/
│   ├── models/           # Isar entities (PlayerProgress)
│   ├── repositories/     # GameRepository (Isar transactions)
│   └── services/         # External services (none currently)
├── domain/
│   ├── cubit/            # GameCubit, SupTechCustomizationCubit, ThemeCubit
│   └── models/           # GameState, SupTechContext, LevelDef, WorldDef, etc.
└── presentation/
    ├── screens/          # WorldScreen, LevelScreen, BossScreen, etc.
    └── widgets/          # Reusable game UI components
```

### State Management: GameCubit

```dart
// Single source of truth for all gameplay state
class GameCubit extends Cubit<GameState> {
  final GameRepository _repository;
  int _userId;

  // State is immutable (Equatable)
  // All mutations go through copyWith()
  // Persistence is async + non-blocking via _safePersist()
}
```

#### GameState Fields

| Field | Type | Purpose |
|-------|------|---------|
| `progress` | `PlayerProgress` | Persisted user data (points, unlocks, completion) |
| `currentWorld` | `WorldDef?` | Active category/world |
| `currentLevel` | `LevelDef?` | Active level |
| `currentStepIndex` | `int` | Step within level (0-based) |
| `currentBossHp` | `int` | Boss battle HP |
| `bossHpMultiplier` | `int` | Difficulty scaling |
| `lastDrawnReward` | `RewardDef?` | Reward popup data |
| `supTechContext` | `SupTechContext` | Hint system mode |
| `hintText` | `String?` | Active hint display |
| `pointsMultiplier` | `int` | Challenge/bonus multiplier |
| `currentBoss` | `BossEncounterDef?` | Active boss data |
| `newlyUnlockedAchievements` | `List<Achievement>` | Popup queue |
| `persistError` | `bool` | Write failure flag |
| `persistErrorCritical` | `bool` | Critical write failure |
| `paidStepIndices` | `Set<int>` | Steps already awarded points |
| `lastLevelPointsEarned` | `int` | Summary display |
| `earnedNoSupTechBonus` | `bool` | Bonus tracking |
| `usedSupTechActions` | `Map<String, Set<String>>` | Per-question SupTech usage |

---

## 🗄 Data Layer: Isar Database

### PlayerProgress Schema

```dart
@collection
class PlayerProgress {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int userId;           // Sharding key
  
  // Core progression
  int points = 0;
  int levelsCleared = 0;
  int bossesDefeated = 0;
  
  // Completion tracking
  List<String> completedLevelIds = [];
  List<String> completedCategoryIds = [];
  
  // SupTech system
  int supTechUsesThisLevel = 1;
  int extraSupTechUses = 0;
  
  // Customization
  String? activeSkinId;
  String? activeFrameId;
  String? activeIconId;
  String? activeTitleId;
  String? themeId;
  List<String> unlockedSkinIds = ['default'];
  
  // Rewards & purchases
  List<String> earnedRewardIds = [];
  List<String> purchasedItemIds = [];
  
  // Achievements
  List<String> unlockedAchievementIds = [];
  List<String> pendingAchievementIds = [];
  
  // Boss tracking
  List<String> defeatedBossIds = [];
  int weeklyBossesDefeated = 0;
  
  // Daily/Weekly
  DateTime? lastDailyQuestDate;
  DateTime? lastWeeklyBossDate;
  
  // Play history
  List<DateTime> playDates = [];
  DateTime? lastActiveDate;
  int totalPlayTimeSeconds = 0;
  
  // Stats
  int correctAnswers = 0;
  int totalAnswers = 0;
  
  // Prep results (serialized JSON per level)
  List<String> prepResults = [];
  
  // Current session
  int currentWorldId = 0;
  String? currentCategoryId;
  String? currentLevelId;
}
```

### Repository Pattern

```dart
class GameRepository {
  final Isar _isar;
  
  // All writes wrapped in writeTxn
  Future<void> saveProgress(PlayerProgress progress) async {
    await _isar.writeTxn(() => _isar.playerProgress.put(progress));
  }
  
  // Queries use indexes
  Future<PlayerProgress?> loadProgress(int userId) async {
    return _isar.playerProgress
      .filter()
      .userIdEqualTo(userId)
      .findFirst();
  }
  
  // Batch operations for critical writes
  Future<void> saveBatch(PlayerProgress progress) async {
    await _isar.writeTxn(() => _isar.playerProgress.put(progress));
  }
}
```

---

## ⚙ Core Services: RuleEngine

### Purpose

Procedurally generates troubleshooting solutions from problem keywords. Enables 400+ levels from ~200 problem keys.

### Input/Output

```dart
// Input: problem key string
final solution = RuleEngine.solve('high cpu usage');

// Output: structured solution
class Solution {
  final List<String> steps;           // Ordered diagnostic steps
  final List<String> hints;           // Contextual hints
  final String? explanation;          // Conceptual explanation
  final Map<String, dynamic> metadata; // Verification commands, etc.
}
```

### Rule Structure

```dart
// Rules defined in rule_engine.dart (~77KB)
final rules = {
  'high cpu usage': Rule(
    steps: [
      'Open Task Manager (Ctrl+Shift+Esc)',
      'Sort by CPU column descending',
      'Identify top consuming process',
      'Research process legitimacy',
      'Apply appropriate fix...'
    ],
    hints: [
      'System processes often spike briefly',
      'Check for runaway loops in user apps',
      'Antivirus scans can cause temporary spikes'
    ],
    explanation: 'CPU usage represents...',
    metadata: {
      'verification': 'tasklist /FI "CPUTIME gt 00:00:10"',
      'tools': ['Task Manager', 'Process Explorer', 'Resource Monitor']
    }
  ),
  // ... 200+ rules
};
```

### Fallback Generation

Unknown keys → generic diagnostic template:

```dart
// Generic fallback for unrecognized problems
Solution.generic(problemKey) => Solution(
  steps: [
    'Identify symptoms and error messages',
    'Check recent changes (updates, installs)',
    'Isolate component (hardware/software/network)',
    'Apply known fixes for similar issues',
    'Verify resolution and monitor'
  ],
  hints: ['Start simple', 'Check logs', 'Search error codes'],
  explanation: 'Systematic troubleshooting follows...',
);
```

---

## 🎨 Theming & Customization

### ThemeCubit

```dart
class ThemeCubit extends Cubit<ThemeData> {
  // Applies theme from PlayerProgress.themeId
  // Themes defined in core/constants/design_tokens.dart
  // Supports: light, dark, plus unlockable variants
}
```

### Design Tokens

```dart
// lib/src/core/constants/design_tokens.dart
class DesignTokens {
  // Spacing scale (4px base)
  static const spacing = [4, 8, 12, 16, 24, 32, 48, 64];
  
  // Typography
  static const headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  static const bodyMedium = TextStyle(fontSize: 14, height: 1.5);
  static const monoStyle = TextStyle(fontFamily: 'JetBrainsMono');
  
  // Colors (semantic)
  static const primary = Color(0xFF4A9BA8);
  static const surface = Color(0xFF1E1E24);
  static const error = Color(0xFFE85D5D);
  // ... unlockable theme palettes
}
```

---

## 🔄 Auth System

### AuthService (Singleton)

```dart
class AuthService {
  static SharedPreferences? _prefs;
  static const _usersKey = 'lt_users';
  static const _currentUserKey = 'lt_current_user';
  
  // User model: {id, username, passwordHash, createdAt, lastLogin}
  // Passwords: PBKDF2 (crypto package)
  // Session: persists current user ID
  
  static Future<void> init(SharedPreferences prefs) { ... }
  static Future<User?> register(String username, String password) { ... }
  static Future<User?> login(String username, String password) { ... }
  static Future<void> logout() { ... }
  static Future<int?> getFreshUserId() { ... }
  static Future<List<User>> getAllUsers() { ... }
}
```

### Auth Flow

```
SplashScreen
    │
    ▼
AuthService.getFreshUserId() ──► null ──► LoginScreen
    │                              ▲
    ▼                              │
  User ID                         │
    │                             │
    ▼                             │
GameCubit.switchUser(id)          │
    │                             │
    ▼                             │
HomeScreen ◄──────────────────────┘
    │
    ▼
[Account Switch] ──► LoginScreen(showAccountPicker: true)
```

---

## 🧭 Navigation

### Route Structure

```dart
// lib/src/core/navigation/app_router.dart
final routes = {
  '/': (ctx) => SplashScreen(),
  '/login': (ctx) => LoginScreen(),
  '/register': (ctx) => RegisterScreen(),
  '/forgot': (ctx) => ForgotPasswordScreen(),
  '/reset': (ctx) => CreateNewPasswordScreen(),
  '/home': (ctx) => HomeScreen(),
  '/world/:worldId': (ctx) => WorldScreen(worldId: ...),
  '/level/:levelId': (ctx) => LevelScreen(levelId: ...),
  '/boss/:bossId': (ctx) => BossScreen(bossId: ...),
  '/solutions': (ctx) => SolutionsScreen(),
  '/solutions/category/:catId': (ctx) => ProblemsListScreen(catId: ...),
  '/solutions/detail/:problemKey': (ctx) => SolutionDetailScreen(problemKey: ...),
  '/settings': (ctx) => SettingsScreen(),
  '/customize': (ctx) => CustomizationScreen(),
  '/profile': (ctx) => ProfileScreen(),
};
```

### Navigation Pattern

```dart
// In Cubits: use navigatorKey from App
_navKey.currentState?.pushNamed('/level/$levelId');

// In Widgets: context.go() or Navigator.push()
context.pushNamed('level', pathParameters: {'levelId': id});
```

---

## 🎯 Key Algorithms

### Streak Calculation

```dart
// lib/src/features/game/constants/streak_tracker.dart
static int calculateStreak(List<DateTime> playDates) {
  if (playDates.isEmpty) return 0;
  
  final sorted = playDates.toList()
    ..sort((a, b) => b.compareTo(a)); // Descending
  
  int streak = 0;
  DateTime expected = DateTime.now().subtract(Duration(days: streak));
  
  for (final date in sorted) {
    final day = DateTime(date.year, date.month, date.day);
    if (day.isAtSameMomentAs(expected)) {
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    } else if (day.isBefore(expected)) {
      break; // Gap found
    }
  }
  return streak;
}
```

### Reward Drawing (Weighted Random)

```dart
// lib/src/features/game/constants/reward_pool.dart
static RewardDef? draw() {
  final weights = _pool.map((r) => r.weight).toList();
  final total = weights.reduce((a, b) => a + b);
  final roll = Random().nextInt(total);
  
  var sum = 0;
  for (int i = 0; i < _pool.length; i++) {
    sum += weights[i];
    if (roll < sum) return _pool[i];
  }
  return null;
}
```

### Achievement Checking

```dart
// lib/src/features/game/constants/achievements.dart
static List<Achievement> checkNew({
  required int levelsCleared,
  required int bossesDefeated,
  required int points,
  required int rewardsEarned,
  required int streak,
  required int categoriesCompleted,
  required Map<String, int> categoryLevelCounts,
  required List<String> alreadyUnlockedIds,
}) {
  return all
    .where(a => !alreadyUnlockedIds.contains(a.id))
    .where(a => a.condition(
      levelsCleared: levelsCleared,
      bossesDefeated: bossesDefeated,
      points: points,
      rewardsEarned: rewardsEarned,
      streak: streak,
      categoriesCompleted: categoriesCompleted,
      categoryLevelCounts: categoryLevelCounts,
    ))
    .toList();
}
```

---

## 🧪 Testing Strategy

### Unit Tests

- **Cubit logic**: State transitions, business rules
- **Repository**: Query/update behavior (mock Isar)
- **RuleEngine**: Solution generation for known keys
- **Achievements**: Condition evaluation
- **StreakTracker**: Edge cases (gaps, timezone)

### Widget Tests

- Screen rendering with mocked Cubits
- User interactions → Cubit method calls
- Error states (persistError, empty data)
- Accessibility semantics

### Integration Tests

- Full auth flow (register → login → play → logout)
- Level completion → reward → achievement unlock
- Boss battle → defeat → progression
- Account switch → data isolation

---

## 📦 Build & Release

### Versioning

`pubspec.yaml`: `version: 2.0.0+2` (semver + build number)

### Build Variants

| Variant | Command | Use Case |
|---------|---------|----------|
| Debug | `flutter run` | Development |
| Profile | `flutter run --profile` | Performance |
| Release APK | `flutter build apk --release` | Testing/Internal |
| App Bundle | `flutter build appbundle --release` | Play Store |
| iOS | `flutter build ios --release` | App Store |
| Windows | `flutter build windows --release` | Microsoft Store |
| Web | `flutter build web --release` | GitHub Pages |

### CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter pub run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
```

---

## 🔧 Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Dependencies, assets, version, flutter config |
| `analysis_options.yaml` | Linter rules (strict) |
| `.gitignore` | Build artifacts, IDE, local config |
| `.metadata` | Flutter project metadata |
| `devtools_options.yaml` | DevTools preferences |

---

## 📊 Performance Considerations

### Isar Optimization

- **Indexes**: `userId` indexed for O(log n) lookup
- **Transactions**: Batch writes in `saveBatch()`
- **Lazy loading**: `findFirst()` vs `where().findAll()`
- **Mutable lists**: `ensureMutableLists()` after load

### UI Performance

- `const` constructors wherever possible
- `RepaintBoundary` for complex widgets
- `ListView.builder` for long lists
- `flutter_animate` for declarative animations (GPU)

### Memory

- Dispose Cubits in `App.dispose()`
- Cancel streams/subscriptions
- Clear image caches on navigation
- Isar connection reused (singleton)

---

## 🔐 Security Notes

- **No network calls** — fully offline
- **Password hashing**: PBKDF2-SHA256 (100k iterations)
- **Isar encryption**: Optional (not enabled by default)
- **No analytics/tracking** — zero telemetry
- **User data isolation**: Separate DB per user ID

---

## 📚 Further Reading

- [Flutter Architecture Guide](https://flutter.dev/docs/resources/architectural-overview)
- [Isar Documentation](https://isar.dev/)
- [Bloc Library](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

*Architecture doc version 1.0 — Update with significant changes.*