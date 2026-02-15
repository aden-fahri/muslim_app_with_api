import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassPainter extends CustomPainter {
  final double heading; // Arah HP sekarang (dari utara, 0-360)
  final double qiblah; // Arah kiblat dari utara (tetap)
  final double size; // Ukuran kompas (diameter)

  CompassPainter({
    required this.heading,
    required this.qiblah,
    this.size = 300.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // 1. Lingkaran luar (border kompas)
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, borderPaint);

    // 2. Lingkaran dalam (background gelap)
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawCircle(center, radius - 4, bgPaint);

    // 3. Garis-garis derajat & teks mata angin
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (int i = 0; i < 360; i += 5) {
      final angle = (i - heading) * math.pi / 180; // Rotate sesuai heading
      final isMajor = i % 90 == 0;
      final isMedium = i % 30 == 0 && !isMajor;
      final length = isMajor ? 20 : (isMedium ? 12 : 6);

      final startX = center.dx + math.cos(angle) * (radius - length - 10);
      final startY = center.dy + math.sin(angle) * (radius - length - 10);
      final endX = center.dx + math.cos(angle) * (radius - 10);
      final endY = center.dy + math.sin(angle) * (radius - 10);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);

      // Teks hanya untuk mata angin utama + derajat besar
      if (i % 90 == 0 || i % 30 == 0) {
        String label;
        Color textColor = Colors.white;
        double fontSize = 14;

        switch (i) {
          case 0:
            label = 'N';
            textColor = Colors.redAccent;
            fontSize = 24;
            break;
          case 90:
            label = 'E';
            break;
          case 180:
            label = 'S';
            break;
          case 270:
            label = 'W';
            break;
          default:
            label = '$i°';
            fontSize = 12;
        }

        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();

        final textAngle =
            angle - math.pi / 2; // Adjust agar teks menghadap luar
        final textX =
            center.dx + math.cos(angle) * (radius - 35) - textPainter.width / 2;
        final textY =
            center.dy +
            math.sin(angle) * (radius - 35) -
            textPainter.height / 2;

        canvas.save();
        canvas.translate(
          textX + textPainter.width / 2,
          textY + textPainter.height / 2,
        );
        canvas.rotate(textAngle);
        canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }

    // 4. Panah Kiblat (Ka'bah) - segitiga sederhana + garis
    final qiblahAngle =
        (qiblah - heading) * math.pi / 180; // Offset dari heading sekarang

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(qiblahAngle);

    // Garis panah panjang ke arah kiblat
    final arrowPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, -radius + 40),
      Offset(0, radius - 40),
      arrowPaint,
    );

    // Kepala panah (segitiga)
    final path = Path()
      ..moveTo(0, radius - 40)
      ..lineTo(-15, radius - 60)
      ..lineTo(15, radius - 60)
      ..close();
    final arrowHeadPaint = Paint()..color = Colors.greenAccent;
    canvas.drawPath(path, arrowHeadPaint);

    canvas.restore();

    // 5. Titik tengah (pusat)
    canvas.drawCircle(center, 10, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.qiblah != qiblah;
  }
}
