import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:littletech/src/features/game/constants/skin_tiers.dart';
import 'package:littletech/src/features/game/domain/cubit/suptech_customization_cubit.dart';
import 'package:littletech/src/features/game/domain/models/suptech_customization.dart';
import 'package:littletech/src/features/game/presentation/widgets/sup_tech_body_renderer.dart';
import 'package:littletech/src/features/game/presentation/widgets/sup_tech_renderer.dart';

class SupTechAvatar extends StatefulWidget {
  final double size;
  final bool isGlowing;
  final String? skinId;
  final AvatarState state;

  const SupTechAvatar({
    super.key,
    this.size = 56,
    this.isGlowing = true,
    this.skinId,
    this.state = const AvatarState(),
  });

  @override
  State<SupTechAvatar> createState() => _SupTechAvatarState();
}

class _SupTechAvatarState extends State<SupTechAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _blinkTimer;
  bool _isBlinking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(
      Duration(milliseconds: 4000 + Random().nextInt(4000)),
      () {
        if (!mounted) return;
        setState(() => _isBlinking = true);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          setState(() => _isBlinking = false);
          _scheduleBlink();
        });
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customization = context.watch<SupTechCustomizationCubit?>()?.state;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return CustomPaint(
            painter: _SkinPainter(
              skinId: widget.skinId,
              isGlowing: widget.isGlowing,
              animationValue: _controller.value,
              isBlinking: _isBlinking,
              state: widget.state,
              customization: customization,
            ),
          );
        },
      ),
    );
  }
}

class _SkinPainter extends CustomPainter {
  final String? skinId;
  final bool isGlowing;
  final double animationValue;
  final bool isBlinking;
  final AvatarState state;
  final SupTechCustomization? customization;

  _SkinPainter({
    required this.skinId,
    required this.isGlowing,
    required this.animationValue,
    required this.isBlinking,
    required this.state,
    this.customization,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;
    final skin = SkinTierManager.fromId(skinId);

    final c = customization;
    final resolvedExpression = c?.expression ?? state.expression;
    final resolvedHeadAccessory = c?.headAccessory ?? skin.headAccessory;
    final resolvedEarAccessory = c?.earAccessory ?? skin.earAccessory;
    final resolvedChestAccessory = c?.chestAccessory ?? skin.chestAccessory;
    final resolvedPose = c?.pose;

    canvas.save();
    final s = size.width / 60;
    canvas.translate(size.width / 2, size.height / 2 - 2 * s);

    // Breathing float
    final floatOffset = sin(animationValue * pi) * 0.5 * s;
    canvas.translate(0, floatOffset);

    // ── GEOMETRY — Reference-Matched (single tweak point) ──
    final headCY = -10 * s;
    final headR = 13 * s;
    final hoodBaseY = -3 * s;
    final hoodTopR = 10 * s;
    final hoodBottomR = 13 * s;
    final hoodPeakY = -28 * s;
    final faceCY = -8.8 * s;
    final faceW = 23.5 * s;
    final faceH = 14.5 * s;
    final bodyTopY = -1 * s;
    final bodyBotY = 12 * s;
    final robeShoulderW = 16 * s;
    final robeBaseW = 22 * s;
    final eyeY = -8.5 * s;
    final eyeSpacing = 5.2 * s;
    final eyeR = 3.1 * s;

    if (!drawSupTechBodyVariant(canvas, skin, s, skin.variant)) {
      drawSupTechBody(
          canvas, skin, s, bodyTopY, bodyBotY, robeShoulderW, robeBaseW);
      drawSupTechHead(canvas, skin, s, headCY, headR, hoodBaseY, hoodTopR,
          hoodBottomR, hoodPeakY);
    }
    if (!skin.hideFace) {
      _drawFace(canvas, skin, s, faceCY, faceW, faceH);

      final resolvedState = AvatarState(
        expression: resolvedExpression,
        blinking: isBlinking,
        lookDirection: state.lookDirection,
      );
      _drawEyesWithOverride(canvas, skin, s, eyeY, eyeSpacing, eyeR, faceCY,
          resolvedState, resolvedPose);
      if (skin.variant == SkinVariant.ninja) {
        drawNinjaFaceScarf(canvas, skin, s, faceCY, faceW, faceH);
      }
    }
    _drawHeadAccessoryValue(
        canvas, skin, s, headCY, headR, hoodPeakY, resolvedHeadAccessory);
    _drawEarAccessoryValue(canvas, skin, s, headCY, headR, resolvedEarAccessory,
        hoodPeakY: hoodPeakY);
    _drawChestAccessoryValue(
        canvas, skin, s, bodyTopY, bodyBotY, resolvedChestAccessory);
    _drawUniqueDetail(canvas, skin, s);
    _drawPoseOverlay(canvas, skin, s, resolvedPose, eyeY, eyeSpacing);
    _drawGlow(canvas, skin, s);

    canvas.restore();
  }

  // ─────────────────────────────────────────────
  // Face void (large dark opening)
  // ─────────────────────────────────────────────

  // ─────────────────────────────────────────────
  // Face void (large dark opening)
  // ─────────────────────────────────────────────

  void _drawFace(Canvas canvas, SkinDefinition skin, double s, double faceCY,
      double faceW, double faceH) {
    final faceRect = Rect.fromCenter(
      center: Offset(0, faceCY),
      width: faceW,
      height: faceH,
    );

    canvas.drawOval(
      faceRect.inflate(1.2 * s),
      Paint()
        ..shader = RadialGradient(
          colors: [
            skin.accentColor.withValues(alpha: 0.13),
            Colors.black.withValues(alpha: 0.0),
          ],
        ).createShader(faceRect.inflate(4 * s)),
    );

    canvas.drawOval(
      faceRect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0.05, -0.05),
          radius: 0.95,
          colors: [
            Color(0xFF1B2633),
            Color(0xFF05070B),
            Color(0xFF020306),
          ],
          stops: [0.0, 0.52, 1.0],
        ).createShader(faceRect)
        ..style = PaintingStyle.fill,
    );
  }

  // ─────────────────────────────────────────────
  // Eyes (expression-based)
  // ─────────────────────────────────────────────

  void _drawEyesWithOverride(
      Canvas canvas,
      SkinDefinition skin,
      double s,
      double eyeY,
      double eyeSpacing,
      double eyeR,
      double faceCY,
      AvatarState resolvedState,
      SupTechPose? pose) {
    if (pose == SupTechPose.working) {
      _drawFocusedEyes(canvas, s, eyeY, eyeSpacing);
      return;
    }
    if (resolvedState.blinking) {
      _drawBlinkLines(canvas, skin, s, eyeY, eyeSpacing);
      return;
    }
    _drawEyes(canvas, skin, s, eyeY, eyeSpacing, eyeR, faceCY, resolvedState);
  }

  void _drawEyes(Canvas canvas, SkinDefinition skin, double s, double eyeY,
      double eyeSpacing, double eyeR, double faceCY,
      [AvatarState? resolvedState]) {
    final effectiveState = resolvedState ?? state;
    if (effectiveState.blinking) {
      _drawBlinkLines(canvas, skin, s, eyeY, eyeSpacing);
      return;
    }
    drawSupTechEyes(
        canvas, skin, s, eyeY, eyeSpacing, eyeR, effectiveState.expression);
  }

  void _drawBlinkLines(Canvas canvas, SkinDefinition skin, double s,
      double eyeY, double eyeSpacing) {
    final linePaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * s
      ..strokeCap = StrokeCap.round;
    for (final dx in [-eyeSpacing, eyeSpacing]) {
      canvas.drawLine(
        Offset(dx - 3 * s, eyeY),
        Offset(dx + 3 * s, eyeY),
        linePaint,
      );
    }
  }

  // ─────────────────────────────────────────────
  // ─────────────────────────────────────────────
  // Head Accessory (antenna)
  // ─────────────────────────────────────────────

  void _drawHeadAccessoryValue(
      Canvas canvas,
      SkinDefinition skin,
      double s,
      double headCY,
      double headR,
      double hoodPeakY,
      SupTechHeadAccessory accessory) {
    drawSupTechHeadAccessory(
        canvas, skin, s, headCY, headR, hoodPeakY, accessory);
  }

  // ─────────────────────────────────────────────
  // Ear Accessory (headset)
  // ─────────────────────────────────────────────

  void _drawEarAccessoryValue(
    Canvas canvas,
    SkinDefinition skin,
    double s,
    double headCY,
    double headR,
    SupTechEarAccessory accessory, {
    double? hoodPeakY,
  }) {
    drawSupTechEarAccessory(canvas, skin, s, headCY, headR, accessory,
        hoodPeakY: hoodPeakY);
  }

  // ─────────────────────────────────────────────
  // Chest Accessory
  // ─────────────────────────────────────────────

  void _drawChestAccessoryValue(Canvas canvas, SkinDefinition skin, double s,
      double bodyTopY, double bodyBotY, SupTechChestAccessory accessory) {
    drawSupTechChestAccessory(canvas, skin, s, bodyTopY, bodyBotY, accessory);
  }

  // ─────────────────────────────────────────────
  // Focused eyes (for working pose)
  // ─────────────────────────────────────────────

  void _drawFocusedEyes(
      Canvas canvas, double s, double eyeY, double eyeSpacing) {
    drawSupTechFocusedEyes(canvas, s, eyeY, eyeSpacing);
  }

  // ─────────────────────────────────────────────
  // Pose overlay (wave arm, thinking hands, working screen)
  // ─────────────────────────────────────────────

  void _drawPoseOverlay(Canvas canvas, SkinDefinition skin, double s,
      SupTechPose? pose, double eyeY, double eyeSpacing) {
    if (pose == null ||
        pose == SupTechPose.none ||
        pose == SupTechPose.neutral) {
      return;
    }
    drawSupTechPoseOverlay(canvas, skin, s, pose, eyeY, eyeSpacing);
  }

  // ─────────────────────────────────────────────
  // Unique detail per skin
  // ─────────────────────────────────────────────

  void _drawUniqueDetail(Canvas canvas, SkinDefinition skin, double s) {
    switch (skin.id) {
      case 'hacker':
        _drawHackerDetail(canvas, skin, s);
        break;
      case 'ninja':
        _drawNinjaDetail(canvas, skin, s);
        break;
      case 'wizard':
        _drawWizardDetail(canvas, skin, s);
        break;
      case 'golden':
        _drawGoldenDetail(canvas, skin, s);
        break;
      case 'engineer':
        _drawEngineerDetail(canvas, skin, s);
        break;
      case 'grandmaster':
        _drawGrandmasterDetail(canvas, skin, s);
        break;
      case 'cyber':
        _drawCyberDetail(canvas, skin, s);
        break;
      case 'shadow':
        _drawShadowDetail(canvas, skin, s);
        break;
      case 'neon':
        _drawNeonDetail(canvas, skin, s);
        break;
      case 'phoenix':
        _drawPhoenixDetail(canvas, skin, s);
        break;
      case 'titan':
        _drawTitanDetail(canvas, skin, s);
        break;
      case 'void_':
        _drawVoidDetail(canvas, skin, s);
        break;
      case 'glitch':
        _drawGlitchDetail(canvas, skin, s);
        break;
      case 'frost':
        _drawFrostDetail(canvas, skin, s);
        break;
      case 'chrono':
        _drawChronoDetail(canvas, skin, s);
        break;
      case 'spectre':
        _drawSpectreDetail(canvas, skin, s);
        break;
      case 'viper':
        _drawViperDetail(canvas, skin, s);
        break;
      case 'spark':
        _drawSparkDetail(canvas, skin, s);
        break;
      case 'rookie':
        _drawRookieDetail(canvas, skin, s);
        break;
      default:
        break;
    }
  }

  void _drawHackerDetail(Canvas canvas, SkinDefinition skin, double s) {
    final promptPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * s
      ..strokeCap = StrokeCap.round;
    final py = -2 * s;
    canvas.drawLine(Offset(-3 * s, py), Offset(-1 * s, py), promptPaint);
    canvas.drawLine(
        Offset(-1 * s, py), Offset(-1 * s, py + 2 * s), promptPaint);
  }

  void _drawNinjaDetail(Canvas canvas, SkinDefinition skin, double s) {
    final starPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.fill;
    drawSupTechStar(canvas, Offset(6 * s, 6 * s), 1.0 * s, starPaint);
  }

  void _drawWizardDetail(Canvas canvas, SkinDefinition skin, double s) {
    final moonPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.fill;
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(-5 * s, -18 * s), width: 3 * s, height: 3 * s),
        -pi * 0.3,
        pi * 1.4,
        false,
        moonPaint);
  }

  void _drawGoldenDetail(Canvas canvas, SkinDefinition skin, double s) {
    canvas.drawCircle(
        Offset(0, -20 * s),
        4 * s,
        Paint()
          ..shader = RadialGradient(colors: [
            skin.accentColor.withValues(alpha: 0.4),
            skin.accentColor.withValues(alpha: 0.0),
          ]).createShader(
              Rect.fromCircle(center: Offset(0, -20 * s), radius: 5 * s)));
  }

  void _drawEngineerDetail(Canvas canvas, SkinDefinition skin, double s) {
    final wrenchPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(5 * s, 3 * s), Offset(5 * s, 9 * s), wrenchPaint);
    canvas.drawCircle(
        Offset(5 * s, 3 * s),
        1.5 * s,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = skin.accentColor
          ..strokeWidth = 0.5 * s);
  }

  void _drawGrandmasterDetail(Canvas canvas, SkinDefinition skin, double s) {
    final glowPaint = Paint()..color = skin.accentColor.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(0, -22 * s), 6 * s, glowPaint);
  }

  void _drawCyberDetail(Canvas canvas, SkinDefinition skin, double s) {
    final scanPaint = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3 * s;
    for (var i = 0; i < 3; i++) {
      final y = -4 * s + i * 3 * s;
      canvas.drawLine(Offset(-6 * s, y), Offset(6 * s, y), scanPaint);
    }
  }

  void _drawShadowDetail(Canvas canvas, SkinDefinition skin, double s) {
    final shadowPaint = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.15);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(2 * s, -4 * s), width: 12 * s, height: 16 * s),
        shadowPaint);
    final trailPaint = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-6 * s, 8 * s), Offset(-8 * s, 12 * s), trailPaint);
    canvas.drawLine(Offset(6 * s, 8 * s), Offset(8 * s, 12 * s), trailPaint);
  }

  void _drawNeonDetail(Canvas canvas, SkinDefinition skin, double s) {
    final neonPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75 * s
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 * s);
    canvas.drawLine(Offset(-6 * s, 2 * s), Offset(-6 * s, 10 * s), neonPaint);
    canvas.drawLine(Offset(6 * s, 2 * s), Offset(6 * s, 10 * s), neonPaint);
  }

  void _drawPhoenixDetail(Canvas canvas, SkinDefinition skin, double s) {
    final flamePaint = Paint()..color = skin.accentColor;
    for (final dx in [-4, 0, 4]) {
      final fh = (2 + (dx.abs() ~/ 2)) * s;
      canvas.drawPath(
        Path()
          ..moveTo(dx * s, 12 * s)
          ..quadraticBezierTo(
              dx * s + 1 * s, 12 * s - fh * 0.6, dx * s, 12 * s - fh)
          ..quadraticBezierTo(
              dx * s - 1 * s, 12 * s - fh * 0.6, dx * s, 12 * s),
        flamePaint,
      );
    }
  }

  void _drawTitanDetail(Canvas canvas, SkinDefinition skin, double s) {
    final platePaint = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(0, 4 * s), width: 6 * s, height: 4 * s),
            Radius.circular(1 * s)),
        platePaint);
    final plateOutline = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 * s;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(0, 4 * s), width: 6 * s, height: 4 * s),
            Radius.circular(1 * s)),
        plateOutline);
  }

  void _drawVoidDetail(Canvas canvas, SkinDefinition skin, double s) {
    final cosmicPaint = Paint()
      ..shader = RadialGradient(colors: [
        skin.accentColor.withValues(alpha: 0.5),
        skin.accentColor.withValues(alpha: 0.0),
      ]).createShader(Rect.fromCircle(center: Offset(0, 4 * s), radius: 6 * s));
    canvas.drawCircle(Offset(0, 4 * s), 5 * s, cosmicPaint);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    for (final pos in [
      Offset(-2 * s, 2 * s),
      Offset(3 * s, 5 * s),
      Offset(-1 * s, 7 * s),
      Offset(2 * s, 3 * s)
    ]) {
      canvas.drawCircle(pos, 0.4 * s, starPaint);
    }
  }

  void _drawGlitchDetail(Canvas canvas, SkinDefinition skin, double s) {
    final glitchPaint = Paint()
      ..color = skin.accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * s;
    canvas.drawLine(Offset(-6 * s, -2 * s), Offset(6 * s, -2 * s), glitchPaint);
    canvas.drawLine(Offset(-4 * s, 3 * s), Offset(4 * s, 3 * s), glitchPaint);
    canvas.drawLine(Offset(-2 * s, 8 * s), Offset(2 * s, 8 * s), glitchPaint);
    final offsetGlitch = Paint()
      ..color = skin.bodyColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 * s;
    canvas.drawLine(
        Offset(-5 * s, -1 * s), Offset(5 * s, -1 * s), offsetGlitch);
    canvas.drawLine(Offset(-3 * s, 5 * s), Offset(3 * s, 5 * s), offsetGlitch);
  }

  void _drawFrostDetail(Canvas canvas, SkinDefinition skin, double s) {
    final icePaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * s
      ..strokeCap = StrokeCap.round;
    for (final dx in [-4, 0, 4]) {
      final iy = 12 * s + (dx.abs() % 2) * 1.5 * s;
      canvas.drawLine(Offset(dx * s, iy), Offset(dx * s, iy + 2 * s), icePaint);
    }
  }

  void _drawChronoDetail(Canvas canvas, SkinDefinition skin, double s) {
    final clockPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * s;
    canvas.drawCircle(Offset(0, 4 * s), 3.5 * s, clockPaint);
    canvas.drawCircle(Offset(0, 4 * s), 0.8 * s, clockPaint);
    for (var i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final outer = Offset(3.5 * s * cos(angle), 4 * s + 3.5 * s * sin(angle));
      final inner = Offset(2.8 * s * cos(angle), 4 * s + 2.8 * s * sin(angle));
      canvas.drawLine(outer, inner, clockPaint);
    }
    canvas.drawLine(Offset(0, 4 * s), Offset(0, 2 * s), clockPaint);
    canvas.drawLine(Offset(0, 4 * s), Offset(2 * s, 4 * s), clockPaint);
  }

  void _drawSpectreDetail(Canvas canvas, SkinDefinition skin, double s) {
    final ghostPaint = Paint()..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawOval(
        Rect.fromCenter(
            center: const Offset(0, 0), width: 14 * s, height: 20 * s),
        ghostPaint);
  }

  void _drawViperDetail(Canvas canvas, SkinDefinition skin, double s) {
    final venomPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.fill;
    for (final pos in [
      Offset(-3 * s, 10 * s),
      Offset(3 * s, 11 * s),
      Offset(0, 12 * s)
    ]) {
      canvas.drawCircle(pos, 0.6 * s, venomPaint);
    }
  }

  void _drawSparkDetail(Canvas canvas, SkinDefinition skin, double s) {
    final sparkPaint = Paint()
      ..color = skin.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(-2 * s, -16 * s)
        ..lineTo(0, -12 * s)
        ..lineTo(-1 * s, -10 * s)
        ..lineTo(1 * s, -7 * s),
      sparkPaint,
    );
    for (final dx in [-5, 5]) {
      canvas.drawLine(
          Offset(dx * s, -2 * s), Offset((dx - 1) * s, 1 * s), sparkPaint);
      canvas.drawLine(
          Offset((dx - 1) * s, 1 * s), Offset((dx + 1) * s, 3 * s), sparkPaint);
    }
  }

  void _drawRookieDetail(Canvas canvas, SkinDefinition skin, double s) {
    final dotPaint = Paint()..color = skin.accentColor.withValues(alpha: 0.3);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset((-2 + i * 2) * s, 6 * s), 0.6 * s, dotPaint);
    }
  }

  // ─────────────────────────────────────────────
  // Glow (3-layer: core, soft, ambient pulse)
  // ─────────────────────────────────────────────

  void _drawGlow(Canvas canvas, SkinDefinition skin, double s) {
    if (!isGlowing) return;

    final pulseAlpha = 0.12 + animationValue * 0.08;
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 84 * s, height: 84 * s),
      Paint()
        ..shader = RadialGradient(colors: [
          skin.accentColor.withValues(alpha: pulseAlpha),
          skin.accentColor.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: Offset.zero, radius: 42 * s)),
    );
  }

  @override
  bool shouldRepaint(covariant _SkinPainter old) =>
      old.skinId != skinId ||
      old.isGlowing != isGlowing ||
      old.animationValue != animationValue ||
      old.isBlinking != isBlinking ||
      old.state.expression != state.expression ||
      old.customization != customization;
}
