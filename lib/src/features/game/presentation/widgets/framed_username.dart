import 'dart:math';
import 'package:flutter/material.dart';
import 'package:littletech/src/core/constants/design_tokens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:littletech/src/features/game/constants/reward_pool.dart';
import 'package:littletech/src/features/game/domain/cubit/game_cubit.dart';

class FramedUsername extends StatelessWidget {
  final String username;
  final double fontSize;
  final Color fontColor;
  final TextAlign textAlign;
  final FontWeight fontWeight;

  const FramedUsername({
    super.key,
    required this.username,
    this.fontSize = 16,
    this.fontColor = Colors.white,
    this.textAlign = TextAlign.start,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (_, state) {
        final progress = state.progress;
        final activeFrame = progress.activeFrameId != null
            ? RewardPool.byId(progress.activeFrameId!)
            : null;
        final activeIcon = progress.activeIconId != null
            ? RewardPool.byId(progress.activeIconId!)
            : null;
        final activeTitle = progress.activeTitleId != null
            ? RewardPool.byId(progress.activeTitleId!)
            : null;

        final usernameText = Text(
          username,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: fontColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        );

        final hasBadge = activeIcon != null || activeTitle != null;
        final badgeColor = activeFrame?.color ?? Colors.white54;

        if (activeFrame == null && !hasBadge) return usernameText;

        final frameId = activeFrame?.id ?? '';

        return _FrameWidget(
          frameId: frameId,
          color: badgeColor,
          child: Column(
            crossAxisAlignment: textAlign == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              usernameText,
              if (hasBadge) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (activeIcon != null)
                      Text(
                        activeIcon.value,
                        style: TextStyle(
                          fontSize: fontSize * 0.75,
                          color: badgeColor,
                        ),
                      ),
                    if (activeIcon != null && activeTitle != null)
                      const SizedBox(width: 4),
                    if (activeTitle != null)
                      Text(
                        activeTitle.value,
                        style: TextStyle(
                          fontSize: fontSize * 0.65,
                          color: badgeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FrameWidget extends StatelessWidget {
  final String frameId;
  final Color color;
  final Widget child;

  const _FrameWidget({
    required this.frameId,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FramePainter(frameId: frameId, color: color),
      child: Container(
        padding: _getPadding(),
        child: child,
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (frameId) {
      case 'frame_simple':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case 'frame_dotted':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case 'frame_tech':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case 'frame_circuit':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case 'frame_neon':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case 'frame_cyber':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case 'frame_glitch':
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case 'frame_binary':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case 'frame_legendary':
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case 'frame_dragon':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case 'frame_platinum':
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      default:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }
}

class _FramePainter extends CustomPainter {
  final String frameId;
  final Color color;

  _FramePainter({required this.frameId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    switch (frameId) {
      case 'frame_simple':
        _paintSimple(canvas, size);
        break;
      case 'frame_dotted':
        _paintDotted(canvas, size);
        break;
      case 'frame_tech':
        _paintTech(canvas, size);
        break;
      case 'frame_circuit':
        _paintCircuit(canvas, size);
        break;
      case 'frame_neon':
        _paintNeon(canvas, size);
        break;
      case 'frame_cyber':
        _paintCyber(canvas, size);
        break;
      case 'frame_glitch':
        _paintGlitch(canvas, size);
        break;
      case 'frame_binary':
        _paintBinary(canvas, size);
        break;
      case 'frame_legendary':
        _paintLegendary(canvas, size);
        break;
      case 'frame_dragon':
        _paintDragon(canvas, size);
        break;
      case 'frame_platinum':
        _paintPlatinum(canvas, size);
        break;
      default:
        _paintSimple(canvas, size);
    }
  }

  void _paintSimple(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _paintDotted(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);

    // Add dots at corners
    final dotPaint = Paint()..color = color;
    const dotRadius = 3.0;
    canvas.drawCircle(const Offset(Radii.md, 0), dotRadius, dotPaint);
    canvas.drawCircle(Offset(size.width - Radii.md, 0), dotRadius, dotPaint);
    canvas.drawCircle(const Offset(0, Radii.md), dotRadius, dotPaint);
    canvas.drawCircle(Offset(size.width, Radii.md), dotRadius, dotPaint);
    canvas.drawCircle(Offset(0, size.height - Radii.md), dotRadius, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height - Radii.md), dotRadius, dotPaint);
    canvas.drawCircle(Offset(Radii.md, size.height), dotRadius, dotPaint);
    canvas.drawCircle(Offset(size.width - Radii.md, size.height), dotRadius, dotPaint);
  }

  void _paintTech(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);

    // Corner brackets
    final bracketPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;

    const bracketSize = 12.0;
    const offset = 4.0;

    // Top-left
    canvas.drawLine(const Offset(offset, offset + bracketSize), const Offset(offset, offset), bracketPaint);
    canvas.drawLine(const Offset(offset, offset), const Offset(offset + bracketSize, offset), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - offset - bracketSize, offset), Offset(size.width - offset, offset), bracketPaint);
    canvas.drawLine(Offset(size.width - offset, offset), Offset(size.width - offset, offset + bracketSize), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(offset, size.height - offset - bracketSize), Offset(offset, size.height - offset), bracketPaint);
    canvas.drawLine(Offset(offset, size.height - offset), Offset(offset + bracketSize, size.height - offset), bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - offset - bracketSize, size.height - offset), Offset(size.width - offset, size.height - offset), bracketPaint);
    canvas.drawLine(Offset(size.width - offset, size.height - offset - bracketSize), Offset(size.width - offset, size.height - offset), bracketPaint);
  }

  void _paintCircuit(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background grid
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 8.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Circuit traces
    final tracePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.15, size.height * 0.3)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.7);

    canvas.drawPath(path, tracePaint);

    // Vias (dots at junctions)
    final viaPaint = Paint()..color = color;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.3), 3, viaPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), 3, viaPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 3, viaPaint);

    // Border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _paintNeon(Canvas canvas, Size size) {
    // Outer glow
    for (var i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1 * (4 - i))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + i * 2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 3.0);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(Radii.md),
      );
      canvas.drawRRect(rrect, glowPaint);
    }

    // Main border
    final mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, mainPaint);

    // Inner highlight
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerRrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      const Radius.circular(Radii.md - 2),
    );
    canvas.drawRRect(innerRrect, innerPaint);
  }

  void _paintCyber(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Grid pattern
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 6.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Highlight cells
    final cellPaint = Paint()..color = color.withValues(alpha: 0.3);
    final rng = Random(42);
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        if (rng.nextDouble() > 0.85) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, gridSize, gridSize),
            cellPaint,
          );
        }
      }
    }

    // Border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);
  }

  void _paintGlitch(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);

    // Glitch slices
    final rng = Random(42);
    final slicePaint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final y = rng.nextDouble() * size.height;
      final h = 1.0 + rng.nextDouble() * 2;
      final offset = (rng.nextDouble() - 0.5) * 6;

      slicePaint.color = color.withValues(alpha: 0.2 + rng.nextDouble() * 0.3);
      canvas.drawRect(
        Rect.fromLTWH(offset, y, size.width, h),
        slicePaint,
      );
    }

    // RGB shift lines
    final shiftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    shiftPaint.color = Colors.red.withValues(alpha: 0.3);
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      shiftPaint,
    );

    shiftPaint.color = Colors.green.withValues(alpha: 0.3);
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
      shiftPaint,
    );

    shiftPaint.color = Colors.blue.withValues(alpha: 0.3);
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      shiftPaint,
    );
  }

  void _paintBinary(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);

    // Binary pattern
    final textPainter = TextPainter(
      text: TextSpan(
        text: '01001010 10110101 01110010 11001010',
        style: TextStyle(
          color: color.withValues(alpha: 0.2),
          fontSize: 8,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(8, 4));
    textPainter.paint(canvas, Offset(8, size.height - 16));

    // Corner markers
    final markerPaint = Paint()..color = color;
    canvas.drawRect(const Rect.fromLTWH(4, 4, 4, 4), markerPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 8, 4, 4, 4), markerPaint);
    canvas.drawRect(Rect.fromLTWH(4, size.height - 8, 4, 4), markerPaint);
    canvas.drawRect(Rect.fromLTWH(size.width - 8, size.height - 8, 4, 4), markerPaint);
  }

  void _paintLegendary(Canvas canvas, Size size) {
    // Golden glow
    for (var i = 3; i >= 0; i--) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15 * (4 - i))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + i * 2
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, i * 4.0);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(Radii.md),
      );
      canvas.drawRRect(rrect, glowPaint);
    }

    // Main border with gradient effect
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, paint);

    // Stars at corners
    final starPaint = Paint()..color = color;
    _drawStar(canvas, const Offset(10, 10), 6, starPaint);
    _drawStar(canvas, Offset(size.width - 10, 10), 6, starPaint);
    _drawStar(canvas, Offset(10, size.height - 10), 6, starPaint);
    _drawStar(canvas, Offset(size.width - 10, size.height - 10), 6, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const points = 5;
    final outerRadius = size;
    final innerRadius = size * 0.4;

    for (var i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final offset = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintDragon(Canvas canvas, Size size) {
    // Fire gradient background
    final firePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
          Colors.orange.withValues(alpha: 0.2),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, firePaint);

    // Flame shapes at bottom
    final flamePaint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    path.moveTo(0, size.height);
    for (var x = 0.0; x < size.width; x += 10) {
      final height = 5 + sin(x * 0.3) * 3 + sin(x * 0.7) * 2;
      path.lineTo(x, size.height - height);
    }
    path.lineTo(size.width, size.height);
    path.close();

    flamePaint.color = color.withValues(alpha: 0.4);
    canvas.drawPath(path, flamePaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect, borderPaint);
  }

  void _paintPlatinum(Canvas canvas, Size size) {
    // Silver gradient
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(Radii.md),
    );
    canvas.drawRRect(rrect, gradientPaint);

    // Main border
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect, paint);

    // Inner shine line
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shinePath = Path()
      ..moveTo(size.width * 0.2, 2)
      ..quadraticBezierTo(size.width * 0.5, 6, size.width * 0.8, 2);

    canvas.drawPath(shinePath, shinePaint);

    // Diamond accent
    final diamondPaint = Paint()..color = color;
    final diamondPath = Path()
      ..moveTo(size.width / 2, 4)
      ..lineTo(size.width / 2 + 5, 10)
      ..lineTo(size.width / 2, 16)
      ..lineTo(size.width / 2 - 5, 10)
      ..close();

    canvas.drawPath(diamondPath, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.frameId != frameId || old.color != color;
}
