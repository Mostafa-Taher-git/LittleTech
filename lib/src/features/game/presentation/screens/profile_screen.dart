import 'package:flutter/material.dart';
import 'package:littletech/src/core/constants/design_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/constants/streak_tracker.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';
import 'package:littletech/src/features/game/domain/cubit/theme_cubit.dart';
import 'package:littletech/src/features/game/presentation/widgets/suptech_avatar.dart';
import 'package:littletech/src/features/game/presentation/widgets/sup_tech_avatar_wrapper.dart';
import 'package:littletech/src/features/game/presentation/widgets/framed_username.dart';
import 'package:littletech/src/core/navigation/nav.dart';
import 'package:littletech/src/features/game/presentation/screens/achievements_screen.dart';
import 'package:littletech/src/features/game/presentation/screens/challenge_screen.dart';
import 'package:littletech/src/features/game/presentation/screens/stats_screen.dart';
import 'package:littletech/src/features/game/presentation/screens/sup_tech_page.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
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
              final progress = state.progress;
              final earnedRewards = progress.earnedRewardIds
                  .map((id) => RewardPool.byId(id))
                  .whereType<RewardDef>()
                  .toList();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
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
                            size: 64,
                            child: SupTechAvatar(
                              size: 64,
                              skinId: progress.activeSkinId,
                            ),
                          ),
                          const Gap(Spacing.ms),
                          FramedUsername(
                            username: user?.username ?? 'Player',
                            fontSize: 22,
                            textAlign: TextAlign.center,
                          ),
                          const Gap(Spacing.xs),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on,
                                      color: scheme.secondary, size: 18),
                                  const Gap(Spacing.xs),
                                  Text(
                                    '${progress.points} points',
                                    style: TextStyle(
                                      color: scheme.secondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      color: Colors.orange, size: 18),
                                  const Gap(Spacing.xs),
                                  Text(
                                    '${StreakTracker.calculateStreak(progress.playDates)} day streak',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Gap(Spacing.ms),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SupTechPage(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: scheme.onPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ST',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: scheme.onPrimary,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const Gap(Spacing.s),
                                  Text(
                                    'SupTech page',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: scheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(Spacing.lg),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.emoji_events,
                          label: 'Levels',
                          value: '${progress.levelsCleared}',
                          scheme: scheme,
                        ),
                        const Gap(Spacing.m),
                        _StatCard(
                          icon: Icons.warning,
                          label: 'Bosses',
                          value: '${progress.bossesDefeated}',
                          scheme: scheme,
                        ),
                        const Gap(Spacing.m),
                        _StatCard(
                          icon: Icons.redeem,
                          label: 'Rewards',
                          value: '${earnedRewards.length}',
                          scheme: scheme,
                        ),
                      ],
                    ),
                    const Gap(Spacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileAction(
                            icon: Icons.emoji_events,
                            label: 'Honors & Badges',
                            onTap: () =>
                                Nav.push(context, const AchievementsScreen()),
                            scheme: scheme,
                          ),
                        ),
                        const Gap(Spacing.m),
                        Expanded(
                          child: _ProfileAction(
                            icon: Icons.bar_chart,
                            label: 'Stats',
                            onTap: () => Nav.push(context, const StatsScreen()),
                            scheme: scheme,
                          ),
                        ),
                        const Gap(Spacing.m),
                        Expanded(
                          child: _ProfileAction(
                            icon: Icons.wb_sunny,
                            label: 'Quests',
                            onTap: () =>
                                Nav.push(context, const ChallengeScreen()),
                            scheme: scheme,
                          ),
                        ),
                      ],
                    ),
                    const Gap(Spacing.xl),
                    Text(
                      'Themes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(Spacing.xl),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _themes.map((t) {
                        final isDefault = t.id == 'default';
                        final rewardId = 'theme_${t.id}';
                        final unlocked = isDefault ||
                            progress.purchasedItemIds.contains(rewardId) ||
                            progress.earnedRewardIds.contains(rewardId);
                        final isActive = isDefault
                            ? (progress.themeId == null ||
                                progress.themeId == 'default')
                            : progress.themeId == t.id;
                        return _ThemeChip(
                          label: t.label,
                          icon: t.icon,
                          isActive: isActive,
                          unlocked: unlocked,
                          onUnlockTap: isDefault
                              ? null
                              : () {
                                  final success = context
                                      .read<GameCubit>()
                                      .purchaseItem(rewardId);
                                  if (success) {
                                    _applyTheme(context, t.id);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Not enough points! Need 1000 pts.'),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                          onTap: () => _applyTheme(context, t.id),
                          scheme: scheme,
                        );
                      }).toList(),
                    ),
                    const Gap(Spacing.xl),
                    Text(
                      'Frames',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(Spacing.ms),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RewardPool.all
                          .where((r) => r.type == RewardType.nicknameFrame)
                          .map((frame) {
                        final earned =
                            progress.earnedRewardIds.contains(frame.id);
                        final purchased =
                            progress.purchasedItemIds.contains(frame.id);
                        final unlocked = earned || purchased;
                        final isActive = progress.activeFrameId == frame.id;
                        return GestureDetector(
                          onTap: unlocked
                              ? () => context
                                  .read<GameCubit>()
                                  .setActiveFrame(isActive ? null : frame.id)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? frame.color.withValues(alpha: 0.2)
                                  : unlocked
                                      ? frame.color.withValues(alpha: 0.1)
                                      : scheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(
                                color: isActive
                                    ? frame.color
                                    : unlocked
                                        ? frame.color.withValues(alpha: 0.3)
                                        : scheme.outline.withValues(alpha: 0.1),
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(frame.icon,
                                    color: unlocked
                                        ? frame.color
                                        : scheme.onSurface
                                            .withValues(alpha: 0.3),
                                    size: 18),
                                const Gap(Spacing.sm),
                                Text(
                                  unlocked
                                      ? frame.displayName
                                      : '${frame.displayName} · 1000 pts',
                                  style: TextStyle(
                                    color: unlocked
                                        ? frame.color
                                        : scheme.onSurface
                                            .withValues(alpha: 0.3),
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isActive) ...[
                                  const Gap(Spacing.s),
                                  Icon(Icons.check_circle,
                                      color: frame.color, size: 16),
                                ] else if (!unlocked) ...[
                                  const Gap(Spacing.s),
                                  GestureDetector(
                                    onTap: () {
                                      final success = context
                                          .read<GameCubit>()
                                          .purchaseItem(frame.id);
                                      if (success) {
                                        context
                                            .read<GameCubit>()
                                            .setActiveFrame(frame.id);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Not enough points! Need 1000 pts.'),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: scheme.secondary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(Radii.s),
                                      ),
                                      child: Text(
                                        'Buy',
                                        style: TextStyle(
                                            color: scheme.secondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(Spacing.xl),
                    Text(
                      'Icons',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(Spacing.ms),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RewardPool.all
                          .where((r) => r.type == RewardType.icon)
                          .map((iconReward) {
                        final earned =
                            progress.earnedRewardIds.contains(iconReward.id);
                        final isActive = progress.activeIconId == iconReward.id;
                        return GestureDetector(
                          onTap: earned
                              ? () => context.read<GameCubit>().setActiveIcon(
                                  isActive ? null : iconReward.id)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? iconReward.color.withValues(alpha: 0.2)
                                  : earned
                                      ? iconReward.color.withValues(alpha: 0.1)
                                      : scheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(
                                color: isActive
                                    ? iconReward.color
                                    : earned
                                        ? iconReward.color
                                            .withValues(alpha: 0.3)
                                        : scheme.outline.withValues(alpha: 0.1),
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  iconReward.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Gap(Spacing.sm),
                                Text(
                                  earned
                                      ? iconReward.displayName
                                      : '${iconReward.displayName} · Locked',
                                  style: TextStyle(
                                    color: earned
                                        ? iconReward.color
                                        : scheme.onSurface
                                            .withValues(alpha: 0.3),
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isActive) ...[
                                  const Gap(Spacing.s),
                                  Icon(Icons.check_circle,
                                      color: iconReward.color, size: 16),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Gap(Spacing.xl),
                    Text(
                      'Titles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(Spacing.ms),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RewardPool.all
                          .where((r) => r.type == RewardType.title)
                          .map((titleReward) {
                        final earned =
                            progress.earnedRewardIds.contains(titleReward.id);
                        final isActive =
                            progress.activeTitleId == titleReward.id;
                        return GestureDetector(
                          onTap: earned
                              ? () => context.read<GameCubit>().setActiveTitle(
                                  isActive ? null : titleReward.id)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? titleReward.color.withValues(alpha: 0.2)
                                  : earned
                                      ? titleReward.color.withValues(alpha: 0.1)
                                      : scheme.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(
                                color: isActive
                                    ? titleReward.color
                                    : earned
                                        ? titleReward.color
                                            .withValues(alpha: 0.3)
                                        : scheme.outline.withValues(alpha: 0.1),
                                width: isActive ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(titleReward.icon,
                                    color: earned
                                        ? titleReward.color
                                        : scheme.onSurface
                                            .withValues(alpha: 0.3),
                                    size: 18),
                                const Gap(Spacing.sm),
                                Text(
                                  earned
                                      ? titleReward.value
                                      : '${titleReward.value} · Locked',
                                  style: TextStyle(
                                    color: earned
                                        ? titleReward.color
                                        : scheme.onSurface
                                            .withValues(alpha: 0.3),
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                                if (isActive) ...[
                                  const Gap(Spacing.s),
                                  Icon(Icons.check_circle,
                                      color: titleReward.color, size: 16),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _applyTheme(BuildContext context, String themeId) {
    context.read<GameCubit>().setThemeId(themeId == 'default' ? null : themeId);
    context.read<ThemeCubit>().applyTheme(themeId);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme scheme;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(Radii.ml),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: scheme.secondary, size: 24),
            const Gap(Spacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.ml),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.ml),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(Radii.ml),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: scheme.secondary, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption {
  final String id;
  final String label;
  final IconData icon;
  final bool shopOnly;

  const _ThemeOption({
    required this.id,
    required this.label,
    required this.icon,
    this.shopOnly = false,
  });
}

const _themes = [
  _ThemeOption(id: 'default', label: 'Default', icon: Icons.palette),
  _ThemeOption(id: 'dark', label: 'Dark', icon: Icons.dark_mode),
  _ThemeOption(id: 'amber', label: 'Amber', icon: Icons.light_mode),
  _ThemeOption(id: 'ocean', label: 'Ocean', icon: Icons.water_drop),
  _ThemeOption(id: 'neon', label: 'Neon', icon: Icons.nights_stay),
  _ThemeOption(
      id: 'medieval', label: 'Medieval', icon: Icons.castle, shopOnly: true),
  _ThemeOption(
      id: 'dungeon',
      label: 'Dungeon',
      icon: Icons.door_front_door,
      shopOnly: true),
  _ThemeOption(
      id: 'arcane', label: 'Arcane', icon: Icons.auto_awesome, shopOnly: true),
  _ThemeOption(
      id: 'dragon_fire',
      label: 'Dragon Fire',
      icon: Icons.local_fire_department,
      shopOnly: true),
];

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool unlocked;
  final VoidCallback? onUnlockTap;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.isActive,
    this.unlocked = true,
    this.onUnlockTap,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = unlocked ? onTap : onUnlockTap;
    return GestureDetector(
      onTap: canTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? scheme.secondary.withValues(alpha: 0.15)
              : unlocked
                  ? scheme.surface
                  : scheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: isActive
                ? scheme.secondary
                : unlocked
                    ? scheme.outline.withValues(alpha: 0.3)
                    : scheme.outline.withValues(alpha: 0.1),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? scheme.secondary
                  : scheme.onSurface.withValues(alpha: 0.5),
            ),
            const Gap(Spacing.s),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? scheme.secondary
                    : scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (!unlocked) ...[
              const Gap(Spacing.s),
              GestureDetector(
                onTap: onUnlockTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Radii.s),
                  ),
                  child: Text(
                    'Buy',
                    style: TextStyle(
                        color: scheme.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
