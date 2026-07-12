import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:littletech/src/features/auth/data/services/auth_service.dart';
import 'package:littletech/src/features/game/constants/achievements.dart';
import 'package:littletech/src/features/game/constants/game_data.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/constants/game_constants.dart';
import 'package:littletech/src/features/game/constants/skin_tiers.dart';
import 'package:littletech/src/features/game/data/models/player_progress.dart';
import 'package:littletech/src/features/game/data/repositories/game_repository.dart';
import 'package:littletech/src/features/game/constants/streak_tracker.dart';
import 'package:littletech/src/core/constants/category_manager.dart';

enum SupTechContext { problem, quiz, ordering, scenario, traps, mistake, boss }

class GameState with Equatable {
  final PlayerProgress progress;
  final WorldDef? currentWorld;
  final LevelDef? currentLevel;
  final int currentStepIndex;
  final int currentBossHp;
  final int bossHpMultiplier;
  final RewardDef? lastDrawnReward;
  final SupTechContext supTechContext;
  final String? hintText;
  final int pointsMultiplier;
  final BossEncounterDef? currentBoss;
  final List<Achievement> newlyUnlockedAchievements;
  final bool persistError;
  final bool persistErrorCritical;
  final Set<int> paidStepIndices;
  final int lastLevelPointsEarned;
  final bool earnedNoSupTechBonus;
  final Map<String, Set<String>> usedSupTechActions;

  @override
  List<Object?> get props => [
        progress,
        currentWorld,
        currentLevel,
        currentStepIndex,
        currentBossHp,
        bossHpMultiplier,
        lastDrawnReward,
        supTechContext,
        hintText,
        pointsMultiplier,
        currentBoss,
        newlyUnlockedAchievements,
        persistError,
        persistErrorCritical,
        paidStepIndices,
        lastLevelPointsEarned,
        earnedNoSupTechBonus,
        usedSupTechActions,
      ];

  const GameState({
    required this.progress,
    this.currentWorld,
    this.currentLevel,
    this.currentStepIndex = 0,
    this.currentBossHp = 0,
    this.bossHpMultiplier = 1,
    this.lastDrawnReward,
    this.supTechContext = SupTechContext.problem,
    this.hintText,
    this.pointsMultiplier = 1,
    this.currentBoss,
    this.newlyUnlockedAchievements = const [],
    this.persistError = false,
    this.persistErrorCritical = false,
    this.paidStepIndices = const {},
    this.lastLevelPointsEarned = 0,
    this.earnedNoSupTechBonus = false,
    this.usedSupTechActions = const {},
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
    SupTechContext? supTechContext,
    Object? hintText = _sentinel,
    int? pointsMultiplier,
    Object? currentBoss = _sentinel,
    List<Achievement>? newlyUnlockedAchievements,
    bool? persistError,
    bool? persistErrorCritical,
    Set<int>? paidStepIndices,
    int? lastLevelPointsEarned,
    bool? earnedNoSupTechBonus,
    Map<String, Set<String>>? usedSupTechActions,
  }) {
    return GameState(
      progress: progress ?? this.progress,
      currentWorld: currentWorld == _sentinel
          ? this.currentWorld
          : currentWorld as WorldDef?,
      currentLevel: currentLevel == _sentinel
          ? this.currentLevel
          : currentLevel as LevelDef?,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      currentBossHp: currentBossHp ?? this.currentBossHp,
      bossHpMultiplier: bossHpMultiplier ?? this.bossHpMultiplier,
      lastDrawnReward: lastDrawnReward == _sentinel
          ? this.lastDrawnReward
          : lastDrawnReward as RewardDef?,
      supTechContext: supTechContext ?? this.supTechContext,
      hintText: hintText == _sentinel ? this.hintText : hintText as String?,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
      currentBoss: currentBoss == _sentinel
          ? this.currentBoss
          : currentBoss as BossEncounterDef?,
      newlyUnlockedAchievements:
          newlyUnlockedAchievements ?? this.newlyUnlockedAchievements,
      persistError: persistError ?? this.persistError,
      persistErrorCritical: persistErrorCritical ?? this.persistErrorCritical,
      paidStepIndices: paidStepIndices ?? this.paidStepIndices,
      lastLevelPointsEarned:
          lastLevelPointsEarned ?? this.lastLevelPointsEarned,
      earnedNoSupTechBonus: earnedNoSupTechBonus ?? this.earnedNoSupTechBonus,
      usedSupTechActions: usedSupTechActions ?? this.usedSupTechActions,
    );
  }

  static String questionKey({
    required SupTechContext context,
    String? levelId,
    int stepIndex = 0,
    String? bossId,
    int itemIndex = 0,
  }) {
    switch (context) {
      case SupTechContext.problem:
        return '${levelId}_step$stepIndex';
      case SupTechContext.boss:
        return 'boss_$bossId';
      case SupTechContext.quiz:
        return '${levelId}_q$itemIndex';
      case SupTechContext.ordering:
        return '$levelId';
      case SupTechContext.scenario:
        return '${levelId}_s$itemIndex';
      case SupTechContext.traps:
        return '${levelId}_t$itemIndex';
      case SupTechContext.mistake:
        return '$levelId';
    }
  }

  bool get canUseSupTech =>
      progress.supTechUsesThisLevel > 0 || progress.extraSupTechUses > 0;

  int get totalPoints => progress.points;

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
            orElse: () =>
                GameData.worlds.isNotEmpty ? GameData.worlds.first : null,
          );
    } else if (progress.currentWorldId < GameData.worlds.length) {
      world = GameData.worlds[progress.currentWorldId];
    } else if (GameData.worlds.isNotEmpty) {
      world = GameData.worlds.first;
    }
    final pending = progress.pendingAchievementIds
        .map((id) => AchievementManager.all
            .cast<Achievement?>()
            .firstWhere((a) => a!.id == id, orElse: () => null))
        .whereType<Achievement>()
        .toList();
    _safePersist([() => _repository.clearPendingAchievements(progress)]);
    emit(GameState(
        progress: progress,
        currentWorld: world,
        newlyUnlockedAchievements: pending));
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
            orElse: () =>
                GameData.worlds.isNotEmpty ? GameData.worlds.first : null,
          );
    } else if (progress.currentWorldId < GameData.worlds.length) {
      world = GameData.worlds[progress.currentWorldId];
    } else if (GameData.worlds.isNotEmpty) {
      world = GameData.worlds.first;
    }
    final skinProgress = _checkAndUnlockProgressionSkins() ?? progress;
    final pending = skinProgress.pendingAchievementIds
        .map((id) => AchievementManager.all
            .cast<Achievement?>()
            .firstWhere((a) => a!.id == id, orElse: () => null))
        .whereType<Achievement>()
        .toList();
    _safePersist([() => _repository.clearPendingAchievements(skinProgress)]);
    emit(GameState(
        progress: skinProgress,
        currentWorld: world,
        newlyUnlockedAchievements: pending));
  }

  void selectWorld(WorldDef world) {
    final progress = state.progress;
    _safePersist(
        [() => _repository.setCurrentCategory(progress, world.id, null)]);
    emit(state.copyWith(
        progress: progress, currentWorld: world, bossHpMultiplier: 1));
  }

  void setBossMultiplier(int multiplier) {
    emit(state.copyWith(bossHpMultiplier: multiplier));
  }

  void setPointsMultiplier(int multiplier) {
    emit(state.copyWith(pointsMultiplier: multiplier));
  }

  void setSupTechContext(SupTechContext context) {
    emit(state.copyWith(supTechContext: context));
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
    _safePersist(
        [() => _repository.setCurrentCategory(updated, world?.id, level.id)]);
    emit(state.copyWith(
      progress: updated,
      currentWorld: world ?? state.currentWorld,
      currentLevel: level,
      currentStepIndex: 0,
      supTechContext: SupTechContext.problem,
      hintText: null,
      paidStepIndices: const {},
      usedSupTechActions: const {},
    ));
  }

  void _savePrepResultData(
      String levelId, String key, Map<String, dynamic> value) {
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
    final updated = progress.copyWith(points: progress.points + bonusPoints);
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
  }

  void startBoss(BossEncounterDef boss) {
    emit(state.copyWith(
      supTechContext: SupTechContext.boss,
      currentBossHp: boss.hp * state.bossHpMultiplier,
      currentBoss: boss,
      hintText: null,
      usedSupTechActions: const {},
    ));
  }

  void solveStep() {
    if (state.currentLevel == null) return;
    final steps = state.currentLevel!.steps;
    final nextIndex = state.currentStepIndex + 1;
    final progress = state.progress;
    final paid = Set<int>.from(state.paidStepIndices);

    if (!paid.contains(state.currentStepIndex)) {
      _safePersist(
          [() => _repository.addPoints(progress, GameConstants.stepPoints)]);
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

  void _safePersist(List<Future<void> Function()> ops,
      {bool isCritical = false}) {
    Future.wait(ops.map((op) => op())).then((_) {
      if (!isClosed) {
        emit(state.copyWith(persistError: false, persistErrorCritical: false));
      }
    }).catchError((e, st) {
      debugPrint('Persist error: $e\n$st');
      if (!isClosed) {
        emit(state.copyWith(
            persistError: true, persistErrorCritical: isCritical));
      }
    });
  }

  void _completeLevel(PlayerProgress progress, int finalStepIndex) {
    final level = state.currentLevel!;
    final basePoints = level.points * state.pointsMultiplier;

    int bonusPoints = 0;
    final noSupTech = progress.supTechUsesThisLevel >= 1;
    if (noSupTech) {
      bonusPoints += GameConstants.noSupTechBonus;
    }
    bonusPoints += GameConstants.firstAttemptBonus;

    final totalPoints = basePoints + bonusPoints;
    final world = state.currentWorld;
    final completedWithCurrent = [...progress.completedLevelIds, level.id];
    final isWorldComplete =
        world != null && GameData.isWorldComplete(world, completedWithCurrent);

    progress.points += totalPoints;
    if (!progress.completedLevelIds.contains(level.id)) {
      progress.completedLevelIds.add(level.id);
      progress.levelsCleared++;
    }
    progress.supTechUsesThisLevel = 1 + progress.extraSupTechUses;
    if (isWorldComplete && !progress.completedCategoryIds.contains(world.id)) {
      progress.completedCategoryIds.add(world.id);
    }

    final reward = _drawReward();
    if (reward != null && !progress.earnedRewardIds.contains(reward.id)) {
      progress.earnedRewardIds.add(reward.id);
      if (reward.type == RewardType.skin &&
          !progress.unlockedSkinIds.contains(reward.value)) {
        progress.unlockedSkinIds.add(reward.value);
      }
      if (reward.type == RewardType.theme) {
        progress.themeId = reward.value;
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!progress.playDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day)) {
      progress.playDates.add(today);
    }
    progress.lastActiveDate = now;
    if (state.pointsMultiplier > 1) {
      progress.lastDailyQuestDate = now;
    }

    _safePersist([() => _repository.saveBatch(progress)], isCritical: true);

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
    if (state.supTechContext != SupTechContext.boss) return;
    final hpLeft = state.currentBossHp - damage;
    final progress = state.progress;

    _safePersist([
      () => _repository.addPoints(progress, GameConstants.bossAttackPoints)
    ]);
    if (hpLeft <= 0) {
      _defeatBoss(progress);
    } else {
      emit(state.copyWith(progress: progress, currentBossHp: hpLeft));
    }
  }

  void _defeatBoss(PlayerProgress progress) {
    final boss = state.currentBoss;
    final bossPoints = boss?.points ??
        state.currentWorld?.boss.points ??
        GameConstants.fallbackBossPoints;

    progress.points += bossPoints * state.pointsMultiplier;
    progress.bossesDefeated++;
    progress.extraSupTechUses++;
    if (boss?.id != null && !progress.defeatedBossIds.contains(boss!.id)) {
      progress.defeatedBossIds.add(boss.id);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (!progress.playDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day)) {
      progress.playDates.add(today);
    }
    progress.lastActiveDate = now;
    if (boss?.id.startsWith('weekly_') == true) {
      progress.lastWeeklyBossDate = DateTime.now();
    }

    final reward = _drawReward();
    if (reward != null && !progress.earnedRewardIds.contains(reward.id)) {
      progress.earnedRewardIds.add(reward.id);
      if (reward.type == RewardType.skin &&
          !progress.unlockedSkinIds.contains(reward.value)) {
        progress.unlockedSkinIds.add(reward.value);
      }
      if (reward.type == RewardType.theme) {
        progress.themeId = reward.value;
      }
    }

    _safePersist([() => _repository.saveBatch(progress)], isCritical: true);

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

  String _questionKey({int itemIndex = 0}) {
    final s = state;
    return GameState.questionKey(
      context: s.supTechContext,
      levelId: s.currentLevel?.id,
      stepIndex: s.currentStepIndex,
      bossId: s.currentBoss?.id,
      itemIndex: itemIndex,
    );
  }

  String? _hintTextFor(String action) {
    final s = state;
    switch (action) {
      case 'hint':
        if (s.supTechContext == SupTechContext.boss) {
          final boss = s.currentBoss;
          return 'Watch ${boss?.name ?? 'the boss'}\'s behavior carefully — '
              'every attack pattern has a tell. Find the right counter and strike.';
        }
        final hints = GameData.levelHints[s.currentLevel?.id];
        if (hints != null && hints.isNotEmpty) {
          return hints[s.currentStepIndex % hints.length];
        }
        return null;
      case 'diagnose':
        final area = s.supTechContext == SupTechContext.boss
            ? ' in this battle'
            : s.currentWorld != null
                ? ' in this ${s.currentWorld!.name} scenario'
                : '';
        return 'Start by identifying what\'s working and what isn\'t$area. '
            'Check for error messages, unusual behavior, or missing output.';
      case 'explain':
        if (s.supTechContext == SupTechContext.boss) {
          return s.currentBoss?.lore ??
              'Every boss has a weakness. Observe and adapt.';
        }
        if (s.currentLevel != null &&
            s.currentStepIndex < s.currentLevel!.steps.length) {
          return s.currentLevel!.steps[s.currentStepIndex];
        }
        return null;
    }
    return null;
  }

  void useSupTech(String action, {int questionIndex = 0}) {
    final progress = state.progress;
    final questionKey = _questionKey(itemIndex: questionIndex);

    final alreadyUsed =
        state.usedSupTechActions[questionKey]?.contains(action) ?? false;

    if (alreadyUsed) {
      final hintText = _hintTextFor(action);
      if (hintText != null) {
        emit(state.copyWith(hintText: hintText));
      }
      return;
    }

    if (state.availableSupTechUses <= 0) return;

    final used = Map<String, Set<String>>.from(state.usedSupTechActions);
    used.update(questionKey, (set) => Set<String>.from(set)..add(action),
        ifAbsent: () => {action});

    final hintText = _hintTextFor(action);

    if (action == 'skip') {
      if (state.supTechContext == SupTechContext.boss ||
          state.currentLevel == null) {
        return;
      }
      _safePersist([() => _repository.useSupTech(progress)]);
      emit(state.copyWith(
        progress: progress,
        usedSupTechActions: used,
      ));
      solveStep();
    } else {
      if (hintText == null) return;
      _safePersist([() => _repository.useSupTech(progress)]);
      emit(state.copyWith(
        progress: progress,
        hintText: hintText,
        usedSupTechActions: used,
      ));
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

  void saveScenariosResult(
      String levelId, int correct, int total, bool passed) {
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
        _safePersist([
          () =>
              _repository.unlockRewardFromAchievement(progress, reward.rewardId)
        ]);
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

  bool purchaseItem(String itemId) {
    final progress = state.progress;
    if (progress.points < GameConstants.itemPurchaseCost) return false;
    if (progress.purchasedItemIds.contains(itemId)) return true;
    if (progress.earnedRewardIds.contains(itemId)) return true;
    final updated = progress.copyWith(
      points: progress.points - GameConstants.itemPurchaseCost,
      purchasedItemIds: List<String>.from(progress.purchasedItemIds)
        ..add(itemId),
    );
    _safePersist([() => _repository.saveProgress(updated)]);
    emit(state.copyWith(progress: updated));
    return true;
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
