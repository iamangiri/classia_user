import 'dart:math';
import 'package:flutter/material.dart';

class HorseRidingPainter extends CustomPainter {
  final double animationValue;
HorseRidingPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Paints
    final horsePaint = Paint()..color = Colors.brown.shade700;
    final riderPaint = Paint()..color = Colors.black87;

    // Center & bounce
    final cx = size.width / 2 + sin(animationValue * 2 * pi) * 10;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);

    // 1) Draw horse silhouette
    final horsePath = Path();
    horsePath.moveTo(-80, 20);
    // body (oval-ish)
    horsePath.cubicTo(-80, -20, 80, -20, 80, 20);
    horsePath.cubicTo(80, 40, -80, 40, -80, 20);
    // neck
    horsePath.moveTo(80, 20);
    horsePath.cubicTo(90, 10, 110, -10, 120, -30);
    // head
    horsePath.cubicTo(125, -35, 130, -45, 125, -50);
    horsePath.cubicTo(120, -55, 110, -50, 105, -45);
    // front leg 1
    horsePath.moveTo(20, 20);
    horsePath.lineTo(30, 60 + 5 * sin(animationValue * 2*pi));
    // front leg 2
    horsePath.moveTo(40, 20);
    horsePath.lineTo(50, 60 - 5 * sin(animationValue * 2*pi));
    // hind leg 1
    horsePath.moveTo(-20, 20);
    horsePath.lineTo(-30, 60 - 5 * sin(animationValue * 2*pi));
    // hind leg 2
    horsePath.moveTo(-40, 20);
    horsePath.lineTo(-50, 60 + 5 * sin(animationValue * 2*pi));
    // tail
    horsePath.moveTo(-80, 20);
    horsePath.cubicTo(-95, 10, -110, 5, -100, 25);

    canvas.drawPath(horsePath, horsePaint..style = PaintingStyle.fill);

    // 2) Draw rider silhouette
    final riderPath = Path();
    // torso
    riderPath.moveTo(0, -30);
    riderPath.lineTo(0, -60);
    // arms
    riderPath.moveTo(0, -50);
    riderPath.lineTo(-15, -40);
    riderPath.moveTo(0, -50);
    riderPath.lineTo(15, -40);
    // legs draped on horse
    riderPath.moveTo(0, -30);
    riderPath.lineTo(-20, -10);
    riderPath.moveTo(0, -30);
    riderPath.lineTo(20, -10);
    // head
    riderPath.addOval(Rect.fromCircle(center: Offset(0, -70), radius: 10));

    canvas.drawPath(riderPath, riderPaint..style = PaintingStyle.fill);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HorseRidingPainter old) =>
      old.animationValue != animationValue;
}
