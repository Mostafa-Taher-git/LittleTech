import 'dart:math';
import 'package:flutter/material.dart';
import 'package:littletech/src/core/constants/design_tokens.dart';

class BossVisuals {
  BossVisuals._();

  static Color color(int visualType) =>
      CategoryColors.forVisualType(visualType);

  static Color particleColor(int visualType) => color(visualType);

  static Color glowColor(int visualType) =>
      color(visualType).withValues(alpha: 0.3);
}

class BossDefeatedBadge extends StatelessWidget {
  final double size;
  const BossDefeatedBadge({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
        ),
        border: Border.all(color: const Color(0xFFDAA520), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.emoji_events,
        color: const Color(0xFF3E2723),
        size: size * 0.55,
      ),
    );
  }
}

class BossMiniPainter extends CustomPainter {
  final int visualType;
  final bool isDefeated;

  BossMiniPainter({required this.visualType, this.isDefeated = false});

  static const _outline = Color(0xFF1A1A1A);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 24;

    if (isDefeated) {
      final paint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 10 * s, paint);
      paint
        ..color = Colors.grey.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * s;
      canvas.drawLine(
        Offset(cx - 5 * s, cy - 5 * s),
        Offset(cx + 5 * s, cy + 5 * s),
        paint,
      );
      canvas.drawLine(
        Offset(cx + 5 * s, cy - 5 * s),
        Offset(cx - 5 * s, cy + 5 * s),
        paint,
      );
      return;
    }

    final color = BossVisuals.color(visualType);
    final fill = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * s;

    switch (visualType) {
      case 1: // Bone Colossus — broad triangular torso
        final path = Path()
          ..moveTo(cx, cy - 10 * s)
          ..lineTo(cx - 9 * s, cy + 8 * s)
          ..lineTo(cx + 9 * s, cy + 8 * s)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, outline);
        // two small horns
        canvas.drawLine(Offset(cx - 4 * s, cy - 9 * s),
            Offset(cx - 7 * s, cy - 11 * s), outline);
        canvas.drawLine(Offset(cx + 4 * s, cy - 9 * s),
            Offset(cx + 7 * s, cy - 11 * s), outline);
        // three eyes
        final eyePaint = Paint()..color = const Color(0xFFCC3344);
        canvas.drawCircle(Offset(cx - 3 * s, cy - 3 * s), 1 * s, eyePaint);
        canvas.drawCircle(Offset(cx, cy - 4.5 * s), 1 * s, eyePaint);
        canvas.drawCircle(Offset(cx + 3 * s, cy - 3 * s), 1 * s, eyePaint);

      case 2: // Memory Devourer — shark jaw
        final jaw = Path()
          ..moveTo(cx - 9 * s, cy - 4 * s)
          ..quadraticBezierTo(cx - 10 * s, cy + 4 * s, cx - 4 * s, cy + 8 * s)
          ..lineTo(cx + 4 * s, cy + 8 * s)
          ..quadraticBezierTo(cx + 10 * s, cy + 4 * s, cx + 9 * s, cy - 4 * s)
          ..quadraticBezierTo(cx, cy - 11 * s, cx - 9 * s, cy - 4 * s)
          ..close();
        canvas.drawPath(jaw, fill);
        canvas.drawPath(jaw, outline);
        // dorsal fin
        final fin = Path()
          ..moveTo(cx - 2 * s, cy - 9 * s)
          ..lineTo(cx + 1 * s, cy - 12 * s)
          ..lineTo(cx + 4 * s, cy - 9 * s)
          ..close();
        canvas.drawPath(fin, fill);
        // teeth
        final teethPaint = Paint()..color = Colors.white;
        for (var i = -2; i <= 2; i++) {
          canvas.drawRect(
              Rect.fromCenter(
                  center: Offset(cx + i * 3 * s, cy + 3 * s),
                  width: 1.5 * s,
                  height: 3 * s),
              teethPaint);
        }

      case 3: // Kernel Wraith — hooded robe
        final robe = Path()
          ..moveTo(cx - 7 * s, cy + 9 * s)
          ..lineTo(cx - 10 * s, cy + 6 * s)
          ..quadraticBezierTo(cx - 11 * s, cy - 2 * s, cx - 5 * s, cy - 8 * s)
          ..quadraticBezierTo(cx, cy - 12 * s, cx + 5 * s, cy - 8 * s)
          ..quadraticBezierTo(cx + 11 * s, cy - 2 * s, cx + 10 * s, cy + 6 * s)
          ..lineTo(cx + 7 * s, cy + 9 * s)
          ..close();
        canvas.drawPath(robe, fill);
        canvas.drawPath(robe, outline);
        // hood
        final hood = Path()
          ..moveTo(cx - 6 * s, cy - 6 * s)
          ..quadraticBezierTo(cx, cy - 13 * s, cx + 6 * s, cy - 6 * s)
          ..close();
        canvas.drawPath(hood, fill);
        canvas.drawPath(hood, outline);
        // glowing eyes
        final eyePaint = Paint()..color = const Color(0xFF00FF88);
        canvas.drawCircle(Offset(cx - 3 * s, cy - 5 * s), 1.5 * s, eyePaint);
        canvas.drawCircle(Offset(cx + 3 * s, cy - 5 * s), 1.5 * s, eyePaint);

      case 4: // Feedback Phantom — speaker-cone mouth
        canvas.drawCircle(Offset(cx, cy), 9 * s, fill);
        canvas.drawCircle(Offset(cx, cy), 9 * s, outline);
        // concentric rings
        canvas.drawCircle(
            Offset(cx, cy + 2 * s),
            6 * s,
            Paint()
              ..color = const Color(0xFF1A1E28)
              ..style = PaintingStyle.fill);
        canvas.drawCircle(
            Offset(cx, cy + 2 * s), 4 * s, Paint()..color = color);
        // eyes
        final eyePaint = Paint()..color = const Color(0xFFFFCC00);
        canvas.drawCircle(Offset(cx - 3 * s, cy - 4 * s), 1.8 * s, eyePaint);
        canvas.drawCircle(Offset(cx + 3 * s, cy - 4 * s), 1.8 * s, eyePaint);
        canvas.drawCircle(
            Offset(cx - 3 * s, cy - 4 * s), 0.8 * s, Paint()..color = _outline);
        canvas.drawCircle(
            Offset(cx + 3 * s, cy - 4 * s), 0.8 * s, Paint()..color = _outline);

      case 5: // Input Overlord — crab shape
        // body
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 2 * s), width: 14 * s, height: 10 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 2 * s), width: 14 * s, height: 10 * s),
            outline);
        // claws
        for (final side in [-1, 1]) {
          final claw = Path()
            ..moveTo(cx + side * 8 * s, cy)
            ..lineTo(cx + side * 12 * s, cy - 4 * s)
            ..lineTo(cx + side * 13 * s, cy - 1 * s)
            ..lineTo(cx + side * 12 * s, cy + 2 * s)
            ..lineTo(cx + side * 8 * s, cy + 3 * s)
            ..close();
          canvas.drawPath(claw, fill);
          canvas.drawPath(claw, outline);
        }
        // cyclops eye
        final eyePaint = Paint()..color = const Color(0xFFFFCC00);
        canvas.drawCircle(Offset(cx, cy - 2 * s), 3 * s, eyePaint);
        canvas.drawCircle(
            Offset(cx, cy - 2 * s), 1.5 * s, Paint()..color = _outline);

      case 6: // Dependency Demon — tiny imp with chain
        // head (oversized)
        canvas.drawCircle(Offset(cx, cy - 3 * s), 6 * s, fill);
        canvas.drawCircle(Offset(cx, cy - 3 * s), 6 * s, outline);
        // body (small)
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 6 * s), width: 8 * s, height: 6 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 6 * s), width: 8 * s, height: 6 * s),
            outline);
        // horns
        canvas.drawLine(Offset(cx - 4 * s, cy - 8 * s),
            Offset(cx - 7 * s, cy - 11 * s), outline);
        canvas.drawLine(Offset(cx + 4 * s, cy - 8 * s),
            Offset(cx + 7 * s, cy - 11 * s), outline);
        // eyes
        canvas.drawCircle(Offset(cx - 2.5 * s, cy - 4 * s), 1.5 * s,
            Paint()..color = const Color(0xFFFF4444));
        canvas.drawCircle(Offset(cx + 2.5 * s, cy - 4 * s), 1.5 * s,
            Paint()..color = const Color(0xFFFF4444));

      case 7: // Latency Leviathan — whale/squid
        // body
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy - 2 * s), width: 16 * s, height: 10 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy - 2 * s), width: 16 * s, height: 10 * s),
            outline);
        // tail
        final tail = Path()
          ..moveTo(cx - 8 * s, cy - 2 * s)
          ..lineTo(cx - 11 * s, cy - 6 * s)
          ..lineTo(cx - 11 * s, cy + 2 * s)
          ..close();
        canvas.drawPath(tail, fill);
        canvas.drawPath(tail, outline);
        // tentacles
        final tentPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s;
        for (var i = -1; i <= 1; i++) {
          final tent = Path()
            ..moveTo(cx + i * 3 * s, cy + 5 * s)
            ..quadraticBezierTo(
                cx + i * 5 * s, cy + 9 * s, cx + i * 4 * s, cy + 10 * s);
          canvas.drawPath(tent, tentPaint);
        }
        // eye
        canvas.drawCircle(Offset(cx + 4 * s, cy - 3 * s), 2 * s,
            Paint()..color = Colors.white);
        canvas.drawCircle(
            Offset(cx + 4 * s, cy - 3 * s), 1 * s, Paint()..color = _outline);

      case 8: // Bit Rot Behemoth — armored turtle
        // shell
        canvas.drawCircle(Offset(cx, cy - 1 * s), 8 * s, fill);
        canvas.drawCircle(Offset(cx, cy - 1 * s), 8 * s, outline);
        // corruption cracks
        final crackPaint = Paint()
          ..color = const Color(0xFFDAA520)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8 * s;
        canvas.drawLine(Offset(cx - 3 * s, cy - 5 * s),
            Offset(cx + 2 * s, cy + 2 * s), crackPaint);
        canvas.drawLine(Offset(cx + 1 * s, cy - 6 * s),
            Offset(cx - 2 * s, cy + 4 * s), crackPaint);
        // head
        canvas.drawCircle(Offset(cx, cy + 7 * s), 3.5 * s,
            Paint()..color = const Color(0xFF8B8000));
        canvas.drawCircle(Offset(cx, cy + 7 * s), 3.5 * s, outline);

      case 9: // Pixel Punisher — angular geometric
        final diamond = Path()
          ..moveTo(cx, cy - 10 * s)
          ..lineTo(cx + 8 * s, cy)
          ..lineTo(cx, cy + 10 * s)
          ..lineTo(cx - 8 * s, cy)
          ..close();
        canvas.drawPath(diamond, fill);
        canvas.drawPath(diamond, outline);
        // scanning eye
        final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
        canvas.drawCircle(Offset(cx, cy), 3 * s, eyePaint);
        canvas.drawCircle(Offset(cx, cy), 2 * s, Paint()..color = color);
        // pixel grid lines
        final gridPaint = Paint()
          ..color = color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5 * s;
        for (var i = -2; i <= 2; i++) {
          canvas.drawLine(Offset(cx + i * 3 * s, cy - 5 * s),
              Offset(cx + i * 3 * s, cy + 5 * s), gridPaint);
        }

      case 10: // Battery Banshee — thin elongated limbs
        // torso
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy - 1 * s), width: 7 * s, height: 10 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy - 1 * s), width: 7 * s, height: 10 * s),
            outline);
        // limbs
        final limbPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s;
        // arms up (screaming)
        canvas.drawLine(Offset(cx - 4 * s, cy - 4 * s),
            Offset(cx - 8 * s, cy - 9 * s), limbPaint);
        canvas.drawLine(Offset(cx + 4 * s, cy - 4 * s),
            Offset(cx + 8 * s, cy - 9 * s), limbPaint);
        // legs
        canvas.drawLine(Offset(cx - 2 * s, cy + 5 * s),
            Offset(cx - 4 * s, cy + 10 * s), limbPaint);
        canvas.drawLine(Offset(cx + 2 * s, cy + 5 * s),
            Offset(cx + 4 * s, cy + 10 * s), limbPaint);
        // battery on chest
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(cx, cy - 1 * s), width: 4 * s, height: 5 * s),
            Paint()..color = const Color(0xFF1A1A1A));
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(cx, cy - 1 * s), width: 3 * s, height: 3 * s),
            Paint()..color = const Color(0xFF00E5FF));

      case 11: // Lag Dragon — winged silhouette
        // body
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 2 * s), width: 10 * s, height: 7 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 2 * s), width: 10 * s, height: 7 * s),
            outline);
        // head
        canvas.drawCircle(Offset(cx + 6 * s, cy - 2 * s), 4 * s, fill);
        canvas.drawCircle(Offset(cx + 6 * s, cy - 2 * s), 4 * s, outline);
        // wings
        final wingL = Path()
          ..moveTo(cx - 2 * s, cy - 1 * s)
          ..lineTo(cx - 10 * s, cy - 9 * s)
          ..lineTo(cx - 4 * s, cy - 3 * s)
          ..close();
        canvas.drawPath(wingL, fill);
        canvas.drawPath(wingL, outline);
        final wingR = Path()
          ..moveTo(cx + 2 * s, cy - 1 * s)
          ..lineTo(cx + 10 * s, cy - 9 * s)
          ..lineTo(cx + 4 * s, cy - 3 * s)
          ..close();
        canvas.drawPath(wingR, fill);
        canvas.drawPath(wingR, outline);
        // tail
        canvas.drawLine(Offset(cx - 5 * s, cy + 4 * s),
            Offset(cx - 9 * s, cy + 7 * s), outline);

      case 12: // Static Phantom — floating orb
        canvas.drawCircle(Offset(cx, cy), 8 * s, fill);
        canvas.drawCircle(Offset(cx, cy), 8 * s, outline);
        // wifi arcs
        final arcPaint = Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 * s;
        for (var i = 1; i <= 3; i++) {
          canvas.drawArc(
              Rect.fromCenter(
                  center: Offset(cx, cy - 2 * s),
                  width: 8 * s * i,
                  height: 8 * s * i),
              -pi * 0.3,
              pi * 0.6,
              false,
              arcPaint);
        }
        // center dot
        canvas.drawCircle(Offset(cx, cy), 2 * s, Paint()..color = _outline);

      case 13: // Exploit Emperor — armored knight
        // helmet
        canvas.drawCircle(Offset(cx, cy - 4 * s), 5 * s, fill);
        canvas.drawCircle(Offset(cx, cy - 4 * s), 5 * s, outline);
        // visor slit
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(cx, cy - 4 * s), width: 6 * s, height: 1.5 * s),
            Paint()..color = _outline);
        // crown
        final crown = Path()
          ..moveTo(cx - 4 * s, cy - 9 * s)
          ..lineTo(cx - 3 * s, cy - 12 * s)
          ..lineTo(cx - 1 * s, cy - 10 * s)
          ..lineTo(cx, cy - 13 * s)
          ..lineTo(cx + 1 * s, cy - 10 * s)
          ..lineTo(cx + 3 * s, cy - 12 * s)
          ..lineTo(cx + 4 * s, cy - 9 * s)
          ..close();
        canvas.drawPath(crown, Paint()..color = const Color(0xFFFF00FF));
        canvas.drawPath(crown, outline);
        // body armor
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(cx, cy + 4 * s), width: 10 * s, height: 10 * s),
            fill);
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset(cx, cy + 4 * s), width: 10 * s, height: 10 * s),
            outline);
        // gem
        canvas.drawCircle(Offset(cx, cy + 2 * s), 2 * s,
            Paint()..color = const Color(0xFFFF00FF));

      case 14: // Packet Storm — three-headed hydra
        final colors = [
          const Color(0xFFFF4444),
          const Color(0xFF00CCDD),
          const Color(0xFF00FF88),
        ];
        for (var i = -1; i <= 1; i++) {
          // head
          canvas.drawCircle(Offset(cx + i * 6 * s, cy - 5 * s), 3.5 * s,
              Paint()..color = colors[i + 1]);
          canvas.drawCircle(
              Offset(cx + i * 6 * s, cy - 5 * s), 3.5 * s, outline);
          // eye
          canvas.drawCircle(Offset(cx + i * 6 * s, cy - 5 * s), 1.2 * s,
              Paint()..color = _outline);
          // neck
          final neckPaint = Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * s;
          canvas.drawLine(Offset(cx + i * 6 * s, cy - 2 * s),
              Offset(cx + i * 2 * s, cy + 4 * s), neckPaint);
        }
        // shared body
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 6 * s), width: 12 * s, height: 6 * s),
            fill);
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(cx, cy + 6 * s), width: 12 * s, height: 6 * s),
            outline);

      default:
        canvas.drawCircle(Offset(cx, cy), 8 * s, fill);
        canvas.drawCircle(Offset(cx, cy), 8 * s, outline);
    }
  }

  @override
  bool shouldRepaint(covariant BossMiniPainter old) =>
      old.visualType != visualType || old.isDefeated != isDefeated;
}

class BossParticlePainter extends CustomPainter {
  final double phase;
  final int visualType;

  BossParticlePainter({required this.phase, required this.visualType});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42 + visualType);
    final baseColor = BossVisuals.particleColor(visualType);

    for (var i = 0; i < 12; i++) {
      final driftX = sin(phase * 1.5 + i * 0.7) * 10;
      final driftY = cos(phase * 1.2 + i * 0.5) * 8;
      final x = (rng.nextDouble() * size.width + driftX) % size.width;
      final y =
          (rng.nextDouble() * size.height + phase * 30 + driftY) % size.height;
      final radius = rng.nextDouble() * 1.5 + 0.5;
      final alpha =
          ((rng.nextDouble() * 25 + 10) * (0.3 + 0.3 * sin(phase * 2 + i)))
              .toInt();

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = baseColor.withValues(alpha: alpha / 255),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BossParticlePainter old) => old.phase != phase;
}

class MonsterPainter extends CustomPainter {
  final int visualType;
  final bool isDefeated;
  final double glowIntensity;
  final double phase;

  static const _accentColors = {
    1: Color(0xFFCC3344),
    2: Color(0xFF00CCDD),
    3: Color(0xFF00FF88),
    4: Color(0xFFFF8800),
    5: Color(0xFFFFCC00),
    6: Color(0xFFFF4444),
    7: Color(0xFF00CCDD),
    8: Color(0xFFFFD700),
    9: Color(0xFFFF00FF),
    10: Color(0xFF00E5FF),
    11: Color(0xFFFF6600),
    12: Color(0xFF00E5FF),
    13: Color(0xFFFF00FF),
    14: Color(0xFF00FF88),
  };

  MonsterPainter({
    required this.visualType,
    required this.isDefeated,
    required this.glowIntensity,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    if (isDefeated) {
      _drawDefeatedMonster(canvas, cx, cy, s);
      return;
    }

    switch (visualType) {
      case 1:
        _drawBoneColossus(canvas, cx, cy, s);
      case 2:
        _drawMemoryWraith(canvas, cx, cy, s);
      case 3:
        _drawKernelWraith(canvas, cx, cy, s);
      case 4:
        _drawFeedbackPhantom(canvas, cx, cy, s);
      case 5:
        _drawInputOverlord(canvas, cx, cy, s);
      case 6:
        _drawDependencyDemon(canvas, cx, cy, s);
      case 7:
        _drawLatencyLeviathan(canvas, cx, cy, s);
      case 8:
        _drawBitRotBehemoth(canvas, cx, cy, s);
      case 9:
        _drawPixelPunisher(canvas, cx, cy, s);
      case 10:
        _drawBatteryBanshee(canvas, cx, cy, s);
      case 11:
        _drawLagDragon(canvas, cx, cy, s);
      case 12:
        _drawStaticPhantom(canvas, cx, cy, s);
      case 13:
        _drawExploitEmperor(canvas, cx, cy, s);
      case 14:
        _drawPacketStorm(canvas, cx, cy, s);
      default:
        _drawBoneColossus(canvas, cx, cy, s);
    }

    if (glowIntensity > 0.5) {
      _drawAura(canvas, cx, cy, s);
    }
  }

  void _drawAura(Canvas canvas, double cx, double cy, double s) {
    final color = _accentColors[visualType] ?? Colors.red;
    final auraPaint = Paint()
      ..color = color.withValues(alpha: 0.18 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(cx, cy), 85 * s, auraPaint);
  }

  void _drawBoneColossus(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Body — broad rectangular torso
    final body = Path()
      ..moveTo(cx - 22 * s, cy + 30 * s)
      ..lineTo(cx - 22 * s, cy - 10 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 25 * s, cx, cy - 28 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 25 * s, cx + 22 * s, cy - 10 * s)
      ..lineTo(cx + 22 * s, cy + 30 * s)
      ..close();
    paint.color = const Color(0xFF5C1010);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Left arm
    final leftArm = Path()
      ..moveTo(cx - 22 * s, cy - 5 * s)
      ..lineTo(cx - 38 * s, cy + 5 * s)
      ..lineTo(cx - 35 * s, cy + 25 * s)
      ..lineTo(cx - 22 * s, cy + 15 * s)
      ..close();
    paint.color = const Color(0xFF4A0C0C);
    canvas.drawPath(leftArm, paint);
    canvas.drawPath(leftArm, outline);
    // Right arm
    final rightArm = Path()
      ..moveTo(cx + 22 * s, cy - 5 * s)
      ..lineTo(cx + 38 * s, cy + 5 * s)
      ..lineTo(cx + 35 * s, cy + 25 * s)
      ..lineTo(cx + 22 * s, cy + 15 * s)
      ..close();
    canvas.drawPath(rightArm, paint);
    canvas.drawPath(rightArm, outline);
    // Head — small dome
    paint.color = const Color(0xFF5C1010);
    canvas.drawCircle(Offset(cx, cy - 35 * s), 12 * s, paint);
    canvas.drawCircle(Offset(cx, cy - 35 * s), 12 * s, outline);
    // Two curved horns
    final hornPaint = Paint()
      ..isAntiAlias = true
      ..color = const Color(0xFFD4C4A8)
      ..style = PaintingStyle.fill;
    final leftHorn = Path()
      ..moveTo(cx - 10 * s, cy - 42 * s)
      ..quadraticBezierTo(cx - 25 * s, cy - 55 * s, cx - 18 * s, cy - 60 * s)
      ..quadraticBezierTo(cx - 12 * s, cy - 55 * s, cx - 6 * s, cy - 42 * s)
      ..close();
    canvas.drawPath(leftHorn, hornPaint);
    canvas.drawPath(leftHorn, outline);
    final rightHorn = Path()
      ..moveTo(cx + 10 * s, cy - 42 * s)
      ..quadraticBezierTo(cx + 25 * s, cy - 55 * s, cx + 18 * s, cy - 60 * s)
      ..quadraticBezierTo(cx + 12 * s, cy - 55 * s, cx + 6 * s, cy - 42 * s)
      ..close();
    canvas.drawPath(rightHorn, hornPaint);
    canvas.drawPath(rightHorn, outline);
    // Three vertical red eyes
    for (var i = 0; i < 3; i++) {
      final eyeY = cy - 40 * s + i * 7 * s;
      paint.color = const Color(0xFFFF0000);
      canvas.drawCircle(Offset(cx, eyeY), 3 * s, paint);
      paint.color = const Color(0xFF1A1A1A);
      canvas.drawCircle(Offset(cx, eyeY), 1.5 * s, paint);
    }
  }

  void _drawMemoryWraith(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Body — serpentine shark
    final body = Path()
      ..moveTo(cx - 20 * s, cy + 30 * s)
      ..quadraticBezierTo(cx - 35 * s, cy + 10 * s, cx - 30 * s, cy - 10 * s)
      ..quadraticBezierTo(cx - 25 * s, cy - 30 * s, cx, cy - 35 * s)
      ..quadraticBezierTo(cx + 25 * s, cy - 30 * s, cx + 30 * s, cy - 10 * s)
      ..quadraticBezierTo(cx + 35 * s, cy + 10 * s, cx + 20 * s, cy + 30 * s)
      ..close();
    paint.color = const Color(0xFF0A2E5C);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Dorsal fin
    final fin = Path()
      ..moveTo(cx - 3 * s, cy - 30 * s)
      ..lineTo(cx, cy - 48 * s)
      ..lineTo(cx + 8 * s, cy - 28 * s)
      ..close();
    paint.color = const Color(0xFF082244);
    canvas.drawPath(fin, paint);
    canvas.drawPath(fin, outline);
    // Massive open jaws
    final jawUpper = Path()
      ..moveTo(cx - 22 * s, cy + 5 * s)
      ..quadraticBezierTo(cx - 15 * s, cy - 5 * s, cx, cy - 8 * s)
      ..quadraticBezierTo(cx + 15 * s, cy - 5 * s, cx + 22 * s, cy + 5 * s)
      ..lineTo(cx + 18 * s, cy + 2 * s)
      ..lineTo(cx - 18 * s, cy + 2 * s)
      ..close();
    paint.color = const Color(0xFF061830);
    canvas.drawPath(jawUpper, paint);
    canvas.drawPath(jawUpper, outline);
    // Teeth
    final teethPaint = Paint()..color = const Color(0xFFF0F0F0);
    for (var i = -2; i <= 2; i++) {
      final tx = cx + i * 7 * s;
      final tooth = Path()
        ..moveTo(tx - 2 * s, cy + 2 * s)
        ..lineTo(tx, cy + 8 * s)
        ..lineTo(tx + 2 * s, cy + 2 * s)
        ..close();
      canvas.drawPath(tooth, teethPaint);
    }
    // Cyan fin tips
    paint.color = const Color(0xFF00CCEE);
    canvas.drawCircle(Offset(cx - 28 * s, cy - 5 * s), 3 * s, paint);
    canvas.drawCircle(Offset(cx + 28 * s, cy - 5 * s), 3 * s, paint);
    // Eyes
    paint.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 10 * s, cy - 18 * s), 5 * s, paint);
    canvas.drawCircle(Offset(cx + 10 * s, cy - 18 * s), 5 * s, paint);
    paint.color = const Color(0xFF0A2E5C);
    canvas.drawCircle(Offset(cx - 10 * s, cy - 18 * s), 2.5 * s, paint);
    canvas.drawCircle(Offset(cx + 10 * s, cy - 18 * s), 2.5 * s, paint);
    // Jaws animate open/close
    final jawOffset = sin(phase * 2) * 3 * s;
    paint.color = const Color(0xFF061830);
    canvas.drawRect(
        Rect.fromLTWH(cx - 18 * s, cy + 2 * s, 36 * s, 4 * s + jawOffset),
        paint);
  }

  void _drawKernelWraith(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Robed body — tall narrow shape
    final robe = Path()
      ..moveTo(cx - 15 * s, cy + 35 * s)
      ..lineTo(cx - 25 * s, cy + 30 * s)
      ..quadraticBezierTo(cx - 28 * s, cy, cx - 18 * s, cy - 25 * s)
      ..quadraticBezierTo(cx - 10 * s, cy - 40 * s, cx, cy - 42 * s)
      ..quadraticBezierTo(cx + 10 * s, cy - 40 * s, cx + 18 * s, cy - 25 * s)
      ..quadraticBezierTo(cx + 28 * s, cy, cx + 25 * s, cy + 30 * s)
      ..lineTo(cx + 15 * s, cy + 35 * s)
      ..close();
    paint.color = const Color(0xFF3A0E5C);
    canvas.drawPath(robe, paint);
    canvas.drawPath(robe, outline);
    // Hood
    final hood = Path()
      ..moveTo(cx - 18 * s, cy - 20 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 38 * s, cx, cy - 45 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 38 * s, cx + 18 * s, cy - 20 * s)
      ..close();
    paint.color = const Color(0xFF2A0A44);
    canvas.drawPath(hood, paint);
    canvas.drawPath(hood, outline);
    // Two green glowing eyes
    paint.color = const Color(0xFF00FF88);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 30 * s), 4 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 30 * s), 4 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 30 * s), 2 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 30 * s), 2 * s, paint);
    // Orbiting rune circle
    final runePaint = Paint()
      ..color = const Color(0xFF00FF88).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    final runeAngle = phase * 1.5;
    final runeRadius = 35 * s;
    final runeX = cx + cos(runeAngle) * runeRadius;
    final runeY = cy - 10 * s + sin(runeAngle) * 10 * s;
    canvas.drawCircle(Offset(runeX, runeY), 5 * s, runePaint);
    paint.color = const Color(0xFF00FF88).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(runeX, runeY), 8 * s, paint);
  }

  void _drawFeedbackPhantom(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Round body
    paint.color = const Color(0xFF2A3040);
    canvas.drawCircle(Offset(cx, cy), 30 * s, paint);
    canvas.drawCircle(Offset(cx, cy), 30 * s, outline);
    // Speaker-cone mouth — concentric circles
    paint.color = const Color(0xFF1A1E28);
    canvas.drawCircle(Offset(cx, cy + 5 * s), 18 * s, paint);
    paint.color = const Color(0xFFFF8800);
    canvas.drawCircle(Offset(cx, cy + 5 * s), 14 * s, paint);
    paint.color = const Color(0xFF1A1E28);
    canvas.drawCircle(Offset(cx, cy + 5 * s), 10 * s, paint);
    paint.color = const Color(0xFFFF8800).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(cx, cy + 5 * s), 6 * s, paint);
    canvas.drawCircle(Offset(cx, cy + 5 * s), 18 * s, outline);
    // Two stubby arms
    paint.color = const Color(0xFF2A3040);
    final leftArm = Path()
      ..moveTo(cx - 28 * s, cy + 5 * s)
      ..lineTo(cx - 40 * s, cy + 15 * s)
      ..lineTo(cx - 35 * s, cy + 25 * s)
      ..lineTo(cx - 25 * s, cy + 15 * s)
      ..close();
    canvas.drawPath(leftArm, paint);
    canvas.drawPath(leftArm, outline);
    final rightArm = Path()
      ..moveTo(cx + 28 * s, cy + 5 * s)
      ..lineTo(cx + 40 * s, cy + 15 * s)
      ..lineTo(cx + 35 * s, cy + 25 * s)
      ..lineTo(cx + 25 * s, cy + 15 * s)
      ..close();
    canvas.drawPath(rightArm, paint);
    canvas.drawPath(rightArm, outline);
    // Eyes
    paint.color = const Color(0xFFFFCC00);
    canvas.drawCircle(Offset(cx - 10 * s, cy - 12 * s), 5 * s, paint);
    canvas.drawCircle(Offset(cx + 10 * s, cy - 12 * s), 5 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 10 * s, cy - 12 * s), 2.5 * s, paint);
    canvas.drawCircle(Offset(cx + 10 * s, cy - 12 * s), 2.5 * s, paint);
    // Sound rings pulse outward
    final ringPaint = Paint()
      ..color = const Color(0xFFFFCC00).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s;
    for (var i = 1; i <= 3; i++) {
      final ringPhase = (phase * 2 + i * 0.8) % 3.0;
      final alpha = (0.3 - ringPhase * 0.1).clamp(0.0, 1.0);
      ringPaint.color = const Color(0xFFFFCC00).withValues(alpha: alpha);
      canvas.drawCircle(
          Offset(cx, cy + 5 * s), (20 + ringPhase * 15) * s, ringPaint);
    }
  }

  void _drawInputOverlord(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Wide flat crab body
    final body = Path()
      ..moveTo(cx - 30 * s, cy + 10 * s)
      ..quadraticBezierTo(cx - 35 * s, cy - 15 * s, cx, cy - 20 * s)
      ..quadraticBezierTo(cx + 35 * s, cy - 15 * s, cx + 30 * s, cy + 10 * s)
      ..quadraticBezierTo(cx, cy + 20 * s, cx - 30 * s, cy + 10 * s);
    paint.color = const Color(0xFF0E3A3A);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // 4 keyboard-key claws (2 per side)
    final clawPaint = Paint()..color = const Color(0xFFFFCC00);
    for (var i = 0; i < 2; i++) {
      final clawY = cy - 8 * s + i * 16 * s;
      // Left claw
      final leftClaw = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 48 * s, clawY - 5 * s, 16 * s, 10 * s),
        Radius.circular(2 * s),
      );
      canvas.drawRRect(leftClaw, clawPaint);
      canvas.drawRRect(leftClaw, outline);
      // Right claw
      final rightClaw = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 32 * s, clawY - 5 * s, 16 * s, 10 * s),
        Radius.circular(2 * s),
      );
      canvas.drawRRect(rightClaw, clawPaint);
      canvas.drawRRect(rightClaw, outline);
      // Claw click animation
      final clickOffset = sin(phase * 3 + i * 1.5) * 2 * s;
      canvas.drawRect(
          Rect.fromLTWH(
              cx - 48 * s + clickOffset, clawY - 5 * s, 16 * s, 10 * s),
          clawPaint);
      canvas.drawRect(
          Rect.fromLTWH(
              cx + 32 * s - clickOffset, clawY - 5 * s, 16 * s, 10 * s),
          clawPaint);
    }
    // Single large cyclops eye
    paint.color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 10 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 5 * s, paint);
    paint.color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(cx - 2 * s, cy - 7 * s), 2 * s, paint);
    // 2 stubby legs
    paint.color = const Color(0xFF0A2E2E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 12 * s, cy + 15 * s, 8 * s, 15 * s),
          Radius.circular(3 * s)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx + 4 * s, cy + 15 * s, 8 * s, 15 * s),
          Radius.circular(3 * s)),
      paint,
    );
  }

  void _drawDependencyDemon(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Tiny body
    final body = Path()
      ..moveTo(cx - 12 * s, cy + 15 * s)
      ..quadraticBezierTo(cx - 18 * s, cy - 5 * s, cx, cy - 10 * s)
      ..quadraticBezierTo(cx + 18 * s, cy - 5 * s, cx + 12 * s, cy + 15 * s)
      ..close();
    paint.color = const Color(0xFF5C1515);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Oversized head
    paint.color = const Color(0xFF6B1A1A);
    canvas.drawCircle(Offset(cx, cy - 22 * s), 18 * s, paint);
    canvas.drawCircle(Offset(cx, cy - 22 * s), 18 * s, outline);
    // 2 small horns
    final hornPaint = Paint()..color = const Color(0xFF3A0A0A);
    final leftHorn = Path()
      ..moveTo(cx - 12 * s, cy - 35 * s)
      ..lineTo(cx - 16 * s, cy - 48 * s)
      ..lineTo(cx - 6 * s, cy - 35 * s)
      ..close();
    canvas.drawPath(leftHorn, hornPaint);
    canvas.drawPath(leftHorn, outline);
    final rightHorn = Path()
      ..moveTo(cx + 12 * s, cy - 35 * s)
      ..lineTo(cx + 16 * s, cy - 48 * s)
      ..lineTo(cx + 6 * s, cy - 35 * s)
      ..close();
    canvas.drawPath(rightHorn, hornPaint);
    canvas.drawPath(rightHorn, outline);
    // Yellow eyes
    paint.color = const Color(0xFFFFCC00);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 25 * s), 5 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 25 * s), 5 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 25 * s), 2.5 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 25 * s), 2.5 * s, paint);
    // Chain links dangling from body
    final chainPaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    for (var i = 0; i < 3; i++) {
      final chainX = cx - 10 * s + i * 10 * s;
      final swing = sin(phase * 2 + i * 1.2) * 5 * s;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(chainX + swing, cy + 25 * s),
            width: 4 * s,
            height: 6 * s),
        chainPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(chainX + swing, cy + 32 * s),
            width: 4 * s,
            height: 6 * s),
        chainPaint,
      );
    }
  }

  void _drawLatencyLeviathan(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Massive whale/squid body
    final body = Path()
      ..moveTo(cx - 35 * s, cy + 10 * s)
      ..quadraticBezierTo(cx - 40 * s, cy - 20 * s, cx - 20 * s, cy - 30 * s)
      ..quadraticBezierTo(cx, cy - 40 * s, cx + 20 * s, cy - 30 * s)
      ..quadraticBezierTo(cx + 40 * s, cy - 20 * s, cx + 35 * s, cy + 10 * s)
      ..quadraticBezierTo(cx, cy + 25 * s, cx - 35 * s, cy + 10 * s);
    paint.color = const Color(0xFF0D0D3B);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // 4 tentacles underneath
    final tentPaint = Paint()
      ..color = const Color(0xFF1A1A5C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final tx = cx - 18 * s + i * 12 * s;
      final tentSwing = sin(phase * 1.5 + i * 0.9) * 8 * s;
      final tentPath = Path()
        ..moveTo(tx, cy + 15 * s)
        ..quadraticBezierTo(
            tx + tentSwing, cy + 35 * s, tx + tentSwing * 0.5, cy + 50 * s);
      canvas.drawPath(tentPath, tentPaint);
    }
    // Cyan data stream trailing behind
    final streamPaint = Paint()
      ..color = const Color(0xFF00CCEE).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    for (var i = 0; i < 5; i++) {
      final sx = cx + 30 * s + i * 8 * s;
      final sy = cy - 15 * s + sin(phase * 2 + i * 0.5) * 5 * s;
      canvas.drawCircle(Offset(sx, sy), 2 * s, streamPaint);
    }
    // Eye
    paint.color = const Color(0xFF00CCEE);
    canvas.drawCircle(Offset(cx - 15 * s, cy - 15 * s), 6 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 15 * s, cy - 15 * s), 3 * s, paint);
  }

  void _drawBitRotBehemoth(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Dome shell
    final shell = Path()
      ..moveTo(cx - 30 * s, cy + 10 * s)
      ..quadraticBezierTo(cx - 35 * s, cy - 25 * s, cx, cy - 30 * s)
      ..quadraticBezierTo(cx + 35 * s, cy - 25 * s, cx + 30 * s, cy + 10 * s)
      ..close();
    paint.color = const Color(0xFF2D2D2D);
    canvas.drawPath(shell, paint);
    canvas.drawPath(shell, outline);
    // Body underneath
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawRect(
        Rect.fromLTWH(cx - 25 * s, cy + 8 * s, 50 * s, 15 * s), paint);
    canvas.drawRect(
        Rect.fromLTWH(cx - 25 * s, cy + 8 * s, 50 * s, 15 * s), outline);
    // Gold corruption cracks — pulse
    final crackPaint = Paint()
      ..color =
          const Color(0xFFFFD700).withValues(alpha: 0.5 + 0.3 * sin(phase * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    final crack1 = Path()
      ..moveTo(cx - 5 * s, cy - 25 * s)
      ..lineTo(cx - 10 * s, cy - 15 * s)
      ..lineTo(cx - 3 * s, cy - 5 * s);
    canvas.drawPath(crack1, crackPaint);
    final crack2 = Path()
      ..moveTo(cx + 8 * s, cy - 22 * s)
      ..lineTo(cx + 12 * s, cy - 12 * s)
      ..lineTo(cx + 5 * s, cy - 2 * s);
    canvas.drawPath(crack2, crackPaint);
    final crack3 = Path()
      ..moveTo(cx - 15 * s, cy - 18 * s)
      ..lineTo(cx - 20 * s, cy - 8 * s);
    canvas.drawPath(crack3, crackPaint);
    // 4 stubby legs
    paint.color = const Color(0xFF1A1A1A);
    for (var i = 0; i < 2; i++) {
      final lx = cx - 18 * s + i * 30 * s;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(lx, cy + 22 * s, 8 * s, 10 * s),
            Radius.circular(2 * s)),
        paint,
      );
    }
    // Head poking out
    paint.color = const Color(0xFF2D2D2D);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 10 * s, paint);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 10 * s, outline);
    // Eyes
    paint.color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(cx - 4 * s, cy - 7 * s), 3 * s, paint);
    canvas.drawCircle(Offset(cx + 4 * s, cy - 7 * s), 3 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 4 * s, cy - 7 * s), 1.5 * s, paint);
    canvas.drawCircle(Offset(cx + 4 * s, cy - 7 * s), 1.5 * s, paint);
  }

  void _drawPixelPunisher(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Angular triangular body
    final body = Path()
      ..moveTo(cx, cy - 35 * s)
      ..lineTo(cx - 30 * s, cy + 25 * s)
      ..lineTo(cx + 30 * s, cy + 25 * s)
      ..close();
    paint.color = const Color(0xFF2A0E4A);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Single large eye with magenta iris
    paint.color = const Color(0xFFFF00FF);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 12 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx, cy - 5 * s), 7 * s, paint);
    // Pixel grid pupil — cyan lines scanning
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * s;
    final scanOffset = (phase * 10) % 14;
    for (var i = -3; i <= 3; i++) {
      final gy = cy - 5 * s + i * 2 * s;
      final gx = cx - 6 * s + scanOffset;
      canvas.drawLine(Offset(gx, gy), Offset(gx + 12 * s, gy), gridPaint);
    }
    for (var i = -3; i <= 3; i++) {
      final gx = cx - 6 * s + i * 2 * s;
      final gy = cy - 5 * s + scanOffset;
      canvas.drawLine(
          Offset(gx, gy - 6 * s), Offset(gx, gy + 6 * s), gridPaint);
    }
    // Sharp edges — small triangles at corners
    paint.color = const Color(0xFF1E0838);
    final edge1 = Path()
      ..moveTo(cx - 30 * s, cy + 25 * s)
      ..lineTo(cx - 40 * s, cy + 30 * s)
      ..lineTo(cx - 28 * s, cy + 30 * s)
      ..close();
    canvas.drawPath(edge1, paint);
    canvas.drawPath(edge1, outline);
    final edge2 = Path()
      ..moveTo(cx + 30 * s, cy + 25 * s)
      ..lineTo(cx + 40 * s, cy + 30 * s)
      ..lineTo(cx + 28 * s, cy + 30 * s)
      ..close();
    canvas.drawPath(edge2, paint);
    canvas.drawPath(edge2, outline);
  }

  void _drawBatteryBanshee(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Thin hunched body
    final body = Path()
      ..moveTo(cx - 15 * s, cy + 30 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 5 * s, cx - 10 * s, cy - 25 * s)
      ..quadraticBezierTo(cx, cy - 35 * s, cx + 10 * s, cy - 25 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 5 * s, cx + 15 * s, cy + 30 * s)
      ..close();
    paint.color = const Color(0xFF0E2A3A);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Battery icon on chest
    final battFill = (sin(phase * 1.5) + 1) / 2;
    paint.color = const Color(0xFF0E1E28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 8 * s, cy - 15 * s, 16 * s, 22 * s),
          Radius.circular(2 * s)),
      paint,
    );
    paint.color = const Color(0xFF00E5FF);
    canvas.drawRect(
        Rect.fromLTWH(cx - 5 * s, cy - 10 * s, 10 * s, 16 * s * battFill),
        paint);
    paint.color = const Color(0xFF00E5FF);
    canvas.drawRect(
        Rect.fromLTWH(cx - 3 * s, cy - 18 * s, 6 * s, 3 * s), paint);
    // Long thin limbs — arms reaching forward
    paint.color = const Color(0xFF0A2030);
    final leftArm = Path()
      ..moveTo(cx - 14 * s, cy - 10 * s)
      ..lineTo(cx - 35 * s, cy - 5 * s)
      ..lineTo(cx - 38 * s, cy + 5 * s)
      ..lineTo(cx - 14 * s, cy)
      ..close();
    canvas.drawPath(leftArm, paint);
    canvas.drawPath(leftArm, outline);
    final rightArm = Path()
      ..moveTo(cx + 14 * s, cy - 10 * s)
      ..lineTo(cx + 35 * s, cy - 5 * s)
      ..lineTo(cx + 38 * s, cy + 5 * s)
      ..lineTo(cx + 14 * s, cy)
      ..close();
    canvas.drawPath(rightArm, paint);
    canvas.drawPath(rightArm, outline);
    // Eyes
    paint.color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(cx - 5 * s, cy - 22 * s), 3 * s, paint);
    canvas.drawCircle(Offset(cx + 5 * s, cy - 22 * s), 3 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 5 * s, cy - 22 * s), 1.5 * s, paint);
    canvas.drawCircle(Offset(cx + 5 * s, cy - 22 * s), 1.5 * s, paint);
  }

  void _drawLagDragon(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Classic dragon body
    final body = Path()
      ..moveTo(cx - 25 * s, cy + 20 * s)
      ..quadraticBezierTo(cx - 30 * s, cy - 10 * s, cx - 15 * s, cy - 25 * s)
      ..quadraticBezierTo(cx, cy - 35 * s, cx + 15 * s, cy - 25 * s)
      ..quadraticBezierTo(cx + 30 * s, cy - 10 * s, cx + 25 * s, cy + 20 * s)
      ..close();
    paint.color = const Color(0xFF0A1530);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // Wings — orange membrane
    final wingPaint = Paint()..color = const Color(0xFFFF6600);
    final leftWing = Path()
      ..moveTo(cx - 20 * s, cy - 15 * s)
      ..lineTo(cx - 45 * s, cy - 35 * s + sin(phase * 1.2) * 5 * s)
      ..lineTo(cx - 38 * s, cy - 15 * s + sin(phase * 1.2) * 3 * s)
      ..lineTo(cx - 30 * s, cy - 25 * s + sin(phase * 1.2) * 4 * s)
      ..lineTo(cx - 20 * s, cy - 10 * s)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    canvas.drawPath(leftWing, outline);
    final rightWing = Path()
      ..moveTo(cx + 20 * s, cy - 15 * s)
      ..lineTo(cx + 45 * s, cy - 35 * s + sin(phase * 1.2 + pi) * 5 * s)
      ..lineTo(cx + 38 * s, cy - 15 * s + sin(phase * 1.2 + pi) * 3 * s)
      ..lineTo(cx + 30 * s, cy - 25 * s + sin(phase * 1.2 + pi) * 4 * s)
      ..lineTo(cx + 20 * s, cy - 10 * s)
      ..close();
    canvas.drawPath(rightWing, wingPaint);
    canvas.drawPath(rightWing, outline);
    // 2 horns
    paint.color = const Color(0xFF0A1530);
    final leftHorn = Path()
      ..moveTo(cx - 8 * s, cy - 28 * s)
      ..lineTo(cx - 14 * s, cy - 42 * s)
      ..lineTo(cx - 3 * s, cy - 28 * s)
      ..close();
    canvas.drawPath(leftHorn, paint);
    canvas.drawPath(leftHorn, outline);
    final rightHorn = Path()
      ..moveTo(cx + 8 * s, cy - 28 * s)
      ..lineTo(cx + 14 * s, cy - 42 * s)
      ..lineTo(cx + 3 * s, cy - 28 * s)
      ..close();
    canvas.drawPath(rightHorn, paint);
    canvas.drawPath(rightHorn, outline);
    // Eyes
    paint.color = const Color(0xFFFF0000);
    canvas.drawCircle(Offset(cx - 8 * s, cy - 18 * s), 4 * s, paint);
    canvas.drawCircle(Offset(cx + 8 * s, cy - 18 * s), 4 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 8 * s, cy - 18 * s), 2 * s, paint);
    canvas.drawCircle(Offset(cx + 8 * s, cy - 18 * s), 2 * s, paint);
    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFF0A1530)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    final tailPath = Path()
      ..moveTo(cx, cy + 20 * s)
      ..quadraticBezierTo(cx + 15 * s, cy + 30 * s,
          cx + 25 * s + sin(phase * 1.5) * 5 * s, cy + 35 * s);
    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawStaticPhantom(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Central orb
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(cx, cy), 20 * s, paint);
    canvas.drawCircle(Offset(cx, cy), 20 * s, outline);
    // Eyes
    paint.color = const Color(0xFF00E5FF);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 3 * s), 5 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 3 * s), 5 * s, paint);
    paint.color = const Color(0xFF1A1A1A);
    canvas.drawCircle(Offset(cx - 7 * s, cy - 3 * s), 2.5 * s, paint);
    canvas.drawCircle(Offset(cx + 7 * s, cy - 3 * s), 2.5 * s, paint);
    // 3 orbiting satellites
    for (var i = 0; i < 3; i++) {
      final angle = phase * 1.8 + i * (2 * pi / 3);
      final satX = cx + cos(angle) * 32 * s;
      final satY = cy + sin(angle) * 32 * s;
      paint.color = const Color(0xFF00E5FF);
      canvas.drawCircle(Offset(satX, satY), 5 * s, paint);
      canvas.drawCircle(Offset(satX, satY), 5 * s, outline);
      // Connection line
      final linePaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1 * s;
      canvas.drawLine(Offset(cx, cy), Offset(satX, satY), linePaint);
    }
    // WiFi arcs above
    final arcPaint = Paint()
      ..color =
          const Color(0xFF00E5FF).withValues(alpha: 0.2 + 0.1 * sin(phase * 2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s;
    for (var i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(cx, cy - 20 * s), radius: (10 + i * 8) * s),
        -pi * 0.8,
        pi * 0.6,
        false,
        arcPaint,
      );
    }
  }

  void _drawExploitEmperor(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Armored torso — rectangular
    final torso = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 18 * s, cy - 15 * s, 36 * s, 40 * s),
      Radius.circular(4 * s),
    );
    paint.color = const Color(0xFF2A2A3A);
    canvas.drawRRect(torso, paint);
    canvas.drawRRect(torso, outline);
    // Helmet — dome with visor slit
    paint.color = const Color(0xFF2A2A3A);
    canvas.drawCircle(Offset(cx, cy - 28 * s), 15 * s, paint);
    canvas.drawCircle(Offset(cx, cy - 28 * s), 15 * s, outline);
    // Visor slit
    final visorPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(cx - 12 * s, cy - 30 * s, 24 * s, 5 * s), visorPaint);
    // Magenta eyes through visor
    paint.color = const Color(0xFFFF00FF);
    canvas.drawCircle(Offset(cx - 5 * s, cy - 28 * s), 2 * s, paint);
    canvas.drawCircle(Offset(cx + 5 * s, cy - 28 * s), 2 * s, paint);
    // Crown
    final crownPaint = Paint()..color = const Color(0xFFFFD700);
    final crown = Path()
      ..moveTo(cx - 12 * s, cy - 40 * s)
      ..lineTo(cx - 10 * s, cy - 50 * s)
      ..lineTo(cx - 5 * s, cy - 43 * s)
      ..lineTo(cx, cy - 52 * s)
      ..lineTo(cx + 5 * s, cy - 43 * s)
      ..lineTo(cx + 10 * s, cy - 50 * s)
      ..lineTo(cx + 12 * s, cy - 40 * s)
      ..close();
    canvas.drawPath(crown, crownPaint);
    canvas.drawPath(crown, outline);
    // Magenta gem in crown
    paint.color = const Color(0xFFFF00FF);
    canvas.drawCircle(Offset(cx, cy - 46 * s), 3 * s, paint);
    // Shield on left
    final shieldPaint = Paint()..color = const Color(0xFF3A3A4A);
    final shield = Path()
      ..moveTo(cx - 30 * s, cy - 10 * s)
      ..lineTo(cx - 30 * s, cy + 15 * s)
      ..quadraticBezierTo(cx - 30 * s, cy + 22 * s, cx - 22 * s, cy + 22 * s)
      ..quadraticBezierTo(cx - 30 * s, cy + 22 * s, cx - 30 * s, cy + 15 * s)
      ..close();
    canvas.drawPath(shield, shieldPaint);
    canvas.drawPath(shield, outline);
    // Sword on right — key-shaped
    final swordPaint = Paint()
      ..color = const Color(0xFFAAAAAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 22 * s, cy - 5 * s),
        Offset(cx + 22 * s, cy + 25 * s), swordPaint);
    canvas.drawLine(Offset(cx + 18 * s, cy + 5 * s),
        Offset(cx + 26 * s, cy + 5 * s), swordPaint);
    // Key teeth at bottom
    canvas.drawLine(Offset(cx + 20 * s, cy + 22 * s),
        Offset(cx + 22 * s, cy + 25 * s), swordPaint);
    canvas.drawLine(Offset(cx + 24 * s, cy + 22 * s),
        Offset(cx + 22 * s, cy + 25 * s), swordPaint);
    // Gem glow pulse on sword
    final gemGlow = Paint()
      ..color =
          const Color(0xFFFF00FF).withValues(alpha: 0.3 + 0.2 * sin(phase * 2));
    canvas.drawCircle(Offset(cx + 22 * s, cy + 5 * s), 4 * s, gemGlow);
  }

  void _drawPacketStorm(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()..isAntiAlias = true;
    final outline = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 3 * s;
    // Thick body
    final body = Path()
      ..moveTo(cx - 25 * s, cy + 25 * s)
      ..quadraticBezierTo(cx - 30 * s, cy - 5 * s, cx - 15 * s, cy - 20 * s)
      ..quadraticBezierTo(cx, cy - 28 * s, cx + 15 * s, cy - 20 * s)
      ..quadraticBezierTo(cx + 30 * s, cy - 5 * s, cx + 25 * s, cy + 25 * s)
      ..close();
    paint.color = const Color(0xFF0D2B1A);
    canvas.drawPath(body, paint);
    canvas.drawPath(body, outline);
    // 3 necks
    paint.color = const Color(0xFF0D2B1A);
    final neckPaint = Paint()
      ..color = const Color(0xFF0D2B1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 * s
      ..strokeCap = StrokeCap.round;
    for (var i = -1; i <= 1; i++) {
      final neckX = cx + i * 12 * s;
      canvas.drawLine(Offset(neckX, cy - 18 * s),
          Offset(neckX + i * 5 * s, cy - 35 * s), neckPaint);
    }
    // 3 distinct heads — different colors
    final headColors = [
      const Color(0xFFFF4444),
      const Color(0xFF4488FF),
      const Color(0xFF44FF44)
    ];
    final eyeColors = [
      const Color(0xFFFFAAAA),
      const Color(0xFFAAAADD),
      const Color(0xAAFFAAAA)
    ];
    for (var i = -1; i <= 1; i++) {
      final headX = cx + i * 18 * s;
      final headY = cy - 40 * s + sin(phase * 2 + i) * 3 * s;
      paint.color = headColors[i + 1];
      canvas.drawCircle(Offset(headX, headY), 12 * s, paint);
      canvas.drawCircle(Offset(headX, headY), 12 * s, outline);
      // Eyes
      paint.color = const Color(0xFF1A1A1A);
      canvas.drawCircle(Offset(headX - 4 * s, headY - 2 * s), 3 * s, paint);
      canvas.drawCircle(Offset(headX + 4 * s, headY - 2 * s), 3 * s, paint);
      paint.color = eyeColors[i + 1];
      canvas.drawCircle(Offset(headX - 4 * s, headY - 2 * s), 1.5 * s, paint);
      canvas.drawCircle(Offset(headX + 4 * s, headY - 2 * s), 1.5 * s, paint);
    }
  }

  void _drawDefeatedMonster(Canvas canvas, double cx, double cy, double s) {
    final paint = Paint()
      ..isAntiAlias = true
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 30 * s, paint);
    paint
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * s;
    canvas.drawLine(Offset(cx - 15 * s, cy - 15 * s),
        Offset(cx + 15 * s, cy + 15 * s), paint);
    canvas.drawLine(Offset(cx + 15 * s, cy - 15 * s),
        Offset(cx - 15 * s, cy + 15 * s), paint);
  }

  @override
  bool shouldRepaint(covariant MonsterPainter old) =>
      old.visualType != visualType ||
      old.isDefeated != isDefeated ||
      old.phase != phase;
}

class ArenaParticlePainter extends CustomPainter {
  final double phase;
  final int visualType;

  ArenaParticlePainter({required this.phase, required this.visualType});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42 + visualType);
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
    final baseColor = colors[(visualType - 1).clamp(0, 13)];

    for (var i = 0; i < 30; i++) {
      final driftX = sin(phase * 1.5 + i * 0.7) * 20;
      final driftY = cos(phase * 1.2 + i * 0.5) * 15;
      final x = (rng.nextDouble() * size.width + driftX) % size.width;
      final y =
          (rng.nextDouble() * size.height + phase * 40 + driftY) % size.height;
      final radius = rng.nextDouble() * 3.0 + 1.0;
      final alpha =
          ((rng.nextDouble() * 80 + 40) * (0.4 + 0.4 * sin(phase * 2 + i)))
              .toInt();

      final paint = Paint()
        ..color = baseColor.withValues(alpha: alpha / 255)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ArenaParticlePainter old) => old.phase != phase;
}
