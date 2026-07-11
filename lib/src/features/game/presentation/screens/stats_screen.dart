import 'package:flutter/material.dart';
import 'package:littletech/src/core/constants/design_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:littletech/src/core/constants/category_manager.dart';
import 'package:littletech/src/features/game/constants/game_data.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/constants/skin_tiers.dart';
import 'package:littletech/src/features/game/constants/streak_tracker.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';
import 'package:littletech/src/features/game/presentation/widgets/framed_username.dart';
import 'package:littletech/src/features/game/presentation/widgets/sup_tech_avatar_wrapper.dart';
import 'package:littletech/src/features/game/presentation/widgets/suptech_avatar.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Stats'),
        backgroundColor: Colors.transparent,
      ),
      body: Builder(
        builder: (context) {
          final authState = context.watch<AuthCubit>().state;
          final user = (authState is LoginSuccess)
              ? authState.user
              : (authState is RegisterSuccess)
                  ? authState.user
                  : null;
          return BlocBuilder<GameCubit, GameState>(
            builder: (_, state) {
              final p = state.progress;
              final earnedRewards = p.earnedRewardIds
                  .map((id) => RewardPool.byId(id))
                  .whereType<RewardDef>()
                  .length;
              final totalLevels =
                  GameData.worlds.fold(0, (s, w) => s + w.levels.length);
              final worldsCompleted = p.completedCategoryIds.length;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          scheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Radii.xxl),
                    ),
                    child: Column(
                      children: [
                        SupTechAvatarWrapper(
                          size: 56,
                          child: SupTechAvatar(
                            size: 56,
                            skinId: state.progress.activeSkinId,
                          ),
                        ),
                        const Gap(Spacing.ms),
                        FramedUsername(
                          username: user?.username ?? 'Player',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Gap(Spacing.lg),
                  Row(
                    children: [
                      _StatSquare(
                          icon: Icons.checklist,
                          label: 'Levels',
                          value: '${p.levelsCleared}/$totalLevels',
                          scheme: scheme),
                      const Gap(Spacing.ms),
                      _StatSquare(
                          icon: Icons.shield,
                          label: 'Bosses',
                          value: '${p.bossesDefeated}',
                          scheme: scheme),
                      const Gap(Spacing.ms),
                      _StatSquare(
                          icon: Icons.public,
                          label: 'Categories',
                          value:
                              '$worldsCompleted/${CategoryManager.all.length}',
                          scheme: scheme),
                    ],
                  ),
                  const Gap(Spacing.ms),
                  Row(
                    children: [
                      _StatSquare(
                          icon: Icons.monetization_on,
                          label: 'Points',
                          value: '${p.points}',
                          scheme: scheme),
                      const Gap(Spacing.ms),
                      _StatSquare(
                          icon: Icons.card_giftcard,
                          label: 'Rewards',
                          value: '$earnedRewards',
                          scheme: scheme),
                      const Gap(Spacing.ms),
                      _StatSquare(
                          icon: Icons.auto_awesome,
                          label: 'Skins',
                          value:
                              '${SkinTierManager.skins.where((s) => p.unlockedSkinIds.contains(s.id) || p.earnedRewardIds.contains('skin_${s.id}') || p.purchasedItemIds.contains(s.id)).length}',
                          scheme: scheme),
                    ],
                  ),
                  const Gap(Spacing.ms),
                  Row(
                    children: [
                      _StatSquare(
                        icon: Icons.speed,
                        label: 'Accuracy',
                        value: p.totalAnswers > 0
                            ? '${(p.correctAnswers * 100 / p.totalAnswers).round()}%'
                            : '—',
                        scheme: scheme,
                      ),
                      const Gap(Spacing.ms),
                      _StatSquare(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value:
                            '${StreakTracker.calculateStreak(p.playDates)} days',
                        scheme: scheme,
                      ),
                      const Gap(Spacing.ms),
                      _StatSquare(
                        icon: Icons.timer,
                        label: 'Play Time',
                        value: p.totalPlayTimeSeconds > 3600
                            ? '${(p.totalPlayTimeSeconds / 3600).round()}h'
                            : '${(p.totalPlayTimeSeconds / 60).round()}m',
                        scheme: scheme,
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  const _StatSquare({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.secondary, size: 22),
            const Gap(Spacing.sm),
            Text(
              value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
