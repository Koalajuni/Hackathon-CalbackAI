import 'package:calendar/pages/all_pages.dart';
import 'package:flutter/cupertino.dart';


class showColorPopup extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xff5562FE)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;
    final double triangleH = 10;
    final double triangleW = 25.0;
    final double width = 86.w;
    final double height = 22.h;

    final Path trianglePath = Path()
      ..moveTo(9, height)
      ..lineTo(18, triangleH + height)
      ..lineTo(22 / 2 + triangleW / 2, height)
      ..lineTo(10, height);
    canvas.drawPath(trianglePath, paint);
    final BorderRadius borderRadius = BorderRadius.circular(4);
    final Rect rect = Rect.fromLTRB(0, 0, 86.w, 22.h);
    final RRect outer = borderRadius.toRRect(rect);
    canvas.drawRRect(outer, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}