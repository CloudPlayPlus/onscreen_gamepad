import 'package:flutter/material.dart';
import 'onscreen_gamepad_models.dart';

/// 与网页预览一致的轻量矢量图案，无位图和额外依赖。
class OnscreenGamepadButtonSymbol extends StatelessWidget {
  const OnscreenGamepadButtonSymbol({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    this.isActive = false,
  });
  final OnscreenGamepadButtonIcon icon;
  final Color color;
  final double size;
  final bool isActive;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _SymbolPainter(icon, color, isActive)),
  );
}

class _SymbolPainter extends CustomPainter {
  const _SymbolPainter(this.icon, this.color, this.isActive);
  final OnscreenGamepadButtonIcon icon;
  final Color color;
  final bool isActive;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color;
    switch (icon) {
      case OnscreenGamepadButtonIcon.text:
        break;
      case OnscreenGamepadButtonIcon.runWalk:
        if (isActive) {
          canvas.drawCircle(const Offset(8, 4), 1.9, fill);
          canvas.drawPath(
            Path()
              ..moveTo(10, 8)
              ..lineTo(13, 13)
              ..lineTo(9, 15)
              ..lineTo(7, 21)
              ..moveTo(10, 8)
              ..lineTo(7, 10)
              ..lineTo(3, 7)
              ..moveTo(10, 8)
              ..lineTo(14, 7)
              ..lineTo(17, 10)
              ..moveTo(13, 13)
              ..lineTo(16, 17)
              ..lineTo(21, 17),
            stroke,
          );
        } else {
          canvas.drawCircle(const Offset(10.5, 4), 1.9, fill);
          canvas.drawPath(
            Path()
              ..moveTo(12, 8)
              ..lineTo(14, 14)
              ..lineTo(10, 17)
              ..lineTo(10, 22)
              ..moveTo(12, 8)
              ..lineTo(8, 12)
              ..lineTo(5, 12)
              ..moveTo(12, 8)
              ..lineTo(16, 10)
              ..lineTo(18, 14)
              ..moveTo(14, 14)
              ..lineTo(16, 20)
              ..lineTo(19, 22),
            stroke,
          );
        }
        break;
      case OnscreenGamepadButtonIcon.jump:
        canvas.drawCircle(const Offset(10, 4), 1.9, fill);
        canvas.drawPath(
          Path()
            ..moveTo(12, 8)
            ..lineTo(13, 13)
            ..lineTo(9, 16)
            ..lineTo(5, 14)
            ..moveTo(13, 13)
            ..lineTo(17, 15)
            ..lineTo(20, 12)
            ..moveTo(12, 8)
            ..lineTo(7, 9)
            ..lineTo(4, 5)
            ..moveTo(12, 8)
            ..lineTo(16, 7)
            ..lineTo(18, 3)
            ..moveTo(20, 22)
            ..lineTo(4, 22)
            ..moveTo(13, 19)
            ..lineTo(13, 22)
            ..moveTo(9, 20)
            ..lineTo(9, 22),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.crouch:
        canvas.drawCircle(const Offset(9, 7), 1.9, fill);
        canvas.drawPath(
          Path()
            ..moveTo(11, 11)
            ..lineTo(14, 15)
            ..lineTo(8, 18)
            ..lineTo(9, 22)
            ..moveTo(11, 11)
            ..lineTo(7, 13)
            ..lineTo(3, 13)
            ..moveTo(14, 15)
            ..lineTo(17, 19)
            ..lineTo(21, 19)
            ..moveTo(12, 22)
            ..lineTo(6, 22),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.prone:
        canvas.drawCircle(const Offset(4, 13), 1.9, fill);
        canvas.drawPath(
          Path()
            ..moveTo(8, 15)
            ..lineTo(14, 16)
            ..lineTo(19, 14)
            ..lineTo(22, 15)
            ..moveTo(8, 15)
            ..lineTo(6, 19)
            ..lineTo(1, 19)
            ..moveTo(14, 16)
            ..lineTo(17, 19)
            ..lineTo(22, 19),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.attack:
        canvas.drawPath(
          Path()
            ..moveTo(20, 20)
            ..lineTo(16, 16)
            ..lineTo(14, 18)
            ..lineTo(18, 22)
            ..close(),
          fill,
        );
        canvas.drawPath(
          Path()
            ..moveTo(18, 14)
            ..lineTo(12, 20)
            ..moveTo(15, 15)
            ..lineTo(7, 3)
            ..lineTo(3, 2)
            ..lineTo(4, 7)
            ..lineTo(13, 17)
            ..close()
            ..moveTo(12, 13)
            ..lineTo(6, 6),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.parry:
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)
            ..lineTo(4, 6)
            ..lineTo(5, 13)
            ..quadraticBezierTo(6, 18, 12, 22)
            ..quadraticBezierTo(18, 18, 19, 13)
            ..lineTo(20, 6)
            ..close()
            ..moveTo(20, 20)
            ..lineTo(7, 7)
            ..moveTo(21, 16)
            ..lineTo(16, 21)
            ..moveTo(11, 7)
            ..lineTo(6, 2)
            ..lineTo(4, 4)
            ..lineTo(7, 9)
            ..close()
            ..moveTo(3, 9)
            ..lineTo(1, 9)
            ..moveTo(14, 2)
            ..lineTo(14, 0),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.medicine:
        canvas.drawPath(
          Path()
            ..moveTo(8, 5)
            ..lineTo(16, 5)
            ..lineTo(16, 8)
            ..lineTo(19, 11)
            ..lineTo(19, 21)
            ..lineTo(5, 21)
            ..lineTo(5, 11)
            ..lineTo(8, 8)
            ..close()
            ..moveTo(8, 2)
            ..lineTo(16, 2)
            ..lineTo(16, 5)
            ..lineTo(8, 5)
            ..close()
            ..moveTo(9, 14)
            ..lineTo(15, 14)
            ..moveTo(12, 11)
            ..lineTo(12, 17),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.menu:
        canvas.drawPath(
          Path()
            ..moveTo(4, 6)
            ..lineTo(20, 6)
            ..moveTo(4, 12)
            ..lineTo(20, 12)
            ..moveTo(4, 18)
            ..lineTo(20, 18),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.backpack:
        canvas.drawPath(
          Path()
            ..moveTo(8, 6)
            ..lineTo(8, 4)
            ..quadraticBezierTo(8, 2, 12, 2)
            ..quadraticBezierTo(16, 2, 16, 4)
            ..lineTo(16, 6)
            ..moveTo(5, 10)
            ..quadraticBezierTo(5, 6, 9, 6)
            ..lineTo(15, 6)
            ..quadraticBezierTo(19, 6, 19, 10)
            ..lineTo(19, 21)
            ..lineTo(5, 21)
            ..close()
            ..moveTo(8, 14)
            ..lineTo(16, 14)
            ..lineTo(16, 18)
            ..lineTo(8, 18)
            ..close()
            ..moveTo(8, 10)
            ..lineTo(16, 10)
            ..moveTo(2, 11)
            ..lineTo(2, 18)
            ..moveTo(22, 11)
            ..lineTo(22, 18),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.shoot:
        canvas.drawPath(
          Path()
            ..moveTo(7.757, 12)
            ..quadraticBezierTo(4.929, 9.172, 4.929, 4.929)
            ..quadraticBezierTo(9.172, 4.929, 12, 7.757)
            ..lineTo(21.192, 16.95)
            ..lineTo(16.95, 21.192)
            ..close()
            ..moveTo(7.757, 12)
            ..lineTo(12, 7.757)
            ..moveTo(14.828, 19.071)
            ..lineTo(19.071, 14.828),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.reload:
        canvas.drawPath(
          Path()
            ..moveTo(9.115, 12)
            ..quadraticBezierTo(7.192, 10.077, 7.192, 7.192)
            ..quadraticBezierTo(10.077, 7.192, 12, 9.115)
            ..lineTo(18.251, 15.366)
            ..lineTo(15.366, 18.251)
            ..close()
            ..moveTo(9.115, 12)
            ..lineTo(12, 9.115)
            ..moveTo(13.923, 16.808)
            ..lineTo(16.808, 13.923),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(2, 13)
            ..quadraticBezierTo(1, 22, 10, 22)
            ..lineTo(13, 21)
            ..moveTo(10, 18)
            ..lineTo(13, 21)
            ..lineTo(10, 24)
            ..moveTo(22, 11)
            ..quadraticBezierTo(23, 2, 14, 2)
            ..lineTo(11, 3)
            ..moveTo(14, 0)
            ..lineTo(11, 3)
            ..lineTo(14, 6),
          stroke,
        );
        break;
      case OnscreenGamepadButtonIcon.aim:
        canvas.drawCircle(const Offset(12, 12), 7, stroke);
        canvas.drawCircle(const Offset(12, 12), 1.4, fill);
        canvas.drawPath(
          Path()
            ..moveTo(12, 1)
            ..lineTo(12, 7)
            ..moveTo(12, 17)
            ..lineTo(12, 23)
            ..moveTo(1, 12)
            ..lineTo(7, 12)
            ..moveTo(17, 12)
            ..lineTo(23, 12),
          stroke,
        );
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SymbolPainter old) =>
      old.icon != icon || old.color != color || old.isActive != isActive;
}
