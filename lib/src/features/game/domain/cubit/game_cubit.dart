import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:littletech/src/features/auth/data/services/auth_service.dart';
import 'package:littletech/src/features/game/constants/achievements.dart';
import 'package:littletech/src/features/game/constants/game_data.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/constants/skin_tiers.dart';
import 'package:littletech/src/features/game/data/models/player_progress.dart';
import 'package:littletech/src/features/game/data/repositories/game_repository.dart';
import 'package:littletech/src/features/game/constants/streak_tracker.dart';
import 'package:littletech/src/core/constants/category_manager.dart';

class GameState {
  final PlayerProgress progress;
  final WorldDef? currentWorld;
  final LevelDef? currentLevel;
  final int currentStepIndex;
  final int currentBossHp;
  final int bossHpMultiplier;
  final RewardDef? lastDrawnReward;
  final bool isBossMode;
  final String? hintText;
  final int pointsMultiplier;
  final BossEncounterDef? currentBoss;
  final List<Achievement> newlyUnlockedAchievements;
  final bool persistError;
  final bool persistErrorCritical;
  final Set<int> paidStepIndices;
  final int lastLevelPointsEarned;
  final bool earnedNoSupTechBonus;

  const GameState({
    required this.progress,
    this.currentWorld,
    this.currentLevel,
    this.currentStepIndex = 0,
    this.currentBossHp = 0,
    this.bossHpMultiplier = 1,
    this.lastDrawnReward,
    this.isBossMode = false,
    this.hintText,
    this.pointsMultiplier = 1,
    this.currentBoss,
    this.newlyUnlockedAchievements = const [],
    this.persistError = false,
    this.persistErrorCritical = false,
    this.paidStepIndices = const {},
    this.lastLevelPointsEarned = 0,
    this.earnedNoSupTechBonus = false,
  });

  static const _sentinel = Object();

  GameState copyWith({
    PlayerProgress? progress,
    Object? currentWorld = _sentinel,
    Object? currentLevel = _sentinel,
    int? currentStepIndex,
    int? currentBossHp,
    int? bossHpMultiplier,
    Object? lastDrawnReward = _sentinel,
    bool? isBossMode,
    Object? hintText = _sentinel,
    int? pointsMultiplier,
    Object? currentBoss = _sentinel,
    List<Achievement>? newlyUnlockedAchievements,
    bool? persistError,
    bool? persistErrorCritical,
    Set<int>? paidStepIndices,
    int? lastLevelPointsEarned,
    bool? earnedNoSupTechBonus,
  }) {
    return GameState(
      progress: progress ?? this.progress,
      currentWorld: currentWorld == _sentinel ? this.currentWorld : currentWorld as WorldDef?,
      currentLevel: currentLevel == _sentinel ? this.currentLevel : currentLevel as LevelDef?,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentBossHp: currentBossHp ?? this.currentBossHp,
      bossHpMultiplier: bossHpMultiplier ?? this.bossHpMultiplier,
      lastDrawnReward: lastDrawnReward == _sentinel ? this.lastDrawnReward : lastDrawnReward as RewardDef?,
      isBossMode: isBossMode ?? this.isBossMode,
      hintText: hintText == _sentinel ? this.hintText : hintText as String?,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
      currentBoss: currentBoss == _sentinel ? this.currentBoss : currentBoss as BossEncounterDef?,
      newlyUnlockedAchievements: newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      persistError: persistError ?? this.persistError,
      persistErrorCritical: persistErrorCritical ?? this.persistErrorCritical,
      paidStepIndices: paidStepIndices ?? this.paidStepIndices,
      lastLevelPointsEarned: lastLevelPointsEarned ?? this.lastLevelPointsEarned,
      earnedNoSupTechBonus: earnedNoSupTechBonus ?? this.earnedNoSupTechBonus,
    );
  }

  bool get canUseSupTech =>
      progress.supTechUsesThisLevel > 0 || progress.extraSupTechUses > 0;

  int get totalPoints =>
      progress.points;

  int get availableSupTechUses =>
      progress.supTechUsesThisLevel + progress.extraSupTechUses;
}

class GameCubit extends Cubit<GameState> {
  final GameRepository _repository;
  int _userId;

  GameCubit(this._repository, this._userId)
      : super(GameState(progress: PlayerProgress()..userId = _userId));

  Future<void> switchUser(int? userId) async {
    if (userId == null) {
      _userId = 0;
      emit(GameState(progress: PlayerProgress()..userId = 0));
      return;
    }
    _userId = userId;
    final progress = await _repository.getOrCreateProgress(userId);
    WorldDef? world;
    if (progress.currentCategoryId != null) {
      world = GameData.worlds.cast<WorldDef?>().firstWhere(
        (w) => w!.id == progress.currentCategoryId,
        orElse: () => GameData.worlds.isNotEmpty ? GameData.worlds.first : null,
      );
    } else if (progress.currentWorldId < GameData.worlds.length) {
      world = GameData.worlds[progress.currentWorldId];
    } else if (GameData.worlds.isNotEmpty) {
      world = GameData.worlds.first;
    }
    final pending = progress.pendingAchievementIds
        .map((id) => AchievementManager.all.firstWhere((a) => a.id == id))
        .toList();
    _safePersist([() => _repository.clearPendingAchievements(progress)]);
    emit(GameState(progress: progress, currentWorld: world, newlyUnlockedAchievements: pending));
  }

  Future<void> loadGame() async {
    final validUsers = await AuthService.getAllUsers();
    final validIds = validUsers.map((u) => u.id).toList();
    await _repository.cleanupOrphanedProgress(validIds);
    final progress = await _repository.getOrCreateProgress(_userId);
    WorldDef? world;
    if (progress.currentCategoryId != null) {
      world = GameData.worlds.cast<WorldDef?>().firstWhere(
        (w) => w!.id == progress.currentCategoryId,
        orElse: () => GameData.worlds.isNotEmpty ? GameData.worlds.first : null,
      );
    } else if (progress.currentWorldId < GameData.worlds.length) {
      world = GameData.worlds[progress.currentWorldId];
    } else if (GameData.worlds.isNotEmpty) {
      world = GameData.worlds.first;
    }
    final skinProgress = _checkAndUnlockProgressionSkins() ?? progress;
    final pending = skinProgress.pendingAchievementIds
        .map((id) => AchievementManager.all.firstWhere((a) => a.id == id))
        .toList();
    _safePersist([() => _repository.clearPendingAchievements(skinProgress)]);
    emit(GameState(progress: skinProgress, currentWorld: world, newlyUnlockedAchievements: pending));
  }

  void selectWorld(WorldDef world) {
    final progress = state.progress;
    _safePersist([() => _repository.setCurrentCategory(progress, world.id, null)]);
    emit(state.copyWith(progress: progress, currentWorld: world, bossHpMultiplier: 1));
  }

  void setBossMultiplier(int multiplier) {
    emit(state.copyWith(bossHpMultiplier: multiplier));
  }

  void setPointsMultiplier(int multiplier) {
    emit(state.copyWith(pointsMultiplier: multiplier));
  }

  void completeDailyQuest() {
    final progress = state.progress;
    final updated = progress.copyWith(lastDailyQuestDate: DateTime.now());
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  void completeWeeklyBoss() {
    final progress = state.progress;
    final updated = progress.copyWith(
      lastWeeklyBossDate: DateTime.now(),
      weeklyBossesDefeated: progress.weeklyBossesDefeated + 1,
    );
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  void selectLevel(LevelDef level, {WorldDef? worldOverride}) {
    final progress = state.progress;
    final world = worldOverride ?? state.currentWorld;
    final updated = progress.copyWith(currentLevelId: level.id);
    _safePersist([() => _repository.setCurrentCategory(updated, world?.id, level.id)]);
    emit(state.copyWith(
      progress: updated,
      currentWorld: world ?? state.currentWorld,
      currentLevel: level,
      currentStepIndex: 0,
      isBossMode: false,
      hintText: null,
      paidStepIndices: const {},
    ));
  }

  void _savePrepResultData(String levelId, String key, Map<String, dynamic> value) {
    final progress = state.progress;
    final raw = progress.getPrepResult(levelId);
    final data = raw != null
        ? json.decode(raw) as Map<String, dynamic>
        : <String, dynamic>{};
    data[key] = value;
    final encoded = json.encode(data);
    final newPrepResults = List<String>.from(progress.prepResults);
    const sep = '\x01';
    final keyPrefix = '$levelId$sep';
    newPrepResults.removeWhere((e) => e.startsWith(keyPrefix));
    newPrepResults.add('$keyPrefix$encoded');
    final updated = progress.copyWith(prepResults: newPrepResults);
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  void saveFeedback(String levelId, bool wasHelpful) {
    _savePrepResultData(levelId, 'feedback', {
      'helpful': wasHelpful,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void addChallengeBonus(int bonusPoints) {
    final progress = state.progress;
    _safePersist([() => _repository.addPoints(progress, bonusPoints)]);
    emit(state.copyWith(progress: progress));
  }

  void startBoss(BossEncounterDef boss) {
    emit(state.copyWith(
      isBossMode: true,
      currentBossHp: boss.hp * state.bossHpMultiplier,
      currentBoss: boss,
      hintText: null,
    ));
  }

  void solveStep() {
    if (state.currentLevel == null) return;
    final steps = state.currentLevel!.steps;
    final nextIndex = state.currentStepIndex + 1;
    final progress = state.progress;
    final paid = Set<int>.from(state.paidStepIndices);

    if (!paid.contains(state.currentStepIndex)) {
      _safePersist([() => _repository.addPoints(progress, 10)]);
      paid.add(state.currentStepIndex);
    }
    if (nextIndex >= steps.length) {
      _completeLevel(progress, nextIndex);
    } else {
      emit(state.copyWith(
        progress: progress,
        currentStepIndex: nextIndex,
        hintText: null,
        paidStepIndices: paid,
      ));
    }
  }

  void _safePersist(List<Future<void> Function()> ops, {bool isCritical = false}) {
    Future.wait(ops.map((op) => op()))
      .then((_) {
        if (!isClosed) emit(state.copyWith(persistError: false, persistErrorCritical: false));
      })
      .catchError((e, st) {
        debugPrint('Persist error: $e\n$st');
        if (!isClosed) emit(state.copyWith(persistError: true, persistErrorCritical: isCritical));
      });
  }

  void _completeLevel(PlayerProgress progress, int finalStepIndex) {
    final level = state.currentLevel!;
    final basePoints = level.points * state.pointsMultiplier;

    int bonusPoints = 0;
    final noSupTech = progress.supTechUsesThisLevel >= 1;
    if (noSupTech) {
      bonusPoints += 25;
    }
    // First attempt bonus — completed without retrying (linear game = always true)
    bonusPoints += 25;

    final totalPoints = basePoints + bonusPoints;
    final world = state.currentWorld;
    final completedWithCurrent = [...progress.completedLevelIds, level.id];
    final isWorldComplete = world != null && GameData.isWorldComplete(world, completedWithCurrent);

    final reward = _drawReward();
    final persistOps = <Future<void> Function()>[
      () => _repository.addPoints(progress, totalPoints),
      () => _repository.completeLevel(progress, level.id),
      () => _repository.resetLevelUses(progress),
      if (isWorldComplete) ...[
        () => _repository.completeCategory(progress, world.id),
      ],
      if (reward != null) () => _repository.addReward(progress, reward.id),
      if (reward?.type == RewardType.skin) () => _repository.unlockSkin(progress, reward!.value),
      if (reward?.type == RewardType.theme) () => _repository.setTheme(progress, reward!.value),
      () => _repository.recordPlayDate(progress),
    ];

    if (state.pointsMultiplier > 1) {
      final questProgress = progress.copyWith(lastDailyQuestDate: DateTime.now());
      persistOps.add(() => _repository.saveProgress(questProgress));
    }

    _safePersist(persistOps, isCritical: true);

    final afterSkins = _checkAndUnlockProgressionSkins() ?? progress;
    final newAchievements = _checkAchievements();

    emit(state.copyWith(
      progress: afterSkins,
      currentStepIndex: finalStepIndex,
      lastDrawnReward: reward,
      hintText: null,
      pointsMultiplier: 1,
      newlyUnlockedAchievements: newAchievements,
      paidStepIndices: const {},
      lastLevelPointsEarned: totalPoints,
      earnedNoSupTechBonus: noSupTech,
    ));
  }

  void attackBoss({int damage = 1}) {
    if (!state.isBossMode) return;
    final hpLeft = state.currentBossHp - damage;
    final progress = state.progress;

    _safePersist([() => _repository.addPoints(progress, 10)]);
    if (hpLeft <= 0) {
      _defeatBoss(progress);
    } else {
      emit(state.copyWith(progress: progress, currentBossHp: hpLeft));
    }
  }

  void _defeatBoss(PlayerProgress progress) {
    final boss = state.currentBoss;
    final bossPoints = boss?.points ?? state.currentWorld?.boss.points ?? 500;

    final reward = _drawReward();
    final persistOps = <Future<void> Function()>[
      () => _repository.addPoints(progress, bossPoints * state.pointsMultiplier),
      () => _repository.defeatBoss(progress, bossId: boss?.id),
      () => _repository.recordPlayDate(progress),
      if (boss?.id.startsWith('weekly_') == true)
        () => _repository.saveProgress(progress.copyWith(lastWeeklyBossDate: DateTime.now())),
      if (reward != null) () => _repository.addReward(progress, reward.id),
      if (reward?.type == RewardType.skin) () => _repository.unlockSkin(progress, reward!.value),
      if (reward?.type == RewardType.theme) () => _repository.setTheme(progress, reward!.value),
    ];

    _safePersist(persistOps, isCritical: true);

    final afterSkins = _checkAndUnlockProgressionSkins() ?? progress;
    final newAchievements = _checkAchievements();

    emit(state.copyWith(
      progress: afterSkins,
      currentBossHp: 0,
      lastDrawnReward: reward,
      pointsMultiplier: 1,
      newlyUnlockedAchievements: newAchievements,
    ));
  }

  void collectReward() {
    emit(state.copyWith(lastDrawnReward: null));
  }

  void useSupTech(String action) {
    final progress = state.progress;
    if (state.availableSupTechUses <= 0) return;

    final isBoss = state.isBossMode;

    switch (action) {
      case 'hint':
        if (isBoss) {
          final boss = state.currentBoss;
          _safePersist([() => _repository.useSupTech(progress)]);
          emit(state.copyWith(
            progress: progress,
            hintText: 'Watch ${boss?.name ?? 'the boss'}\'s behavior carefully — '
                'every attack pattern has a tell. Find the right counter and strike.',
          ));
        } else {
          final hints = GameData.levelHints[state.currentLevel?.id];
          if (hints != null && hints.isNotEmpty) {
            _safePersist([() => _repository.useSupTech(progress)]);
            emit(state.copyWith(
              progress: progress,
              hintText: hints[state.currentStepIndex % hints.length],
            ));
          }
        }
      case 'skip':
        if (isBoss || state.currentLevel == null) return;
        _safePersist([() => _repository.useSupTech(progress)]);
        solveStep();
      case 'diagnose':
        _safePersist([() => _repository.useSupTech(progress)]);
        final area = isBoss
            ? ' in this battle'
            : state.currentWorld != null
                ? ' in this ${state.currentWorld!.name} scenario'
                : '';
        emit(state.copyWith(
          progress: progress,
          hintText: 'Start by identifying what\'s working and what isn\'t$area. '
              'Check for error messages, unusual behavior, or missing output.',
        ));
      case 'explain':
        if (isBoss) {
          _safePersist([() => _repository.useSupTech(progress)]);
          emit(state.copyWith(
            progress: progress,
            hintText: state.currentBoss?.lore ?? 'Every boss has a weakness. Observe and adapt.',
          ));
        } else if (state.currentLevel != null &&
            state.currentStepIndex < state.currentLevel!.steps.length) {
          _safePersist([() => _repository.useSupTech(progress)]);
          emit(state.copyWith(
            progress: progress,
            hintText: state.currentLevel!.steps[state.currentStepIndex],
          ));
        }
    }
  }

  Future<void> refreshProgress() async {
    final p = await _repository.loadProgress(_userId);
    if (p != null && !isClosed) emit(state.copyWith(progress: p));
  }

  void addPoints(int amount) {
    final progress = state.progress;
    _safePersist([() => _repository.addPoints(progress, amount)]);
    emit(state.copyWith(progress: progress));
  }

  void saveQuizResult(String levelId, int correct, int total, int hearts) {
    _savePrepResultData(levelId, 'quiz', {
      'correct': correct,
      'total': total,
      'hearts': hearts,
    });
  }

  void saveOrderingResult(String levelId, int attempts, bool passed) {
    _savePrepResultData(levelId, 'ordering', {
      'attempts': attempts,
      'passed': passed,
    });
  }

  void saveTrapsResult(String levelId, int correct, int total, bool passed) {
    _savePrepResultData(levelId, 'traps', {
      'correct': correct,
      'total': total,
      'passed': passed,
    });
  }

  void saveScenariosResult(String levelId, int correct, int total, bool passed) {
    _savePrepResultData(levelId, 'scenarios', {
      'correct': correct,
      'total': total,
      'passed': passed,
    });
  }

  void saveMistakeResult(String levelId, bool passed) {
    _savePrepResultData(levelId, 'mistakes', {'passed': passed});
  }

  Future<void> setThemeId(String? themeId) async {
    final progress = state.progress;
    final updated = progress.copyWith(themeId: themeId);
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  RewardDef? _drawReward() {
    try {
      return RewardPool.draw();
    } catch (e, st) {
      debugPrint('Reward draw failed: $e\n$st');
      return null;
    }
  }

  PlayerProgress? _checkAndUnlockProgressionSkins() {
    final progress = state.progress;
    final newSkinIds = List<String>.from(progress.unlockedSkinIds);
    var changed = false;
    for (final skin in SkinTierManager.skins) {
      if (!skin.isRewardSkin &&
          progress.levelsCleared >= skin.levelsRequired &&
          !newSkinIds.contains(skin.id)) {
        newSkinIds.add(skin.id);
        changed = true;
      }
    }
    if (changed) {
      final updated = progress.copyWith(unlockedSkinIds: newSkinIds);
      _safePersist([() => _repository.saveProgress(updated)]);
      return updated;
    }
    return null;
  }

  String _extractCategoryId(String levelId) {
    for (final cat in CategoryManager.all) {
      if (levelId.startsWith('${cat.id}_')) return cat.id;
    }
    return levelId;
  }

  List<Achievement> _checkAchievements() {
    final progress = state.progress;
    final catsDone = progress.completedCategoryIds.length;

    final categoryLevelCounts = <String, int>{};
    for (final levelId in progress.completedLevelIds) {
      final catId = _extractCategoryId(levelId);
      categoryLevelCounts[catId] = (categoryLevelCounts[catId] ?? 0) + 1;
    }

    final newAchievements = AchievementManager.checkNew(
      levelsCleared: progress.levelsCleared,
      bossesDefeated: progress.bossesDefeated,
      points: progress.points,
      rewardsEarned: progress.earnedRewardIds.length,
      streak: StreakTracker.calculateStreak(progress.playDates),
      categoriesCompleted: catsDone,
      categoryLevelCounts: categoryLevelCounts,
      alreadyUnlockedIds: progress.unlockedAchievementIds,
    );
    for (final a in newAchievements) {
      _safePersist([() => _repository.unlockAchievement(progress, a.id)]);
      for (final reward in a.rewards) {
        _safePersist([() => _repository.unlockRewardFromAchievement(progress, reward.rewardId)]);
      }
    }
    return newAchievements;
  }

  Future<void> setActiveSkin(String? skinId) async {
    final progress = state.progress;
    if (skinId != null &&
        !progress.unlockedSkinIds.contains(skinId) &&
        !progress.earnedRewardIds.contains('skin_$skinId') &&
        !progress.purchasedItemIds.contains(skinId)) {
      return; // Can't equip locked skin
    }
    final updated = progress.copyWith(activeSkinId: skinId);
    _safePersist([() => _repository.setActiveSkin(updated, skinId)]);
    emit(state.copyWith(progress: updated));
  }

  Future<void> setActiveFrame(String? frameId) async {
    final progress = state.progress;
    if (frameId != null &&
        !progress.earnedRewardIds.contains(frameId) &&
        !progress.purchasedItemIds.contains(frameId)) {
      return; // Can't equip locked frame
    }
    final updated = progress.copyWith(activeFrameId: frameId);
    _safePersist([() => _repository.setActiveFrame(updated, frameId)]);
    emit(state.copyWith(progress: updated));
  }

  Future<void> setActiveIcon(String? iconId) async {
    final progress = state.progress;
    if (iconId != null && !progress.earnedRewardIds.contains(iconId)) {
      return; // Can't equip locked icon
    }
    final updated = progress.copyWith(activeIconId: iconId);
    _safePersist([() => _repository.setActiveIcon(updated, iconId)]);
    emit(state.copyWith(progress: updated));
  }

  Future<void> setActiveTitle(String? titleId) async {
    final progress = state.progress;
    if (titleId != null && !progress.earnedRewardIds.contains(titleId)) {
      return; // Can't equip locked title
    }
    final updated = progress.copyWith(activeTitleId: titleId);
    _safePersist([() => _repository.setActiveTitle(updated, titleId)]);
    emit(state.copyWith(progress: updated));
  }

  void purchaseItem(String itemId) {
    final progress = state.progress;
    if (progress.points < 1000) return;
    if (progress.purchasedItemIds.contains(itemId)) return;
    if (progress.earnedRewardIds.contains(itemId)) return;
    final updated = progress.copyWith(
      points: progress.points - 1000,
      purchasedItemIds: List<String>.from(progress.purchasedItemIds)..add(itemId),
    );
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  void selectWorldById(String worldId) {
    final world = GameData.worlds.cast<WorldDef?>().firstWhere(
      (w) => w!.id == worldId,
      orElse: () => null,
    );
    if (world != null) {
      selectWorld(world);
    }
  }

  void resetSteps() {
    emit(state.copyWith(currentStepIndex: 0, hintText: null));
  }

  Future<void> unlockEverything() async {
    if (!kDebugMode) return;
    final progress = await _repository.createTestProgress(_userId);
    emit(GameState(progress: progress, currentWorld: state.currentWorld));
  }

  Future<void> terminateAccount() async {
    await _repository.deleteProgress(_userId);
    emit(GameState(progress: PlayerProgress()..userId = _userId));
  }
}
