import 'package:flutter/material.dart';

class OvalOutline extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const OvalOutline({
    super.key,
    required this.width,
    required this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _OvalBorderPainter(
        color: Colors.white,
        strokeWidth: 2.5,
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(child: child),
      ),
    );
  }
}

class _OvalBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _OvalBorderPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Inset the rect slightly by half strokeWidth so the border isn't clipped
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _OvalBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
