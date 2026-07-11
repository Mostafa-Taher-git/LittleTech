import 'package:flutter/material.dart';
import 'package:littletech/src/core/constants/design_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';

class _ActionDef {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  const _ActionDef({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}

final _contextActions = {
  SupTechContext.problem: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Get a helpful tip'),
    _ActionDef(
        id: 'skip',
        label: 'Skip Step',
        icon: Icons.skip_next,
        description: 'Auto-solve this step'),
    _ActionDef(
        id: 'diagnose',
        label: 'Diagnose',
        icon: Icons.quiz_outlined,
        description: 'Ask guided questions'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'Simple explanation of this step'),
  ],
  SupTechContext.quiz: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Eliminate one wrong answer'),
    _ActionDef(
        id: 'skip',
        label: 'Skip Question',
        icon: Icons.skip_next,
        description: 'Auto-answer this question'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'Explain the concept being tested'),
  ],
  SupTechContext.ordering: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Reveal correct position for one step'),
    _ActionDef(
        id: 'skip',
        label: 'Auto-Arrange',
        icon: Icons.skip_next,
        description: 'Automatically arrange correctly'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'Why this sequence matters'),
  ],
  SupTechContext.scenario: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Nudge toward the better response'),
    _ActionDef(
        id: 'skip',
        label: 'Skip',
        icon: Icons.skip_next,
        description: 'Auto-pick the correct response'),
    _ActionDef(
        id: 'diagnose',
        label: 'Diagnose',
        icon: Icons.quiz_outlined,
        description: 'Walk through the reasoning'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'Why the correct response is right'),
  ],
  SupTechContext.traps: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Point toward which area has the issue'),
    _ActionDef(
        id: 'skip',
        label: 'Skip',
        icon: Icons.skip_next,
        description: 'Reveal the trap directly'),
    _ActionDef(
        id: 'diagnose',
        label: 'Diagnose',
        icon: Icons.quiz_outlined,
        description: 'Questions to track down the issue'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'What the trap is and why it is wrong'),
  ],
  SupTechContext.mistake: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Point toward which area has the issue'),
    _ActionDef(
        id: 'skip',
        label: 'Skip',
        icon: Icons.skip_next,
        description: 'Mark the mistake directly'),
    _ActionDef(
        id: 'diagnose',
        label: 'Diagnose',
        icon: Icons.quiz_outlined,
        description: 'Questions to track down the issue'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'What the mistake is and why it is wrong'),
  ],
  SupTechContext.boss: const [
    _ActionDef(
        id: 'hint',
        label: 'Hint',
        icon: Icons.lightbulb_outline,
        description: 'Get a boss-fighting tip'),
    _ActionDef(
        id: 'diagnose',
        label: 'Diagnose',
        icon: Icons.quiz_outlined,
        description: 'Analyze the situation'),
    _ActionDef(
        id: 'explain',
        label: 'Explain',
        icon: Icons.description_outlined,
        description: 'Lore and strategy context'),
  ],
};

class SupTechDialog extends StatelessWidget {
  final SupTechContext contextType;
  final int questionIndex;

  const SupTechDialog(
      {super.key, required this.contextType, this.questionIndex = 0});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actions = _contextActions[contextType] ??
        _contextActions[SupTechContext.problem]!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BlocBuilder<GameCubit, GameState>(
        builder: (_, state) {
          final poolZero = state.availableSupTechUses <= 0;
          final questionKey = GameState.questionKey(
            context: state.supTechContext,
            levelId: state.currentLevel?.id,
            stepIndex: state.currentStepIndex,
            bossId: state.currentBoss?.id,
            itemIndex: questionIndex,
          );

          return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                    ),
                  ),
                  const Gap(Spacing.md),
                  Row(
                    children: [
                      Text(
                        'SupTech',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Text(
                          '${state.availableSupTechUses} left',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(Spacing.xs),
                  Text(
                    'Pick an action to help with this step',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const Gap(Spacing.lg),
                  ...actions.map((a) {
                    final alreadyUsed =
                        state.usedSupTechActions[questionKey]?.contains(a.id) ??
                            false;
                    final enabled = alreadyUsed || !poolZero;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ActionButton(
                        icon: a.icon,
                        label: a.label,
                        description: alreadyUsed
                            ? 'Already used — tap to reopen'
                            : a.description,
                        color: _actionColor(scheme, a.id),
                        enabled: enabled,
                        onTap: enabled ? () => _useAction(context, a.id) : null,
                      ),
                    );
                  }),
                  const Gap(Spacing.ms),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _actionColor(ColorScheme scheme, String actionId) {
    switch (actionId) {
      case 'hint':
        return scheme.tertiary;
      case 'skip':
        return scheme.error;
      case 'diagnose':
        return scheme.secondary;
      case 'explain':
        return scheme.primary;
      default:
        return scheme.primary;
    }
  }

  String _labelFor(String actionId) {
    switch (actionId) {
      case 'hint':
        return 'Hint';
      case 'skip':
        return 'Skipped';
      case 'diagnose':
        return 'Diagnosis';
      case 'explain':
        return 'Explanation';
      default:
        return 'Result';
    }
  }

  void _useAction(BuildContext context, String action) {
    final cubit = context.read<GameCubit>();
    cubit.useSupTech(action, questionIndex: questionIndex);
    Navigator.pop(context);

    if (action == 'skip') return;

    final hintText = cubit.state.hintText;
    if (hintText != null) {
      Future.microtask(() {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    size: 20,
                    color: _actionColor(Theme.of(ctx).colorScheme, action)),
                const Gap(Spacing.sm),
                Text(_labelFor(action)),
              ],
            ),
            content: Text(hintText),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final alpha = enabled ? 1.0 : 0.35;

    return Material(
      color: color.withValues(alpha: 0.06 * alpha),
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.15 * alpha)),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1 * alpha),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child:
                    Icon(icon, color: color.withValues(alpha: alpha), size: 22),
              ),
              const Gap(Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: scheme.onSurface.withValues(alpha: alpha),
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.5 * alpha),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: color.withValues(alpha: alpha), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
