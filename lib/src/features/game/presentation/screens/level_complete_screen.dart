import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:littletech/src/core/constants/colors.dart';
import 'package:littletech/src/core/navigation/nav.dart';
import 'package:littletech/src/features/game/constants/achievements.dart';
import 'package:littletech/src/features/game/constants/game_data.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/data/models/player_progress.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';
import 'package:littletech/src/features/game/presentation/screens/level_select_screen.dart';

class LevelCompleteScreen extends StatefulWidget {
  final WorldDef world;
  final LevelDef level;
  final List<Achievement> newAchievements;
  final RewardDef? reward;

  const LevelCompleteScreen({
    super.key,
    required this.world,
    required this.level,
    this.newAchievements = const [],
    this.reward,
  });

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late List<_Particle> _particles;
  final _rng = Random();
  int _displayPoints = 0;
  Map<String, dynamic>? _prepData;
  bool _pointsReachedFinal = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _particles = List.generate(
        50,
        (_) => _Particle(
              x: _rng.nextDouble(),
              y: 1.0 + _rng.nextDouble() * 0.3,
              speed: 0.003 + _rng.nextDouble() * 0.005,
              size: 2 + _rng.nextDouble() * 4,
              opacity: 0.3 + _rng.nextDouble() * 0.5,
              color: _rng.nextDouble() > 0.5
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFFFA000),
            ));
  }

  int get _totalPoints => context.read<GameCubit>().state.lastLevelPointsEarned;

  Color get _categoryColor => CategoryColors.forId(widget.world.id);

  Color get _bossColor => CategoryColors.forBoss(_visualTypeForWorld);

  int get _visualTypeForWorld {
    final bosses = widget.world.bosses;
    if (bosses.isNotEmpty) return bosses.first.visualType;
    final worldIndex = [
      'core_components',
      'ram',
      'operating_system',
      'audio',
      'peripherals',
      'software',
      'internet',
      'storage',
      'display',
      'mobile',
      'gaming',
      'smart_home',
      'security',
      'networking'
    ].indexOf(widget.world.id);
    return worldIndex >= 0 ? worldIndex + 1 : 1;
  }

  bool get _isBossLevel => widget.level.isBossLevel;

  int get _starRating {
    if (_prepData == null) return 2;
    final quiz = _prepData!['quiz'] as Map?;
    final totalCorrect = quiz?['correct'] as int? ?? 0;
    final totalQuestions = quiz?['total'] as int? ?? 4;
    final accuracy = totalQuestions > 0 ? totalCorrect / totalQuestions : 0.5;
    final cubitState = context.read<GameCubit>().state;
    final isFirstAttempt = !cubitState.earnedNoSupTechBonus;
    if (accuracy >= 0.9 && isFirstAttempt) return 3;
    if (accuracy >= 0.6) return 2;
    return 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating) return;
    final raw =
        context.read<GameCubit>().state.progress.getPrepResult(widget.level.id);
    _prepData = raw != null ? json.decode(raw) as Map<String, dynamic> : null;

    _controller.addListener(() {
      final t = _controller.value;
      for (final p in _particles) {
        p.y -= p.speed;
        if (p.y < -0.1) {
          p.y = 1.0;
          p.x = _rng.nextDouble();
        }
      }
      if (t >= 0.4 && t <= 0.7) {
        final pts = ((t - 0.4) / 0.3 * _totalPoints).round();
        if (pts != _displayPoints) setState(() => _displayPoints = pts);
      }
      if (t >= 0.7 && !_pointsReachedFinal) {
        setState(() {
          _displayPoints = _totalPoints;
          _pointsReachedFinal = true;
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;
    final scheme = Theme.of(context).colorScheme;
    final currentPoints = context.read<GameCubit>().state.progress.points;
    final rankThresholds = [0, 100, 500, 1500, 5000, 15000, 50000];
    final rankNames = [
      'Beginner',
      'Novice',
      'Apprentice',
      'Skilled Repairer',
      'Master Technician',
      'Tech Legend',
      'Grand Master'
    ];
    int currentRank = 0;
    for (var i = rankThresholds.length - 1; i >= 0; i--) {
      if (currentPoints >= rankThresholds[i]) {
        currentRank = i;
        break;
      }
    }
    final nextRank =
        currentRank < rankThresholds.length - 1 ? currentRank + 1 : currentRank;
    final prevThreshold = rankThresholds[currentRank];
    final nextThreshold = rankThresholds[nextRank];
    final xpProgress = nextThreshold > prevThreshold
        ? ((currentPoints - prevThreshold) / (nextThreshold - prevThreshold))
            .clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ParticlePainter(
                  particles: _particles,
                  opacity: (t - 0.1).clamp(0.0, 1.0),
                ),
              );
            },
          ),
          Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _bossColor.withValues(alpha: 0.3),
                    Colors.black,
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // Boss Defeat Banner
                  if (_isBossLevel)
                    Opacity(
                      opacity: (t - 0.15).clamp(0.0, 1.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _bossColor.withValues(alpha: 0.3),
                              _bossColor.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          border: Border.all(
                            color: _bossColor.withValues(alpha: 0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _bossColor.withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.whatshot, color: _bossColor, size: 24),
                            const Gap(Spacing.sm),
                            Text(
                              'BOSS DEFEATED',
                              style: TextStyle(
                                color: _bossColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                              ),
                            ),
                            const Gap(Spacing.sm),
                            Icon(Icons.whatshot, color: _bossColor, size: 24),
                          ],
                        ),
                      ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          ),
                    ),

                  if (_isBossLevel) const Gap(Spacing.md),

                  // Title
                  Opacity(
                    opacity: (t - 0.2).clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.5 + 0.5 * ((t - 0.2) / 0.2).clamp(0.0, 1.0),
                      child: Text(
                        'LEVEL COMPLETE',
                        style: TextStyle(
                          color: _bossColor,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: _bossColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(Spacing.sm),
                  Opacity(
                    opacity: (t - 0.3).clamp(0.0, 1.0),
                    child: Text(
                      widget.level.title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Gap(Spacing.lg),

                  // Star Rating
                  Opacity(
                    opacity: (t - 0.35).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isFilled = index < _starRating;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: isFilled ? Colors.amber : Colors.white24,
                            size: 36,
                            shadows: isFilled
                                ? [
                                    Shadow(
                                      color:
                                          Colors.amber.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }).animate().scale(
                            begin: const Offset(0, 0),
                            duration: 400.ms,
                            curve: Curves.elasticOut,
                          ),
                    ),
                  ),

                  const Gap(Spacing.xl),

                  // Points Card
                  Opacity(
                    opacity: (t - 0.4).clamp(0.0, 1.0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 48),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(
                          color: _bossColor.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _bossColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, child) {
                              final scale = _pointsReachedFinal
                                  ? 1.0 + (_pulseController.value * 0.05)
                                  : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Text(
                              '+$_displayPoints',
                              style: TextStyle(
                                color: _bossColor,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: _bossColor.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Gap(Spacing.xs),
                          Text(
                            'POINTS EARNED',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(Spacing.lg),

                  // Stats Card
                  Opacity(
                    opacity: (t - 0.45).clamp(0.0, 1.0),
                    child: _buildStatsCard(
                        context.read<GameCubit>().state.progress, scheme),
                  ),

                  const Gap(Spacing.lg),

                  // Prep Chips
                  ..._buildPrepChips(t),

                  // Rank Up Notification
                  if (currentRank < nextRank)
                    Opacity(
                      opacity: (t - 0.6).clamp(0.0, 1.0),
                      child: _buildRankUpBanner(
                          rankNames, currentRank, nextRank, scheme),
                    ),

                  // Reward
                  if (widget.reward != null)
                    Opacity(
                      opacity: (t - 0.55).clamp(0.0, 1.0),
                      child: _buildRewardReveal(scheme),
                    ),

                  // Achievements
                  if (widget.newAchievements.isNotEmpty)
                    Opacity(
                      opacity: (t - 0.65).clamp(0.0, 1.0),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Column(
                          children: widget.newAchievements
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.emoji_events,
                                            color: Colors.amber, size: 20),
                                        const Gap(Spacing.sm),
                                        Text(
                                          a.name,
                                          style: TextStyle(
                                            color: Colors.amber.shade200,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // XP Progress Bar
                  Opacity(
                    opacity: (t - 0.7).clamp(0.0, 1.0),
                    child: _buildXPBar(
                        xpProgress, rankNames, currentRank, nextRank, scheme),
                  ),

                  const SizedBox(height: 24),

                  // Continue Button
                  Opacity(
                    opacity: (t - 0.75).clamp(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: t >= 0.75
                              ? () {
                                  HapticFeedback.mediumImpact();
                                  Nav.pushReplacement(
                                    context,
                                    LevelSelectScreen(world: widget.world),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward, size: 20),
                          label: const Text(
                            'Continue',
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _bossColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Radii.lg),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(PlayerProgress progress, ColorScheme scheme) {
    final accuracy = progress.totalAnswers > 0
        ? (progress.correctAnswers * 100 / progress.totalAnswers).round()
        : 0;
    final hours = progress.totalPlayTimeSeconds ~/ 3600;
    final minutes = (progress.totalPlayTimeSeconds % 3600) ~/ 60;
    final timeStr = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(
              Icons.check_circle, '$accuracy%', 'Accuracy', AppColors.success),
          _statDivider(),
          _statItem(Icons.timer, timeStr, 'Time', _categoryColor),
          _statDivider(),
          _statItem(Icons.local_fire_department, '${progress.bossesDefeated}',
              'Bosses', Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const Gap(Spacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildRewardReveal(ColorScheme scheme) {
    const rarityColor = RarityColors.legendary;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rarityColor.withValues(alpha: 0.1),
              border: Border.all(
                color: rarityColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              widget.reward!.icon,
              color: rarityColor,
              size: 48,
            ),
          ).animate().scale(
                begin: const Offset(0, 0),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),
          const Gap(Spacing.sm),
          Text(
            widget.reward!.displayName,
            style: const TextStyle(
              color: rarityColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankUpBanner(List<String> rankNames, int currentRank,
      int nextRank, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.withValues(alpha: 0.2),
              Colors.amber.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, color: Colors.amber, size: 24),
            const Gap(Spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RANK UP!',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '→ ${rankNames[nextRank]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().slideX(
            begin: 0.2,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  Widget _buildXPBar(double progress, List<String> rankNames, int currentRank,
      int nextRank, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rankNames[currentRank],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                rankNames[nextRank],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(Spacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_bossColor),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrepChips(double t) {
    if (_prepData == null) return [];
    final chips = <Widget>[];
    final quiz = _prepData!['quiz'] as Map?;
    final ordering = _prepData!['ordering'] as Map?;
    final traps = _prepData!['traps'] as Map?;

    if (quiz != null) {
      final correct = quiz['correct'] as int? ?? 0;
      final total = quiz['total'] as int? ?? 0;
      chips.add(_prepChip(
        Icons.check_circle,
        '$correct/$total',
        'Quiz',
        total > 0 && correct == total ? AppColors.success : _categoryColor,
      ));
    }
    if (ordering != null) {
      final passed = ordering['passed'] == true;
      final attempts = ordering['attempts'] as int? ?? 1;
      chips.add(_prepChip(
        passed ? Icons.check_circle : Icons.replay,
        passed ? 'Pass' : '${attempts}x',
        'Order',
        passed ? AppColors.success : AppColors.error,
      ));
    }
    if (traps != null) {
      final correct = traps['correct'] as int? ?? 0;
      final total = traps['total'] as int? ?? 0;
      final passed = traps['passed'] == true;
      chips.add(_prepChip(
        passed ? Icons.check_circle : Icons.cancel,
        '$correct/$total',
        'Traps',
        passed ? AppColors.success : AppColors.error,
      ));
    }

    final cubitState = context.read<GameCubit>().state;
    if (cubitState.earnedNoSupTechBonus) {
      chips.add(
          _prepChip(Icons.psychology, '+25', 'No Hints', AppColors.success));
    }
    chips.add(_prepChip(Icons.bolt, '+25', 'First Try', AppColors.success));

    if (chips.isEmpty) return [];

    return [
      Opacity(
        opacity: (t - 0.48).clamp(0.0, 1.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: chips,
          ),
        ),
      ),
    ];
  }

  Widget _prepChip(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const Gap(Spacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double x, y, speed, size, opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double opacity;

  _ParticlePainter({required this.particles, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.opacity != opacity || old.particles != particles;
}
