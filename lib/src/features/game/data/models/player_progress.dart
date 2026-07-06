import 'package:isar/isar.dart';

part 'player_progress.g.dart';

@collection
class PlayerProgress {
  Id id = Isar.autoIncrement;

  @Index()
  late int userId;

int points = 0;
   int supTechUsesThisLevel = 1;
   int extraSupTechUses = 0;
   int currentWorldId = 0;
   String? currentCategoryId;
   String? currentLevelId;
   List<String> completedLevelIds = [];
   List<String> completedCategoryIds = [];
   List<String> purchasedItemIds = [];
   List<String> earnedRewardIds = [];
   List<String> unlockedSkinIds = [];
   List<String> defeatedBossIds = [];
   String? activeSkinId;  // Currently equipped skin
   String? activeFrameId; // Currently equipped nickname frame
   String? activeIconId;  // Currently equipped icon badge
   String? activeTitleId; // Currently equipped title
   String? themeId;
   int levelsCleared = 0;
   int bossesDefeated = 0;
   List<DateTime> playDates = [];
   DateTime? lastActiveDate;
   int totalPlayTimeSeconds = 0;
    int correctAnswers = 0;
    int totalAnswers = 0;
    int weeklyBossesDefeated = 0;
    List<String> prepResults = [];  // "levelId\x01json" entries
     DateTime? lastDailyQuestDate;  // Track daily quest completion
     DateTime? lastWeeklyBossDate;  // Track weekly boss completion
     List<String> unlockedAchievementIds = [];  // Persisted achievement unlocks
    List<String> pendingAchievementIds = [];   // Temporary: newly unlocked, shown on Level Complete

  static const _sentinel = Object();
  static const _sep = '\x01';

  PlayerProgress copyWith({
    int? userId,
    int? points,
    int? supTechUsesThisLevel,
    int? extraSupTechUses,
    int? currentWorldId,
    Object? currentCategoryId = _sentinel,
    Object? currentLevelId = _sentinel,
    List<String>? completedLevelIds,
    List<String>? completedCategoryIds,
    List<String>? purchasedItemIds,
    List<String>? earnedRewardIds,
    List<String>? unlockedSkinIds,
    List<String>? defeatedBossIds,
    Object? activeSkinId = _sentinel,
    Object? activeFrameId = _sentinel,
    Object? activeIconId = _sentinel,
    Object? activeTitleId = _sentinel,
    Object? themeId = _sentinel,
    int? levelsCleared,
    int? bossesDefeated,
    List<DateTime>? playDates,
    Object? lastActiveDate = _sentinel,
    int? totalPlayTimeSeconds,
    int? correctAnswers,
    int? totalAnswers,
    int? weeklyBossesDefeated,
    List<String>? prepResults,
    Object? lastDailyQuestDate = _sentinel,
    Object? lastWeeklyBossDate = _sentinel,
    List<String>? unlockedAchievementIds,
    List<String>? pendingAchievementIds,
  }) {
    return PlayerProgress()
      ..id = id
      ..userId = userId ?? this.userId
      ..points = points ?? this.points
      ..supTechUsesThisLevel = supTechUsesThisLevel ?? this.supTechUsesThisLevel
      ..extraSupTechUses = extraSupTechUses ?? this.extraSupTechUses
      ..currentWorldId = currentWorldId ?? this.currentWorldId
      ..currentCategoryId = currentCategoryId == _sentinel ? this.currentCategoryId : currentCategoryId as String?
      ..currentLevelId = currentLevelId == _sentinel ? this.currentLevelId : currentLevelId as String?
      ..completedLevelIds = List<String>.from(completedLevelIds ?? this.completedLevelIds)
      ..completedCategoryIds = List<String>.from(completedCategoryIds ?? this.completedCategoryIds)
      ..purchasedItemIds = List<String>.from(purchasedItemIds ?? this.purchasedItemIds)
      ..earnedRewardIds = List<String>.from(earnedRewardIds ?? this.earnedRewardIds)
      ..unlockedSkinIds = List<String>.from(unlockedSkinIds ?? this.unlockedSkinIds)
      ..defeatedBossIds = List<String>.from(defeatedBossIds ?? this.defeatedBossIds)
      ..activeSkinId = activeSkinId == _sentinel ? this.activeSkinId : activeSkinId as String?
      ..activeFrameId = activeFrameId == _sentinel ? this.activeFrameId : activeFrameId as String?
      ..activeIconId = activeIconId == _sentinel ? this.activeIconId : activeIconId as String?
      ..activeTitleId = activeTitleId == _sentinel ? this.activeTitleId : activeTitleId as String?
      ..themeId = themeId == _sentinel ? this.themeId : themeId as String?
      ..levelsCleared = levelsCleared ?? this.levelsCleared
      ..bossesDefeated = bossesDefeated ?? this.bossesDefeated
      ..playDates = List<DateTime>.from(playDates ?? this.playDates)
      ..lastActiveDate = lastActiveDate == _sentinel ? this.lastActiveDate : lastActiveDate as DateTime?
      ..totalPlayTimeSeconds = totalPlayTimeSeconds ?? this.totalPlayTimeSeconds
      ..correctAnswers = correctAnswers ?? this.correctAnswers
      ..totalAnswers = totalAnswers ?? this.totalAnswers
      ..weeklyBossesDefeated = weeklyBossesDefeated ?? this.weeklyBossesDefeated
      ..prepResults = List<String>.from(prepResults ?? this.prepResults)
      ..lastDailyQuestDate = lastDailyQuestDate == _sentinel ? this.lastDailyQuestDate : lastDailyQuestDate as DateTime?
      ..lastWeeklyBossDate = lastWeeklyBossDate == _sentinel ? this.lastWeeklyBossDate : lastWeeklyBossDate as DateTime?
      ..unlockedAchievementIds = List<String>.from(unlockedAchievementIds ?? this.unlockedAchievementIds)
      ..pendingAchievementIds = List<String>.from(pendingAchievementIds ?? this.pendingAchievementIds);
  }

  String? getPrepResult(String levelId) {
    for (final e in prepResults) {
      final idx = e.indexOf(_sep);
      if (idx >= 0 && e.substring(0, idx) == levelId) return e.substring(idx + 1);
    }
    return null;
  }

  void setPrepResult(String levelId, String json) {
    final key = '$levelId$_sep';
    prepResults.removeWhere((e) => e.startsWith(key));
    prepResults.add('$key$json');
  }

  /// Call after loading from Isar to ensure all lists are growable.
  void ensureMutableLists() {
    completedLevelIds = List<String>.from(completedLevelIds);
    completedCategoryIds = List<String>.from(completedCategoryIds);
    earnedRewardIds = List<String>.from(earnedRewardIds);
    unlockedSkinIds = List<String>.from(unlockedSkinIds);
    defeatedBossIds = List<String>.from(defeatedBossIds);
    playDates = List<DateTime>.from(playDates);
    prepResults = List<String>.from(prepResults);
    purchasedItemIds = List<String>.from(purchasedItemIds);
    unlockedAchievementIds = List<String>.from(unlockedAchievementIds);
    pendingAchievementIds = List<String>.from(pendingAchievementIds);
  }

  bool getDailyQuestCompleted() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return lastDailyQuestDate != null &&
        lastDailyQuestDate!.year == todayDate.year &&
        lastDailyQuestDate!.month == todayDate.month &&
        lastDailyQuestDate!.day == todayDate.day;
  }

  void setDailyQuestCompleted() {
    lastDailyQuestDate = DateTime.now();
  }

  bool getWeeklyBossCompleted() {
    if (lastWeeklyBossDate == null) return false;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd = weekStart.add(const Duration(days: 7));
    return lastWeeklyBossDate!.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
        lastWeeklyBossDate!.isBefore(weekEnd);
  }

  void setWeeklyBossCompleted() {
    lastWeeklyBossDate = DateTime.now();
  }
}
