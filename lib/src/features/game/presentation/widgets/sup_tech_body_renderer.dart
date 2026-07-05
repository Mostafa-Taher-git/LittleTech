import 'dart:math';

import 'package:flutter/material.dart';
import 'package:littletech/src/features/game/constants/skin_tiers.dart';

void drawSupTechBody(Canvas canvas, SkinDefinition skin, double s,
    double bodyTopY, double bodyBotY, double robeShoulderW, double robeBaseW) {
  final bodyPaint = Paint()
    ..color = skin.bodyColor
    ..style = PaintingStyle.fill;
  final isLightBody =
      ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.25 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Drop shadow
  canvas.drawOval(
    Rect.fromCenter(
        center: Offset(0, bodyBotY + 2 * s), width: 22 * s, height: 2.5 * s),
    Paint()
      ..color = Colors.black.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill,
  );

  // Robe body — vertical sides, rounded bottom
  final robePath = Path()
    ..moveTo(-robeShoulderW / 2, bodyTopY)
    ..lineTo(robeShoulderW / 2, bodyTopY)
    ..lineTo(robeShoulderW / 2, bodyBotY)
    ..quadraticBezierTo(5.5 * s, bodyBotY + 2 * s, 0, bodyBotY + 1 * s)
    ..quadraticBezierTo(-5.5 * s, bodyBotY + 2 * s, -robeShoulderW / 2, bodyBotY)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Center robe fold
  final foldPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.10)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5 * s
    ..strokeCap = StrokeCap.round;
  canvas.drawPath(
    Path()
      ..moveTo(0, bodyTopY + 1 * s)
      ..quadraticBezierTo(0.5 * s, (bodyTopY + bodyBotY) / 2, 0, bodyBotY),
    foldPaint,
  );

  // Blue glow at robe bottom
  canvas.drawOval(
    Rect.fromCenter(center: Offset(0, bodyBotY + 1.5 * s), width: 20 * s, height: 4 * s),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
      ).createShader(Rect.fromCenter(center: Offset(0, bodyBotY + 1.5 * s), width: 20 * s, height: 4 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
}

void drawSupTechHead(Canvas canvas, SkinDefinition skin, double s,
    double headCY, double headR, double hoodBaseY,
    double hoodTopR, double hoodBottomR, double hoodPeakY,
    {Color? stripeColor}) {
  final bodyPaint = Paint()
    ..color = skin.bodyColor
    ..style = PaintingStyle.fill;
  final isLightBody =
      ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5 * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Smooth dome hood (cubic bezier matching concept sheet)
  final hoodPath = Path()
    ..moveTo(-hoodBottomR, hoodBaseY)
    ..cubicTo(-hoodBottomR, hoodBaseY - 15 * s,
        -hoodTopR, hoodPeakY + 1 * s, 0, hoodPeakY)
    ..cubicTo(hoodTopR, hoodPeakY + 1 * s,
        hoodBottomR, hoodBaseY - 15 * s, hoodBottomR, hoodBaseY)
    ..quadraticBezierTo(7 * s, 1 * s, 0, -0.5 * s)
    ..quadraticBezierTo(-7 * s, 1 * s, -hoodBottomR, hoodBaseY)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Draw vertical hood stripe at the top center
  final effectiveStripeColor = stripeColor ??
      (isLightBody ? const Color(0xFF64748B) : const Color(0xFF2D3748));
  final stripePaint = Paint()
    ..color = effectiveStripeColor
    ..style = PaintingStyle.fill;
  final stripePath = Path()
    ..moveTo(-1.5 * s, hoodPeakY)
    ..lineTo(1.5 * s, hoodPeakY)
    ..lineTo(1.5 * s, hoodPeakY + 5 * s)
    ..lineTo(-1.5 * s, hoodPeakY + 5 * s)
    ..close();
  canvas.drawPath(stripePath, stripePaint);
  canvas.drawPath(stripePath, outlinePaint);

  // Inner shadow along hood edges
  final innerShadowPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.12)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1 * s
    ..strokeCap = StrokeCap.round;
  final innerPath = Path()
    ..moveTo(-hoodBottomR + 2 * s, hoodBaseY - 1 * s)
    ..quadraticBezierTo(-hoodBottomR + 2 * s, hoodBaseY - 16 * s,
        -hoodTopR + 2 * s, hoodPeakY + 5 * s)
    ..quadraticBezierTo(-8 * s, hoodPeakY + 1 * s, 0, hoodPeakY + 1 * s)
    ..quadraticBezierTo(8 * s, hoodPeakY + 1 * s,
        hoodTopR - 2 * s, hoodPeakY + 5 * s)
    ..quadraticBezierTo(hoodBottomR - 2 * s, hoodBaseY - 16 * s,
        hoodBottomR - 2 * s, hoodBaseY - 1 * s);
  canvas.drawPath(innerPath, innerShadowPaint);

  // Subtle highlight along top of hood dome
  final highlightPaint = Paint()
    ..color = skin.accentColor.withValues(alpha: 0.15)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.75 * s
    ..strokeCap = StrokeCap.round;
  canvas.drawPath(
    Path()
      ..moveTo(-8 * s, hoodPeakY + 3 * s)
      ..quadraticBezierTo(-headR / 2, hoodPeakY - 1.5 * s, 0, hoodPeakY - 0.5 * s)
      ..quadraticBezierTo(headR / 2, hoodPeakY - 1.5 * s, 8 * s, hoodPeakY + 3 * s),
    highlightPaint,
  );
}

void drawSupTechStar(Canvas canvas, Offset center, double r, Paint paint) {
  final path = Path();
  for (var i = 0; i < 5; i++) {
    final angle = i * 2 * pi / 5 - pi / 2;
    final innerAngle = angle + pi / 5;
    final outerR = r;
    final innerR = r * 0.4;
    if (i == 0) {
      path.moveTo(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle));
    } else {
      path.lineTo(center.dx + outerR * cos(angle), center.dy + outerR * sin(angle));
    }
    path.lineTo(center.dx + innerR * cos(innerAngle), center.dy + innerR * sin(innerAngle));
  }
  path.close();
  canvas.drawPath(path, paint);
}

void drawSupTechNinjaVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14 * s), width: 18 * s, height: 2 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Slim robe body
  final robePath = Path()
    ..moveTo(-6 * s, -1 * s)
    ..lineTo(6 * s, -1 * s)
    ..quadraticBezierTo(8 * s, 5 * s, 9 * s, 12 * s)
    ..quadraticBezierTo(4.5 * s, 13.5 * s, 0, 13 * s)
    ..quadraticBezierTo(-4.5 * s, 13.5 * s, -9 * s, 12 * s)
    ..quadraticBezierTo(-8 * s, 5 * s, -6 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Tight flat hood — lower dome, wider base
  final hoodPath = Path()
    ..moveTo(-12 * s, -3 * s)
    ..cubicTo(-12 * s, -16 * s, -9 * s, -25 * s, 0, -28 * s)
    ..cubicTo(9 * s, -25 * s, 12 * s, -16 * s, 12 * s, -3 * s)
    ..quadraticBezierTo(6 * s, 0.5 * s, 0, 0 * s)
    ..quadraticBezierTo(-6 * s, 0.5 * s, -12 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Center robe fold
  final foldPaint = Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.stroke..strokeWidth = 0.5 * s..strokeCap = StrokeCap.round;
  canvas.drawPath(Path()..moveTo(0, 0)..quadraticBezierTo(0.5 * s, 6 * s, -0.5 * s, 12 * s), foldPaint);

  // Bottom glow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 13.5 * s), width: 16 * s, height: 3 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
    ).createShader(Rect.fromCenter(center: Offset(0, 13.5 * s), width: 16 * s, height: 3 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
}

void drawSupTechWizardVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 15 * s), width: 26 * s, height: 2.5 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Wide flowing robe
  final robePath = Path()
    ..moveTo(-8 * s, -1 * s)
    ..lineTo(8 * s, -1 * s)
    ..quadraticBezierTo(12 * s, 5 * s, 14 * s, 13 * s)
    ..quadraticBezierTo(7 * s, 15 * s, 0, 14 * s)
    ..quadraticBezierTo(-7 * s, 15 * s, -14 * s, 13 * s)
    ..quadraticBezierTo(-12 * s, 5 * s, -8 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Stars pattern on robe
  final starPaint = Paint()..color = skin.accentColor.withValues(alpha: 0.3)..style = PaintingStyle.fill;
  for (final pos in [Offset(-4 * s, 5 * s), Offset(3 * s, 8 * s), Offset(-2 * s, 11 * s)]) {
    drawSupTechStar(canvas, pos, 1.2 * s, starPaint);
  }

  // Tall hood with pointed top
  final hoodPath = Path()
    ..moveTo(-13 * s, -3 * s)
    ..cubicTo(-13 * s, -16 * s, -8 * s, -28 * s, 0, -32 * s)
    ..cubicTo(8 * s, -28 * s, 13 * s, -16 * s, 13 * s, -3 * s)
    ..quadraticBezierTo(7 * s, 1 * s, 0, -0.5 * s)
    ..quadraticBezierTo(-7 * s, 1 * s, -13 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Center robe fold
  final foldPaint = Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.stroke..strokeWidth = 0.5 * s..strokeCap = StrokeCap.round;
  canvas.drawPath(Path()..moveTo(0, 0)..quadraticBezierTo(0.5 * s, 6 * s, -0.5 * s, 12 * s), foldPaint);

  // Bottom glow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14.5 * s), width: 24 * s, height: 4 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
    ).createShader(Rect.fromCenter(center: Offset(0, 14.5 * s), width: 24 * s, height: 4 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
}

void drawSupTechTechVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14 * s), width: 22 * s, height: 2.5 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Medium robe
  final robePath = Path()
    ..moveTo(-7 * s, -1 * s)
    ..lineTo(7 * s, -1 * s)
    ..quadraticBezierTo(9 * s, 5 * s, 10 * s, 12 * s)
    ..quadraticBezierTo(5 * s, 14 * s, 0, 13 * s)
    ..quadraticBezierTo(-5 * s, 14 * s, -10 * s, 12 * s)
    ..quadraticBezierTo(-9 * s, 5 * s, -7 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Circuit lines on robe
  final circuitPaint = Paint()..color = skin.accentColor.withValues(alpha: 0.25)..style = PaintingStyle.stroke..strokeWidth = 0.4 * s..strokeCap = StrokeCap.round;
  canvas.drawLine(Offset(-3 * s, 2 * s), Offset(-3 * s, 8 * s), circuitPaint);
  canvas.drawLine(Offset(-3 * s, 8 * s), Offset(0, 10 * s), circuitPaint);
  canvas.drawLine(Offset(3 * s, 3 * s), Offset(3 * s, 7 * s), circuitPaint);
  canvas.drawLine(Offset(3 * s, 7 * s), Offset(1 * s, 9 * s), circuitPaint);
  // Circuit nodes
  for (final pos in [Offset(-3 * s, 8 * s), Offset(0, 10 * s), Offset(3 * s, 7 * s), Offset(1 * s, 9 * s)]) {
    canvas.drawCircle(pos, 0.8 * s, Paint()..color = skin.accentColor.withValues(alpha: 0.4));
  }

  // Hoodie hood — slightly wider, with hood lip at bottom
  final hoodPath = Path()
    ..moveTo(-13 * s, -3 * s)
    ..cubicTo(-13 * s, -17 * s, -10 * s, -26 * s, 0, -28 * s)
    ..cubicTo(10 * s, -26 * s, 13 * s, -17 * s, 13 * s, -3 * s)
    ..quadraticBezierTo(7 * s, 1.5 * s, 0, 1 * s)
    ..quadraticBezierTo(-7 * s, 1.5 * s, -13 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Hood lip / collar line
  canvas.drawPath(
    Path()
      ..moveTo(-10 * s, -2 * s)
      ..quadraticBezierTo(-5 * s, 2 * s, 0, 1 * s)
      ..quadraticBezierTo(5 * s, 2 * s, 10 * s, -2 * s),
    Paint()..color = skin.accentColor.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 0.75 * s..strokeCap = StrokeCap.round,
  );

  // Bottom glow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 13.5 * s), width: 18 * s, height: 3.5 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
    ).createShader(Rect.fromCenter(center: Offset(0, 13.5 * s), width: 18 * s, height: 3.5 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
}

void drawSupTechArmoredVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
  final platePaint = Paint()..color = skin.accentColor.withValues(alpha: 0.3)..style = PaintingStyle.fill;
  final plateOutline = Paint()..color = Colors.black87..style = PaintingStyle.stroke..strokeWidth = 0.4 * s;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 15 * s), width: 26 * s, height: 3 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Bulky robe
  final robePath = Path()
    ..moveTo(-9 * s, -1 * s)
    ..lineTo(9 * s, -1 * s)
    ..quadraticBezierTo(11 * s, 6 * s, 12 * s, 13 * s)
    ..quadraticBezierTo(6 * s, 15 * s, 0, 14 * s)
    ..quadraticBezierTo(-6 * s, 15 * s, -12 * s, 13 * s)
    ..quadraticBezierTo(-11 * s, 6 * s, -9 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Shoulder plates
  for (final dir in [-1, 1]) {
    final platePath = Path()
      ..moveTo(dir * 8 * s, 0)
      ..lineTo(dir * 13 * s, 1 * s)
      ..lineTo(dir * 12 * s, 5 * s)
      ..lineTo(dir * 8 * s, 4 * s)
      ..close();
    canvas.drawPath(platePath, platePaint);
    canvas.drawPath(platePath, plateOutline);
  }

  // Chest plate
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, 4 * s), width: 8 * s, height: 6 * s), Radius.circular(1.5 * s)),
    platePaint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(0, 4 * s), width: 8 * s, height: 6 * s), Radius.circular(1.5 * s)),
    plateOutline,
  );

  // Helmet hood — angular, armored
  final hoodPath = Path()
    ..moveTo(-14 * s, -3 * s)
    ..lineTo(-12 * s, -20 * s)
    ..lineTo(-4 * s, -28 * s)
    ..lineTo(0, -29 * s)
    ..lineTo(4 * s, -28 * s)
    ..lineTo(12 * s, -20 * s)
    ..lineTo(14 * s, -3 * s)
    ..quadraticBezierTo(7 * s, 1 * s, 0, -0.5 * s)
    ..quadraticBezierTo(-7 * s, 1 * s, -14 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Helmet ridge
  canvas.drawLine(Offset(0, -29 * s), Offset(0, -10 * s),
    Paint()..color = skin.accentColor..style = PaintingStyle.stroke..strokeWidth = 1 * s..strokeCap = StrokeCap.round);

  // Bottom glow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14.5 * s), width: 22 * s, height: 4 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
    ).createShader(Rect.fromCenter(center: Offset(0, 14.5 * s), width: 22 * s, height: 4 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
}

void drawSupTechPhoenixVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14 * s), width: 24 * s, height: 2.5 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Wing cape (behind body)
  final wingPaint = Paint()..color = skin.accentColor.withValues(alpha: 0.35)..style = PaintingStyle.fill;
  // Left wing
  final leftWing = Path()
    ..moveTo(-7 * s, 0)
    ..quadraticBezierTo(-18 * s, -5 * s, -20 * s, 5 * s)
    ..quadraticBezierTo(-16 * s, 10 * s, -10 * s, 12 * s)
    ..close();
  canvas.drawPath(leftWing, wingPaint);
  canvas.drawPath(leftWing, Paint()..color = skin.accentColor..style = PaintingStyle.stroke..strokeWidth = 0.4 * s);
  // Right wing
  final rightWing = Path()
    ..moveTo(7 * s, 0)
    ..quadraticBezierTo(18 * s, -5 * s, 20 * s, 5 * s)
    ..quadraticBezierTo(16 * s, 10 * s, 10 * s, 12 * s)
    ..close();
  canvas.drawPath(rightWing, wingPaint);
  canvas.drawPath(rightWing, Paint()..color = skin.accentColor..style = PaintingStyle.stroke..strokeWidth = 0.4 * s);

  // Flame-like robe bottom
  final robePath = Path()
    ..moveTo(-7 * s, -1 * s)
    ..lineTo(7 * s, -1 * s)
    ..quadraticBezierTo(9 * s, 5 * s, 10 * s, 11 * s)
    ..quadraticBezierTo(7 * s, 13 * s, 4 * s, 11 * s)
    ..quadraticBezierTo(2 * s, 14 * s, 0, 12 * s)
    ..quadraticBezierTo(-2 * s, 14 * s, -4 * s, 11 * s)
    ..quadraticBezierTo(-7 * s, 13 * s, -10 * s, 11 * s)
    ..quadraticBezierTo(-9 * s, 5 * s, -7 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Default dome hood
  final hoodPath = Path()
    ..moveTo(-13 * s, -3 * s)
    ..cubicTo(-13 * s, -18 * s, -10 * s, -27 * s, 0, -28 * s)
    ..cubicTo(10 * s, -27 * s, 13 * s, -18 * s, 13 * s, -3 * s)
    ..quadraticBezierTo(7 * s, 1 * s, 0, -0.5 * s)
    ..quadraticBezierTo(-7 * s, 1 * s, -13 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Bottom glow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 13 * s), width: 20 * s, height: 4 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor],
    ).createShader(Rect.fromCenter(center: Offset(0, 13 * s), width: 20 * s, height: 4 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
}

void drawSupTechVoidVariant(Canvas canvas, SkinDefinition skin, double s) {
  final bodyPaint = Paint()..color = skin.bodyColor..style = PaintingStyle.fill;
  final isLightBody = ThemeData.estimateBrightnessForColor(skin.bodyColor) == Brightness.light;
  final outlinePaint = Paint()
    ..color = isLightBody ? const Color(0xFF94A3B8) : Colors.black87
    ..style = PaintingStyle.stroke..strokeWidth = 1.25 * s..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

  // Shadow
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 14 * s), width: 22 * s, height: 2.5 * s),
    Paint()..color = Colors.black.withValues(alpha: 0.10)..style = PaintingStyle.fill);

  // Wispy robe — irregular bottom edge
  final robePath = Path()
    ..moveTo(-7 * s, -1 * s)
    ..lineTo(7 * s, -1 * s)
    ..quadraticBezierTo(10 * s, 5 * s, 11 * s, 10 * s)
    ..quadraticBezierTo(8 * s, 12 * s, 5 * s, 10 * s)
    ..quadraticBezierTo(2 * s, 14 * s, 0, 11 * s)
    ..quadraticBezierTo(-2 * s, 14 * s, -5 * s, 10 * s)
    ..quadraticBezierTo(-8 * s, 12 * s, -11 * s, 10 * s)
    ..quadraticBezierTo(-10 * s, 5 * s, -7 * s, -1 * s)
    ..close();
  canvas.drawPath(robePath, bodyPaint);
  canvas.drawPath(robePath, outlinePaint);

  // Void wisps (floating particles)
  final wispPaint = Paint()..style = PaintingStyle.fill;
  final rng = skin.id.length;
  for (var i = 0; i < 5; i++) {
    final wx = (-6 + i * 3) * s;
    final wy = (2 + (rng + i) % 5 * 2) * s;
    final wr = (0.8 + (i % 3) * 0.4) * s;
    wispPaint.color = skin.accentColor.withValues(alpha: 0.2 + (i % 3) * 0.1);
    canvas.drawCircle(Offset(wx, wy), wr, wispPaint);
  }

  // Default dome hood
  final hoodPath = Path()
    ..moveTo(-13 * s, -3 * s)
    ..cubicTo(-13 * s, -18 * s, -10 * s, -27 * s, 0, -28 * s)
    ..cubicTo(10 * s, -27 * s, 13 * s, -18 * s, 13 * s, -3 * s)
    ..quadraticBezierTo(7 * s, 1 * s, 0, -0.5 * s)
    ..quadraticBezierTo(-7 * s, 1 * s, -13 * s, -3 * s)
    ..close();
  canvas.drawPath(hoodPath, bodyPaint);
  canvas.drawPath(hoodPath, outlinePaint);

  // Bottom glow (extra ethereal)
  canvas.drawOval(Rect.fromCenter(center: Offset(0, 13 * s), width: 22 * s, height: 5 * s),
    Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [skin.accentColor.withValues(alpha: 0.0), skin.accentColor.withValues(alpha: 0.6)],
    ).createShader(Rect.fromCenter(center: Offset(0, 13 * s), width: 22 * s, height: 5 * s))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
}

/// Draws the body+hood for a given [variant].
/// Returns true if a body was drawn. For [SkinVariant.default_],
/// call [drawSupTechBody] and [drawSupTechHead] separately instead.
bool drawSupTechBodyVariant(Canvas canvas, SkinDefinition skin, double s, SkinVariant variant) {
  switch (variant) {
    case SkinVariant.ninja:
      drawSupTechNinjaVariant(canvas, skin, s);
      return true;
    case SkinVariant.wizard:
      drawSupTechWizardVariant(canvas, skin, s);
      return true;
    case SkinVariant.tech:
      drawSupTechTechVariant(canvas, skin, s);
      return true;
    case SkinVariant.armored:
      drawSupTechArmoredVariant(canvas, skin, s);
      return true;
    case SkinVariant.phoenix:
      drawSupTechPhoenixVariant(canvas, skin, s);
      return true;
    case SkinVariant.void_:
      drawSupTechVoidVariant(canvas, skin, s);
      return true;
    case SkinVariant.default_:
      return false;
  }
}
