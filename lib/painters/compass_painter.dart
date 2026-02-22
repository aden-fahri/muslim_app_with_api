import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  final double heading;
  final double qiblah;
  final double size;

  CompassPainter({
    required this.heading,
    required this.qiblah,
    this.size = 260.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // Warna dari tema yang kamu berikan
    const primaryPurple = Color(0xFF7C5ABF);
    const softPurple = Color(0xFF9F7EE6);
    const goldHighlight = Color(0xFFB8975A);
    const deepPurple = Color(0xFF2A0E5A);

    // 1. Lingkaran Background Subtle
    final bgPaint = Paint()
      ..color = primaryPurple.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 2. Ring Luar (Hairline)
    final ringPaint = Paint()
      ..color = primaryPurple.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, ringPaint);

    // 3. Garis Derajat & Label Bahasa Indonesia
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 360; i += 5) {
      final angleRad = (i - heading - 90) * math.pi / 180;
      final isMajor = i % 90 == 0;
      final isMid = i % 30 == 0 && !isMajor;

      double tickLength = 6.0;
      if (isMajor) tickLength = 14.0;
      else if (isMid) tickLength = 9.0;

      final paint = Paint()
        ..color = isMajor 
            ? primaryPurple 
            : softPurple.withOpacity(i % 10 == 0 ? 0.4 : 0.2)
        ..strokeWidth = isMajor ? 2.0 : 0.8;

      final start = Offset(
        center.dx + math.cos(angleRad) * (radius - tickLength),
        center.dy + math.sin(angleRad) * (radius - tickLength),
      );
      final end = Offset(
        center.dx + math.cos(angleRad) * radius,
        center.dy + math.sin(angleRad) * radius,
      );

      canvas.drawLine(start, end, paint);

      // Label Arah Utama Bahasa Indonesia
      if (isMajor) {
        // U = Utara, T = Timur, S = Selatan, B = Barat
        final label = ['U', 'T', 'S', 'B'][(i ~/ 90) % 4];
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: label == 'U' ? goldHighlight : deepPurple,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        );
        textPainter.layout();
        
        final labelOffset = Offset(
          center.dx + math.cos(angleRad) * (radius - 32) - textPainter.width / 2,
          center.dy + math.sin(angleRad) * (radius - 32) - textPainter.height / 2,
        );
        textPainter.paint(canvas, labelOffset);
      }
    }

    // 4. Jarum Kiblat (Modern Gold)
    final qiblahAngle = (qiblah - heading - 90) * math.pi / 180;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(qiblahAngle);

    // Garis Jarum (Sleek Hairline)
    final needleLinePaint = Paint()
      ..color = goldHighlight
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(0, 5),
      Offset(0, -radius + 15),
      needleLinePaint,
    );

    // Indikator Panah Ka'bah
    final kabaPaint = Paint()..color = goldHighlight;
    final kabaPath = Path()
      ..moveTo(0, -radius + 10)
      ..lineTo(-8, -radius + 30)
      ..lineTo(8, -radius + 30)
      ..close();
    canvas.drawPath(kabaPath, kabaPaint);

    // Label "KIBLAT"
    textPainter.text = const TextSpan(
      text: 'KIBLAT',
      style: TextStyle(
        color: goldHighlight,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -radius + 38));

    canvas.restore();

    // 5. Center Point (Poros)
    canvas.drawCircle(center, 5, Paint()..color = primaryPurple);
    canvas.drawCircle(center, 2, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) => 
      oldDelegate.heading != heading || oldDelegate.qiblah != qiblah;
}