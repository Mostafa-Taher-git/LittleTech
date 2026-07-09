import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/core/navigation/nav.dart';
import 'package:littletech/src/features/game/constants/game_data.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';
import 'package:littletech/src/features/game/presentation/screens/level_complete_screen.dart';
import 'package:littletech/src/features/game/presentation/screens/reward_spin_screen.dart';
import 'package:littletech/src/features/game/presentation/screens/suptech_dialog.dart';
import 'package:littletech/src/features/game/presentation/widgets/boss_visuals.dart';
import 'package:littletech/src/features/game/presentation/widgets/suptech_avatar.dart';
import 'package:littletech/src/features/game/presentation/widgets/sup_tech_avatar_wrapper.dart';

class BossScreen extends StatefulWidget {
  final BossEncounterDef boss;

  const BossScreen({super.key, required this.boss});

  @override
  State<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends State<BossScreen> with TickerProviderStateMixin {
  late AnimationController _bossController;
  late AnimationController _entranceController;
  late Animation<double> _breathAnimation;
  late Animation<double> _glowPulse;
  late Animation<double> _entranceAnimation;

  int _currentPhase = 0;
  String? _lastOutcome;
  bool _navigatedToReward = false;
  bool _showDiagnosis = false;
  bool _diagnosisLocked = false;
  String? _diagnosisResult;
  bool _diagnosisCorrect = false;
  int _resolveCount = 0;

  List<int>? _diagnosisShuffledOrder;

  bool get _isEasy => widget.boss.difficulty == DifficultyLevel.easy;
  bool get _isHard => widget.boss.difficulty == DifficultyLevel.hard;

  @override
  void initState() {
    super.initState();
    _bossController = AnimationController(
      vsync: this,
      duration: 2000.ms,
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: 800.ms,
    )..forward();

    _breathAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _bossController, curve: Curves.easeInOutSine),
    );

    _glowPulse = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _bossController, curve: Curves.easeInOutSine),
    );

    _entranceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _bossController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _selectedDiagnosis(int selectedShuffledIndex) {
    if (_diagnosisLocked) return;
    final diagnosis = widget.boss.diagnosis;
    if (diagnosis.isEmpty) return;

    _diagnosisLocked = true;
    final order = _diagnosisShuffledOrder ?? [];
    final originalIndex =
        order.isNotEmpty ? order[selectedShuffledIndex] : selectedShuffledIndex;
    final correct = (diagnosis['correct'] as int?) ?? 0;
    final cubit = context.read<GameCubit>();

    if (originalIndex == correct) {
      setState(() {
        _diagnosisResult =
            (diagnosis['flavor'] as String?) ?? 'Correct diagnosis.';
        _diagnosisCorrect = true;
      });
    } else {
      setState(() {
        _diagnosisResult =
            (diagnosis['failFlavor'] as String?) ?? 'Incorrect diagnosis.';
        _diagnosisCorrect = false;
      });
    }

    Future.delayed(1500.ms, () {
      if (mounted) {
        if (_diagnosisCorrect) {
          cubit.attackBoss(damage: 3);
        }
        setState(() {
          _showDiagnosis = false;
          _diagnosisResult = null;
          _diagnosisLocked = false;
          _currentPhase = 1;
        });
      }
    });
  }

  void _executeStrategy(Map<String, dynamic> strategy) {
    final cubit = context.read<GameCubit>();
    final rng = Random();
    final roll = rng.nextInt(100) + 1;
    final success = (strategy['success'] as int?) ?? 50;
    final damage = (strategy['damage'] as int?) ?? 1;

    if (roll <= success) {
      cubit.attackBoss(damage: damage);
      setState(() {
        _lastOutcome = (strategy['flavor'] as String?) ?? 'Strategy succeeded!';
        _currentPhase = 2;
      });
    } else {
      setState(() {
        _lastOutcome =
            (strategy['failFlavor'] as String?) ?? 'Strategy failed.';
        _currentPhase = 2;
      });
    }
  }

  Color _bossColor(int visualType) {
    const colors = [
      Color(0xFFE94560),
      Color(0xFF6BB5FF),
      Color(0xFF7B2D8B),
      Color(0xFF4A90D9),
      Color(0xFF2D6A4F),
      Color(0xFFFF6B35),
      Color(0xFF8B0000),
      Color(0xFFFFD700),
      Color(0xFF9B30FF),
      Color(0xFF00E5FF),
      Color(0xFFFF6B35),
      Color(0xFF00E5FF),
      Color(0xFFFF00FF),
      Color(0xFF00FF88),
    ];
    return colors[(visualType - 1).clamp(0, 13)];
  }

  Widget _buildDefeatedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, size: 22, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Defeated!',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseStart() {
    if (_isEasy) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _currentPhase = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.flash_on, size: 22),
          label: const Text(
            'Begin Battle!',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final diagnosis = widget.boss.diagnosis;
    if (_showDiagnosis) {
      if (_diagnosisResult != null) {
        final isCorrect = _diagnosisCorrect;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.shade900.withValues(alpha: 0.3)
                : Colors.red.shade900.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect
                  ? Colors.green.shade400.withValues(alpha: 0.4)
                  : Colors.red.shade400.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
                size: 36,
              ),
              const Gap(12),
              Text(
                _diagnosisResult!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }

      final options =
          (diagnosis['options'] as List<dynamic>?)?.cast<String>() ??
              <String>[];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIAGNOSIS PHASE',
            style: TextStyle(
              color: Colors.orange.shade300,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Gap(10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Text(
              (diagnosis['symptoms'] as String?) ?? 'Unknown symptoms',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const Gap(12),
          Text(
            'What is the correct diagnosis?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          ...(_diagnosisShuffledOrder ??
                  List.generate(options.length, (i) => i))
              .asMap()
              .entries
              .map((entry) {
            final shuffledPos = entry.key;
            final originalIdx = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectedDiagnosis(shuffledPos),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      options[originalIdx],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          final diagnosis = widget.boss.diagnosis;
          final opts = (diagnosis['options'] as List<dynamic>?) ?? <dynamic>[];
          _diagnosisShuffledOrder = List.generate(opts.length, (i) => i)
            ..shuffle(Random());
          setState(() {
            _showDiagnosis = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.flash_on, size: 22),
        label: const Text(
          'Begin Battle!',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildPhaseStrategy() {
    final strategies = widget.boss.strategies;
    return Column(
      children: [
        Text(
          'Choose your strategy:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(12),
        ...strategies.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _executeStrategy(s),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                '${s['damage']} dmg · ${s['success']}% success',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${s['success']}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildPhaseResolve() {
    final isRound2 = _isHard && _resolveCount >= 1;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _lastOutcome?.contains('!') ?? false
                    ? Icons.whatshot
                    : Icons.block,
                color: _lastOutcome?.contains('!') ?? false
                    ? Colors.orange.shade400
                    : Colors.red.shade300,
                size: 18,
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  _lastOutcome ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        if (_isHard && !isRound2)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _currentPhase = 1;
                _resolveCount++;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Second Wind!',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _currentPhase = 1;
                _resolveCount = 0;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Next Turn',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boss = widget.boss;
    final bossColor = _bossColor(boss.visualType);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('BOSS ENCOUNTER', style: TextStyle(letterSpacing: 2)),
      ),
      body: BlocBuilder<GameCubit, GameState>(
        builder: (_, state) {
          final hpLeft = state.currentBossHp;
          final isDefeated = hpLeft <= 0;

          if (isDefeated && !_navigatedToReward) {
            _navigatedToReward = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (state.lastDrawnReward != null) {
                  Nav.pushReplacement(context,
                      RewardSpinScreen(reward: state.lastDrawnReward!));
                } else if (state.currentWorld != null &&
                    state.currentLevel != null) {
                  Nav.pushReplacement(
                    context,
                    LevelCompleteScreen(
                      world: state.currentWorld!,
                      level: state.currentLevel!,
                      newAchievements: state.newlyUnlockedAchievements,
                      reward: null,
                    ),
                  );
                }
              }
            });
          }

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        bossColor.withValues(alpha: 0.15),
                        const Color(0xFF0D0D0D),
                        Colors.black,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: ArenaParticlePainter(
                    phase: _bossController.value,
                    visualType: boss.visualType,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    AnimatedBuilder(
                      animation: _breathAnimation,
                      builder: (_, child) {
                        return Opacity(
                          opacity: _entranceAnimation.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _breathAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(
                          painter: MonsterPainter(
                            visualType: boss.visualType,
                            isDefeated: isDefeated,
                            glowIntensity: _glowPulse.value,
                            phase: _bossController.value,
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    Text(
                      boss.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        boss.lore,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    if (boss.introText.isNotEmpty) ...[
                      const Gap(12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          boss.introText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),
                    ],
                    const Gap(24),
                    _HitDiceBar(
                      hpLeft: hpLeft,
                      bossHp: boss.hp,
                      isDefeated: isDefeated,
                    ).animate().fadeIn(delay: 500.ms),
                    const Gap(24),
                    _MonsterStatBlock(
                      armorClass: boss.armor,
                      hpDisplay: '${boss.hp}',
                      abilities: boss.abilities,
                      isDefeated: isDefeated,
                      challengeRating: boss.challengeRating,
                      difficulty: boss.difficulty,
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                    if (!isDefeated &&
                        boss.phaseShiftText.isNotEmpty &&
                        hpLeft <= (boss.hp / 2).ceil()) ...[
                      const Gap(12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            boss.phaseShiftText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade200,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.1),
                    ],
                    const Gap(24),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        children: [
                          if (isDefeated)
                            _buildDefeatedButton()
                          else if (_currentPhase == 0)
                            _buildPhaseStart()
                          else if (_currentPhase == 1)
                            _buildPhaseStrategy()
                          else
                            _buildPhaseResolve(),
                          if (!isDefeated) ...[
                            const Gap(16),
                            Center(
                              child: SupTechAvatarWrapper(
                                size: 48,
                                onTap: () => _showSupTechDialog(context),
                                child: SupTechAvatar(
                                  size: 48,
                                  skinId: state.progress.activeSkinId,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isDefeated)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'VICTORY!',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Awaiting your reward...',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSupTechDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SupTechDialog(contextType: SupTechContext.boss),
    );
  }
}

class _HitDiceBar extends StatelessWidget {
  final int hpLeft;
  final int bossHp;
  final bool isDefeated;

  const _HitDiceBar({
    required this.hpLeft,
    required this.bossHp,
    required this.isDefeated,
  });

  @override
  Widget build(BuildContext context) {
    const segments = 8;
    final segmentHp = bossHp / segments;
    final filledSegments =
        ((bossHp - hpLeft) / segmentHp).ceil().clamp(0, segments);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HIT POINTS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Gap(8),
          Row(
            children: [
              Icon(
                isDefeated ? Icons.check_circle : Icons.favorite,
                color: isDefeated ? Colors.green : Colors.red.shade400,
                size: 16,
              ),
              const Gap(8),
              Text(
                '$hpLeft / $bossHp',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: List.generate(segments, (i) {
              final isFilled = i < filledSegments;
              return Expanded(
                child: Container(
                  height: 12,
                  margin: EdgeInsets.only(right: i < segments - 1 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? (isDefeated ? Colors.green : Colors.red.shade400)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isFilled
                          ? (isDefeated
                              ? Colors.green.shade300
                              : Colors.red.shade300)
                          : Colors.white.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MonsterStatBlock extends StatelessWidget {
  final int armorClass;
  final String hpDisplay;
  final List<Map<String, dynamic>> abilities;
  final bool isDefeated;
  final int challengeRating;
  final DifficultyLevel difficulty;

  const _MonsterStatBlock({
    required this.armorClass,
    required this.hpDisplay,
    required this.abilities,
    required this.isDefeated,
    this.challengeRating = 3,
    this.difficulty = DifficultyLevel.medium,
  });

  @override
  Widget build(BuildContext context) {
    final diffLabel = switch (difficulty) {
      DifficultyLevel.easy => 'EASY',
      DifficultyLevel.medium => 'MEDIUM',
      DifficultyLevel.hard => 'HARD',
    };
    final diffColor = switch (difficulty) {
      DifficultyLevel.easy => Colors.green,
      DifficultyLevel.medium => Colors.orange,
      DifficultyLevel.hard => Colors.red,
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STAT BLOCK',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Gap(12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatChip(label: 'AC', value: '$armorClass'),
                const Gap(12),
                _StatChip(label: 'HP', value: hpDisplay),
                const Gap(12),
                _StatChip(label: 'CR', value: '$challengeRating'),
                const Gap(12),
                _StatChip(
                    label: 'Tier', value: diffLabel, valueColor: diffColor),
                const Gap(12),
                _StatChip(
                  label: 'Status',
                  value: isDefeated ? 'DEFEATED' : 'ACTIVE',
                  valueColor: isDefeated ? Colors.green : Colors.red.shade400,
                ),
              ],
            ),
          ),
          const Gap(12),
          const Divider(color: Colors.white12, height: 1),
          const Gap(12),
          Text(
            'ABILITIES',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const Gap(8),
          ...abilities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle,
                        size: 4, color: Colors.white.withValues(alpha: 0.3)),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a['name'] as String,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (a['description'] != null &&
                              (a['description'] as String).isNotEmpty)
                            Text(
                              a['description'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
