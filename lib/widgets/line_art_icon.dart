import 'dart:math';
import 'package:flutter/material.dart';

enum LineArtSymbol {
  cave,
  sensor,
  analytics,
  warehouse,
  export,
  temperature,
  humidity,
  light,
  home,
}

class LineArtIcon extends StatelessWidget {
  final LineArtSymbol symbol;
  final Color color;
  final double size;
  final double strokeWidth;

  const LineArtIcon({
    super.key,
    required this.symbol,
    this.color = Colors.white,
    this.size = 28,
    this.strokeWidth = 2.3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LineArtIconPainter(symbol, color, strokeWidth),
    );
  }
}

class _LineArtIconPainter extends CustomPainter {
  final LineArtSymbol symbol;
  final Color color;
  final double strokeWidth;

  _LineArtIconPainter(this.symbol, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    switch (symbol) {
      case LineArtSymbol.cave:
        _drawCave(canvas, paint, w, h);
        break;
      case LineArtSymbol.sensor:
        _drawSensor(canvas, paint, w, h);
        break;
      case LineArtSymbol.analytics:
        _drawAnalytics(canvas, paint, w, h);
        break;
      case LineArtSymbol.warehouse:
        _drawWarehouse(canvas, paint, w, h);
        break;
      case LineArtSymbol.export:
        _drawExport(canvas, paint, w, h);
        break;
      case LineArtSymbol.temperature:
        _drawTemperature(canvas, paint, w, h);
        break;
      case LineArtSymbol.humidity:
        _drawHumidity(canvas, paint, w, h);
        break;
      case LineArtSymbol.light:
        _drawLight(canvas, paint, w, h);
        break;
      case LineArtSymbol.home:
        _drawHome(canvas, paint, w, h);
        break;
    }
  }

  void _drawCave(Canvas canvas, Paint paint, double w, double h) {
    final cave = Path()
      ..moveTo(w * 0.1, h * 0.7)
      ..quadraticBezierTo(w * 0.2, h * 0.2, w * 0.5, h * 0.15)
      ..quadraticBezierTo(w * 0.8, h * 0.2, w * 0.9, h * 0.7)
      ..close();
    canvas.drawPath(cave, paint);
    canvas.drawLine(
      Offset(w * 0.18, h * 0.55),
      Offset(w * 0.18, h * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.33, h * 0.6),
      Offset(w * 0.33, h * 0.34),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.75, h * 0.58),
      Offset(w * 0.75, h * 0.33),
      paint,
    );
  }

  void _drawSensor(Canvas canvas, Paint paint, double w, double h) {
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.28, paint);
    canvas.drawLine(Offset(w * 0.5, h * 0.22), Offset(w * 0.5, h * 0.5), paint);
    canvas.drawLine(
      Offset(w * 0.44, h * 0.58),
      Offset(w * 0.56, h * 0.58),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.35, h * 0.38),
      Offset(w * 0.65, h * 0.38),
      paint,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.84), w * 0.08, paint);
  }

  void _drawAnalytics(Canvas canvas, Paint paint, double w, double h) {
    final spacing = w * 0.14;
    final baseline = h * 0.78;
    final bars = [0.3, 0.55, 0.85];
    for (var i = 0; i < bars.length; i++) {
      final left = spacing + i * spacing * 2;
      canvas.drawLine(
        Offset(left, baseline),
        Offset(left, baseline - h * bars[i]),
        paint,
      );
      canvas.drawCircle(
        Offset(left, baseline - h * bars[i]),
        strokeWidth * 0.7,
        paint,
      );
    }
    canvas.drawLine(
      Offset(spacing * 0.7, baseline - h * 0.02),
      Offset(w * 0.93, baseline - h * 0.68),
      paint,
    );
  }

  void _drawWarehouse(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.15, h * 0.75)
      ..lineTo(w * 0.15, h * 0.45)
      ..lineTo(w * 0.5, h * 0.19)
      ..lineTo(w * 0.85, h * 0.45)
      ..lineTo(w * 0.85, h * 0.75);
    canvas.drawPath(path, paint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.32, h * 0.52, w * 0.36, h * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.52),
      Offset(w * 0.5, h * 0.72),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.32, h * 0.62),
      Offset(w * 0.68, h * 0.62),
      paint,
    );
  }

  void _drawExport(Canvas canvas, Paint paint, double w, double h) {
    canvas.drawRect(
      Rect.fromLTWH(w * 0.16, h * 0.24, w * 0.68, h * 0.48),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.2, h * 0.26),
      Offset(w * 0.8, h * 0.26),
      paint,
    );
    canvas.drawLine(Offset(w * 0.5, h * 0.26), Offset(w * 0.5, h * 0.7), paint);
    canvas.drawLine(
      Offset(w * 0.4, h * 0.72),
      Offset(w * 0.55, h * 0.88),
      paint,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.72),
      Offset(w * 0.65, h * 0.88),
      paint,
    );
  }

  void _drawTemperature(Canvas canvas, Paint paint, double w, double h) {
    canvas.drawLine(
      Offset(w * 0.5, h * 0.25),
      Offset(w * 0.5, h * 0.68),
      paint,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.78), w * 0.18, paint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.78), w * 0.08, paint);
  }

  void _drawHumidity(Canvas canvas, Paint paint, double w, double h) {
    final path = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..quadraticBezierTo(w * 0.2, h * 0.5, w * 0.5, h * 0.86)
      ..quadraticBezierTo(w * 0.8, h * 0.5, w * 0.5, h * 0.12);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.45), w * 0.08, paint);
  }

  void _drawLight(Canvas canvas, Paint paint, double w, double h) {
    final center = Offset(w * 0.5, h * 0.42);
    canvas.drawCircle(center, w * 0.2, paint);
    final rays = 8;
    for (var i = 0; i < rays; i++) {
      final angle = (pi * 2 / rays) * i;
      final start = Offset(
        center.dx + cos(angle) * w * 0.24,
        center.dy + sin(angle) * w * 0.24,
      );
      final end = Offset(
        center.dx + cos(angle) * w * 0.34,
        center.dy + sin(angle) * w * 0.34,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawHome(Canvas canvas, Paint paint, double w, double h) {
    final roof = Path()
      ..moveTo(w * 0.18, h * 0.55)
      ..lineTo(w * 0.5, h * 0.2)
      ..lineTo(w * 0.82, h * 0.55);
    canvas.drawPath(roof, paint);
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.55, w * 0.5, h * 0.3), paint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.45, h * 0.7, w * 0.12, h * 0.15),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
