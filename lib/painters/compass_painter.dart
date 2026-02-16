import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  final double heading;
  final double qiblah;
  final double size;
  final Color primaryColor; // Tambahkan ini agar dinamis

  CompassPainter({
    required this.heading,
    required this.qiblah,
    required this.primaryColor,
    this.size = 300.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // 1. Lingkaran Luar (Ring Emas)
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFB8860B)], // Gold Gradient
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(center, radius, borderPaint);

    // 2. Lingkaran Dalam (Deep Purple Background)
    final bgPaint = Paint()..color = primaryColor.withOpacity(0.9);
    canvas.drawCircle(center, radius - 6, bgPaint);

    // 3. Garis-garis Derajat
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 5) {
      final angle = (i - heading - 90) * math.pi / 180; // Sesuaikan rotasi
      final isMajor = i % 90 == 0;
      final length = isMajor ? 15.0 : 8.0;

      final startX = center.dx + math.cos(angle) * (radius - length - 15);
      final startY = center.dy + math.sin(angle) * (radius - length - 15);
      final endX = center.dx + math.cos(angle) * (radius - 15);
      final endY = center.dy + math.sin(angle) * (radius - 15);

      tickPaint.color = isMajor ? Colors.amber : Colors.white.withOpacity(0.3);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // 4. Panah Kiblat (The Golden Kaaba Needle)
    final qiblahAngle = (qiblah - heading - 90) * math.pi / 180;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(qiblahAngle);

    // Jarum utama
    final needlePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.amber, Colors.orangeAccent],
      ).createShader(Rect.fromLTRB(-5, -radius, 5, radius))
      ..strokeWidth = 4.0;

    canvas.drawLine(Offset(0, -radius + 40), Offset(0, 20), needlePaint);

    // Kepala Panah (Icon Ka'bah atau Segitiga Emas)
    final path = Path()
      ..moveTo(0, -radius + 20)
      ..lineTo(-15, -radius + 45)
      ..lineTo(15, -radius + 45)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.amber);

    canvas.restore();

    // 5. Pusat Kompas
    canvas.drawCircle(center, 8, Paint()..color = Colors.amber);
    canvas.drawCircle(center, 4, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) => true;
}
