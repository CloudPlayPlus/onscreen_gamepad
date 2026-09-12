// GENERATED CODE — 请勿直接编辑。
// 来源：cloudplayplus/docs/prototypes/screen_buttons_rules/icons-draft.js
// 更新：node tool/sync_onscreen_icons.cjs <onscreen_gamepad 仓库路径>

part of 'onscreen_gamepad_button_symbol.dart';

void _paintButtonSymbol(
  Canvas canvas,
  OnscreenGamepadButtonIcon icon,
  Color color,
  bool isActive,
) {
  final stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final fill = Paint()..color = color;
  switch (icon) {
    case OnscreenGamepadButtonIcon.text:
      break;
    case OnscreenGamepadButtonIcon.runWalk:
      if (isActive) {
        canvas.drawCircle(const Offset(8, 4), 2, fill);
        canvas.drawPath(
          Path()
            ..moveTo(9, 8)
            ..lineTo(13, 12)
            ..lineTo(9, 15)
            ..lineTo(7, 21)
            ..moveTo(9, 8)
            ..lineTo(6, 11)
            ..lineTo(3, 9)
            ..moveTo(9, 8)
            ..lineTo(14, 7)
            ..lineTo(17, 10)
            ..moveTo(13, 12)
            ..lineTo(17, 17)
            ..lineTo(21, 17),
          stroke,
        );
      } else {
        canvas.drawCircle(const Offset(10, 4), 2, fill);
        canvas.drawPath(
          Path()
            ..moveTo(10, 8)
            ..lineTo(12, 13)
            ..lineTo(8, 16)
            ..lineTo(6, 21)
            ..moveTo(12, 13)
            ..lineTo(14, 17)
            ..lineTo(18, 21)
            ..moveTo(10, 8)
            ..lineTo(7, 12)
            ..lineTo(4, 13)
            ..moveTo(10, 8)
            ..lineTo(15, 11)
            ..lineTo(17, 14),
          stroke,
        );
      }
      break;
    case OnscreenGamepadButtonIcon.jump:
      canvas.drawCircle(const Offset(9, 4), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(10, 8)
          ..lineTo(12, 12)
          ..lineTo(7.25, 10.8125)
          ..lineTo(8.25, 14.8125)
          ..moveTo(12, 12)
          ..lineTo(16, 15)
          ..lineTo(19, 12)
          ..moveTo(10, 8)
          ..lineTo(5.5, 8.5)
          ..lineTo(3.25, 7)
          ..moveTo(10, 8)
          ..lineTo(14, 7)
          ..lineTo(17, 9)
          ..moveTo(7, 20)
          ..lineTo(7, 22)
          ..moveTo(12, 20)
          ..lineTo(12, 22)
          ..moveTo(17, 20)
          ..lineTo(17, 22),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.crouch:
      canvas.drawCircle(const Offset(11, 7), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(12, 11)
          ..lineTo(14, 17)
          ..lineTo(7, 16)
          ..lineTo(7, 21)
          ..moveTo(14, 17)
          ..lineTo(11, 21)
          ..lineTo(16, 21)
          ..moveTo(12, 11)
          ..lineTo(8, 14)
          ..lineTo(4, 14)
          ..moveTo(12, 11)
          ..lineTo(15, 13)
          ..lineTo(11, 14),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.prone:
      canvas.drawCircle(const Offset(4, 12), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(8, 14)
          ..lineTo(14, 14)
          ..lineTo(18, 16)
          ..lineTo(21, 16)
          ..moveTo(8, 14)
          ..lineTo(6, 18)
          ..lineTo(3, 18)
          ..moveTo(14, 14)
          ..lineTo(17, 19)
          ..lineTo(21, 19),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.dodge:
      canvas.drawCircle(const Offset(8, 5), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(9, 9)
          ..lineTo(13, 13)
          ..lineTo(8, 16)
          ..lineTo(4, 20)
          ..moveTo(9, 9)
          ..lineTo(5, 11)
          ..lineTo(3, 11)
          ..moveTo(13, 13)
          ..lineTo(17, 18)
          ..lineTo(21, 18)
          ..moveTo(16, 7)
          ..lineTo(21, 7)
          ..moveTo(18, 11)
          ..lineTo(21, 11),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.grapple:
      canvas.drawPath(
        Path()
          ..moveTo(19, 20)
          ..lineTo(10, 11)
          ..moveTo(4, 10)
          ..lineTo(4, 4)
          ..lineTo(10, 4)
          ..moveTo(4, 4)
          ..lineTo(12, 12)
          ..moveTo(5, 12)
          ..cubicTo(3, 16, 7, 20, 11, 17)
          ..lineTo(13, 15)
          ..moveTo(12, 5)
          ..cubicTo(16, 3, 20, 7, 17, 11)
          ..lineTo(15, 13),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.climb:
      canvas.drawCircle(const Offset(16, 4), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(3, 2)
          ..lineTo(3, 22)
          ..moveTo(9, 2)
          ..lineTo(9, 22)
          ..moveTo(3, 5)
          ..lineTo(9, 5)
          ..moveTo(3, 9)
          ..lineTo(9, 9)
          ..moveTo(3, 13)
          ..lineTo(9, 13)
          ..moveTo(3, 17)
          ..lineTo(9, 17)
          ..moveTo(3, 21)
          ..lineTo(9, 21)
          ..moveTo(16, 8)
          ..lineTo(17, 13.5)
          ..lineTo(12, 14)
          ..lineTo(9, 17)
          ..moveTo(17, 13.5)
          ..lineTo(11.5, 17.5)
          ..lineTo(9, 21)
          ..moveTo(16, 8)
          ..lineTo(12, 8)
          ..lineTo(9, 5)
          ..moveTo(16, 9)
          ..lineTo(13, 11)
          ..lineTo(9, 9),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.swim:
      canvas.drawCircle(const Offset(5, 10), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(9, 12)
          ..lineTo(16, 12)
          ..moveTo(10, 12)
          ..lineTo(13, 5)
          ..lineTo(18, 7)
          ..moveTo(16, 12)
          ..lineTo(21, 10)
          ..moveTo(3, 17)
          ..quadraticBezierTo(6, 14, 9, 17)
          ..quadraticBezierTo(12, 20, 15, 17)
          ..quadraticBezierTo(18, 14, 21, 17)
          ..moveTo(3, 21)
          ..quadraticBezierTo(6, 18, 9, 21)
          ..quadraticBezierTo(12, 24, 15, 21)
          ..quadraticBezierTo(18, 18, 21, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.glide:
      canvas.drawPath(
        Path()
          ..moveTo(3, 9)
          ..arcToPoint(
            const Offset(21, 9),
            radius: const Radius.elliptical(9, 7),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(3, 9)
          ..close()
          ..moveTo(12, 2)
          ..cubicTo(8, 4, 8, 7, 8, 9)
          ..moveTo(12, 2)
          ..cubicTo(16, 4, 16, 7, 16, 9)
          ..moveTo(3, 9)
          ..lineTo(10, 16)
          ..moveTo(21, 9)
          ..lineTo(14, 16)
          ..moveTo(10, 16)
          ..lineTo(14, 16)
          ..lineTo(14, 19)
          ..lineTo(12, 22)
          ..lineTo(10, 19)
          ..lineTo(10, 16),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.slide:
      canvas.drawCircle(const Offset(20, 9.5), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(16.5, 12)
          ..lineTo(11, 16)
          ..lineTo(7, 17)
          ..lineTo(3, 18)
          ..moveTo(11, 16)
          ..lineTo(8, 12.5)
          ..lineTo(4, 14.5)
          ..moveTo(16.5, 12)
          ..lineTo(13, 8.5)
          ..lineTo(10, 9.5)
          ..moveTo(16.5, 12)
          ..lineTo(19, 15)
          ..lineTo(18, 18)
          ..moveTo(3, 21)
          ..lineTo(21, 21)
          ..moveTo(15, 5)
          ..lineTo(21, 5),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.attack:
      canvas.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(9, 5)
          ..lineTo(17, 13)
          ..lineTo(13, 17)
          ..lineTo(5, 9)
          ..close()
          ..moveTo(6, 6)
          ..lineTo(14, 14)
          ..moveTo(11, 19)
          ..lineTo(19, 11)
          ..moveTo(16, 16)
          ..lineTo(20, 20)
          ..moveTo(18, 21)
          ..lineTo(21, 18),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.parry:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(4, 6)
          ..lineTo(4, 12)
          ..cubicTo(4, 16, 8, 19, 12, 21)
          ..cubicTo(16, 19, 20, 16, 20, 12)
          ..lineTo(20, 6)
          ..lineTo(12, 3)
          ..close()
          ..moveTo(12, 7)
          ..lineTo(12, 17),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.heavyAttack:
      canvas.drawPath(
        Path()
          ..moveTo(4, 3)
          ..lineTo(13, 3)
          ..lineTo(13, 9)
          ..lineTo(4, 9)
          ..close()
          ..moveTo(8, 9)
          ..lineTo(8, 21)
          ..moveTo(17, 3)
          ..lineTo(20, 6)
          ..lineTo(17, 9)
          ..moveTo(17, 13)
          ..lineTo(20, 16)
          ..lineTo(17, 19),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.kick:
      canvas.drawCircle(const Offset(13, 4), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(12, 8)
          ..lineTo(11, 13)
          ..lineTo(16, 20)
          ..moveTo(11, 13)
          ..lineTo(7, 11)
          ..lineTo(3, 13)
          ..moveTo(12, 8)
          ..lineTo(8, 6)
          ..lineTo(5, 7)
          ..moveTo(12, 8)
          ..lineTo(16, 11)
          ..lineTo(20, 10),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.counter:
      canvas.drawPath(
        Path()
          ..moveTo(12, 10)
          ..lineTo(4, 12)
          ..lineTo(4, 15)
          ..cubicTo(4, 18, 8, 21, 12, 22)
          ..cubicTo(16, 21, 20, 18, 20, 15)
          ..lineTo(20, 12)
          ..lineTo(12, 10)
          ..close()
          ..moveTo(4, 3)
          ..lineTo(12, 7)
          ..lineTo(20, 3)
          ..moveTo(16, 3)
          ..lineTo(20, 3)
          ..lineTo(20, 7),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.lockOn:
      canvas.drawPath(
        Path()
          ..moveTo(3, 8)
          ..lineTo(3, 3)
          ..lineTo(8, 3)
          ..moveTo(16, 3)
          ..lineTo(21, 3)
          ..lineTo(21, 8)
          ..moveTo(21, 16)
          ..lineTo(21, 21)
          ..lineTo(16, 21)
          ..moveTo(8, 21)
          ..lineTo(3, 21)
          ..lineTo(3, 16),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 12), 4, stroke);
      canvas.drawCircle(const Offset(12, 12), 1, fill);
      break;
    case OnscreenGamepadButtonIcon.bow:
      canvas.drawPath(
        Path()
          ..moveTo(5, 20)
          ..cubicTo(2, 9, 9, 2, 20, 5)
          ..lineTo(5, 20)
          ..moveTo(3, 3)
          ..lineTo(12.5, 12.5)
          ..moveTo(3, 8)
          ..lineTo(3, 3)
          ..lineTo(8, 3),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.axe:
      canvas.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(21, 21)
          ..moveTo(6, 6)
          ..cubicTo(5, 9, 4, 10, 2, 10)
          ..cubicTo(2, 14, 6, 18, 10, 18)
          ..cubicTo(8, 15, 9, 12, 11, 11)
          ..close()
          ..moveTo(6, 6)
          ..cubicTo(9, 5, 10, 4, 10, 2)
          ..cubicTo(15, 2, 19, 6, 19, 11)
          ..cubicTo(15, 9, 12, 9, 11, 11)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.dualBlade:
      canvas.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(3, 8)
          ..lineTo(6, 14)
          ..lineTo(10, 12)
          ..lineTo(7, 6)
          ..close()
          ..moveTo(5.5, 15.5)
          ..lineTo(11.5, 12.5)
          ..moveTo(8.5, 14)
          ..lineTo(11, 19)
          ..moveTo(13, 3)
          ..lineTo(13, 8)
          ..lineTo(16, 14)
          ..lineTo(20, 12)
          ..lineTo(17, 6)
          ..close()
          ..moveTo(15.5, 15.5)
          ..lineTo(21.5, 12.5)
          ..moveTo(18.5, 14)
          ..lineTo(21, 19),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.dart:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(14, 9)
          ..lineTo(21, 12)
          ..lineTo(15, 14)
          ..lineTo(12, 21)
          ..lineTo(10, 15)
          ..lineTo(3, 12)
          ..lineTo(9, 10)
          ..lineTo(12, 3)
          ..close(),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 12), 1.6, stroke);
      break;
    case OnscreenGamepadButtonIcon.shoot:
      canvas.drawPath(
        Path()
          ..moveTo(4, 3)
          ..cubicTo(7, 3, 9, 4, 11, 6)
          ..lineTo(21, 16)
          ..lineTo(16, 21)
          ..lineTo(6, 11)
          ..cubicTo(4, 9, 3, 6, 4, 3)
          ..close()
          ..moveTo(6, 11)
          ..lineTo(11, 6)
          ..moveTo(13, 18)
          ..lineTo(18, 13),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.reload:
      canvas.drawPath(
        Path()
          ..moveTo(7, 7)
          ..quadraticBezierTo(10, 7, 12, 9)
          ..lineTo(17, 14)
          ..lineTo(14, 17)
          ..lineTo(9, 12)
          ..quadraticBezierTo(7, 10, 7, 7)
          ..close()
          ..moveTo(11, 14)
          ..lineTo(14, 11)
          ..moveTo(8, 2.835)
          ..arcToPoint(
            const Offset(21.85, 13.74),
            radius: const Radius.elliptical(10, 10),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..moveTo(19.1, 11.4)
          ..lineTo(21.85, 13.74)
          ..lineTo(22.7, 10.2)
          ..moveTo(16, 21.165)
          ..arcToPoint(
            const Offset(2.15, 10.26),
            radius: const Radius.elliptical(10, 10),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..moveTo(4.9, 12.6)
          ..lineTo(2.15, 10.26)
          ..lineTo(1.3, 13.8),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.aim:
      canvas.drawCircle(const Offset(12, 12), 7, stroke);
      canvas.drawCircle(const Offset(12, 12), 1.5, fill);
      canvas.drawPath(
        Path()
          ..moveTo(12, 2)
          ..lineTo(12, 7)
          ..moveTo(12, 17)
          ..lineTo(12, 22)
          ..moveTo(2, 12)
          ..lineTo(7, 12)
          ..moveTo(17, 12)
          ..lineTo(22, 12),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.grenade:
      canvas.drawPath(
        Path()
          ..moveTo(10, 7)
          ..lineTo(10, 4)
          ..lineTo(15, 4)
          ..lineTo(15, 8)
          ..moveTo(9, 4)
          ..lineTo(17, 4)
          ..lineTo(21, 8)
          ..moveTo(8, 8)
          ..lineTo(16, 8)
          ..lineTo(19, 12)
          ..lineTo(19, 17)
          ..lineTo(15, 21)
          ..lineTo(9, 21)
          ..lineTo(5, 17)
          ..lineTo(5, 12)
          ..lineTo(8, 8)
          ..close()
          ..moveTo(6, 13)
          ..lineTo(18, 13)
          ..moveTo(8, 17)
          ..lineTo(17, 17)
          ..moveTo(12, 9)
          ..lineTo(12, 20),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.weaponSwap:
      canvas.drawPath(
        Path()
          ..moveTo(7, 12)
          ..lineTo(9, 10)
          ..lineTo(9, 18)
          ..moveTo(7, 18)
          ..lineTo(11, 18)
          ..moveTo(13, 8)
          ..cubicTo(13, 5, 18, 5, 18, 8)
          ..cubicTo(18, 10, 13, 11, 13, 14)
          ..lineTo(18, 14)
          ..moveTo(8, 2.835)
          ..arcToPoint(
            const Offset(21.85, 13.74),
            radius: const Radius.elliptical(10, 10),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..moveTo(19.1, 11.4)
          ..lineTo(21.85, 13.74)
          ..lineTo(22.7, 10.2)
          ..moveTo(16, 21.165)
          ..arcToPoint(
            const Offset(2.15, 10.26),
            radius: const Radius.elliptical(10, 10),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..moveTo(4.9, 12.6)
          ..lineTo(2.15, 10.26)
          ..lineTo(1.3, 13.8),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.pistol:
      canvas.drawPath(
        Path()
          ..moveTo(3, 6)
          ..lineTo(21, 6)
          ..lineTo(21, 12)
          ..lineTo(17, 12)
          ..lineTo(20, 21)
          ..lineTo(15, 21)
          ..lineTo(13, 12)
          ..lineTo(3, 12)
          ..lineTo(3, 6)
          ..close()
          ..moveTo(13, 12)
          ..lineTo(13, 16)
          ..lineTo(9, 16)
          ..lineTo(7, 12)
          ..moveTo(8, 6)
          ..lineTo(8, 12),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.rifle:
      canvas.drawPath(
        Path()
          ..moveTo(2, 10)
          ..lineTo(6, 10)
          ..moveTo(3, 7)
          ..lineTo(3, 10)
          ..moveTo(6, 8)
          ..lineTo(17, 8)
          ..lineTo(17, 10)
          ..lineTo(19, 10)
          ..lineTo(22, 8)
          ..lineTo(22, 15)
          ..lineTo(18, 13)
          ..lineTo(6, 13)
          ..lineTo(6, 8)
          ..close()
          ..moveTo(9, 8)
          ..lineTo(9, 5)
          ..lineTo(15, 5)
          ..lineTo(15, 8)
          ..moveTo(10, 13)
          ..lineTo(9, 19)
          ..lineTo(12, 20)
          ..lineTo(14, 13)
          ..moveTo(16, 13)
          ..lineTo(17, 19)
          ..lineTo(20, 19)
          ..lineTo(18, 13),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 10.5)
          ..lineTo(13, 10.5)
          ..moveTo(14, 13)
          ..lineTo(14, 16)
          ..lineTo(17, 16),
        (Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round),
      );
      break;
    case OnscreenGamepadButtonIcon.scope:
      canvas.drawCircle(const Offset(10, 10), 7, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(15, 15)
          ..lineTo(21, 21)
          ..moveTo(10, 6)
          ..lineTo(10, 14)
          ..moveTo(6, 10)
          ..lineTo(14, 10),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.burst:
      canvas.drawPath(
        Path()
          ..moveTo(3, 10)
          ..lineTo(3, 5)
          ..lineTo(5, 3)
          ..lineTo(7, 5)
          ..lineTo(7, 10)
          ..lineTo(3, 10)
          ..close()
          ..moveTo(10, 13)
          ..lineTo(10, 8)
          ..lineTo(12, 6)
          ..lineTo(14, 8)
          ..lineTo(14, 13)
          ..lineTo(10, 13)
          ..close()
          ..moveTo(17, 16)
          ..lineTo(17, 11)
          ..lineTo(19, 9)
          ..lineTo(21, 11)
          ..lineTo(21, 16)
          ..lineTo(17, 16)
          ..close()
          ..moveTo(3, 15)
          ..lineTo(3, 18)
          ..moveTo(10, 18)
          ..lineTo(10, 21)
          ..moveTo(17, 20)
          ..lineTo(17, 22),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.safety:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 10, 14, 11),
          const Radius.circular(2),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(8, 10)
          ..lineTo(8, 7)
          ..arcToPoint(
            const Offset(16, 7),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(16, 10)
          ..moveTo(12, 14)
          ..lineTo(12, 17),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.skill:
      canvas.drawPath(
        Path()
          ..moveTo(13, 2)
          ..lineTo(4, 14)
          ..lineTo(11, 14)
          ..lineTo(10, 22)
          ..lineTo(20, 9)
          ..lineTo(13, 9)
          ..lineTo(14, 2)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.staff:
      canvas.drawPath(
        Path()
          ..moveTo(6, 2)
          ..lineTo(10, 6)
          ..lineTo(6, 10)
          ..lineTo(2, 6)
          ..close()
          ..moveTo(3, 9)
          ..cubicTo(6, 13, 9, 14, 12, 12)
          ..cubicTo(14, 9, 13, 6, 9, 3)
          ..moveTo(12, 12)
          ..lineTo(21, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.fire:
      canvas.drawPath(
        Path()
          ..moveTo(13, 3)
          ..cubicTo(14, 8, 8, 8, 9, 12)
          ..cubicTo(7, 12, 6, 10, 6, 9)
          ..cubicTo(1, 16, 5, 21, 12, 21)
          ..cubicTo(20, 21, 23, 13, 17, 8)
          ..cubicTo(17, 11, 15, 12, 14, 12)
          ..cubicTo(16, 8, 14, 5, 13, 3)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.ice:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(12, 21)
          ..moveTo(4, 7)
          ..lineTo(20, 17)
          ..moveTo(4, 17)
          ..lineTo(20, 7)
          ..moveTo(9, 4)
          ..lineTo(12, 7)
          ..lineTo(15, 4)
          ..moveTo(9, 20)
          ..lineTo(12, 17)
          ..lineTo(15, 20)
          ..moveTo(4, 11)
          ..lineTo(8, 10)
          ..lineTo(8, 6)
          ..moveTo(16, 18)
          ..lineTo(16, 14)
          ..lineTo(20, 13)
          ..moveTo(4, 13)
          ..lineTo(8, 14)
          ..lineTo(8, 18)
          ..moveTo(16, 6)
          ..lineTo(16, 10)
          ..lineTo(20, 11),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.wind:
      canvas.drawPath(
        Path()
          ..moveTo(3, 8)
          ..lineTo(15, 8)
          ..arcToPoint(
            const Offset(12, 5),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: true,
            clockwise: false,
          )
          ..moveTo(3, 12)
          ..lineTo(19, 12)
          ..arcToPoint(
            const Offset(17, 14),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: true,
            clockwise: true,
          )
          ..moveTo(3, 16)
          ..lineTo(11, 16)
          ..arcToPoint(
            const Offset(8, 19),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: true,
            clockwise: true,
          ),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.water:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..cubicTo(9, 7, 5, 11, 5, 15)
          ..arcToPoint(
            const Offset(19, 15),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          )
          ..cubicTo(19, 11, 15, 7, 12, 3)
          ..close()
          ..moveTo(9, 15)
          ..arcToPoint(
            const Offset(12, 18),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          ),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.heal:
      canvas.drawPath(
        Path()
          ..moveTo(8, 3)
          ..lineTo(16, 3)
          ..lineTo(16, 8)
          ..lineTo(21, 8)
          ..lineTo(21, 16)
          ..lineTo(16, 16)
          ..lineTo(16, 21)
          ..lineTo(8, 21)
          ..lineTo(8, 16)
          ..lineTo(3, 16)
          ..lineTo(3, 8)
          ..lineTo(8, 8)
          ..lineTo(8, 3)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.magicShield:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(4, 6)
          ..lineTo(4, 12)
          ..cubicTo(4, 16, 8, 19, 12, 21)
          ..cubicTo(16, 19, 20, 16, 20, 12)
          ..lineTo(20, 6)
          ..lineTo(12, 3)
          ..close()
          ..moveTo(12, 7)
          ..lineTo(13.5, 10.5)
          ..lineTo(17, 12)
          ..lineTo(13.5, 13.5)
          ..lineTo(12, 17)
          ..lineTo(10.5, 13.5)
          ..lineTo(7, 12)
          ..lineTo(10.5, 10.5)
          ..lineTo(12, 7)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.summon:
      canvas.drawCircle(const Offset(12, 7), 3, stroke);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(12, 19), width: 18, height: 6),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(7, 16)
          ..lineTo(7, 15)
          ..arcToPoint(
            const Offset(17, 15),
            radius: const Radius.elliptical(5, 5),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(17, 16)
          ..moveTo(12, 16)
          ..lineTo(12, 20),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.teleport:
      canvas.drawCircle(const Offset(4.5, 6), 2, fill);
      canvas.drawPath(
        Path()
          ..moveTo(5.5, 10)
          ..lineTo(7.5, 13)
          ..lineTo(3.5, 12.75)
          ..lineTo(4.5, 16.75)
          ..moveTo(5.5, 10)
          ..lineTo(3, 9.5)
          ..lineTo(2, 8.5)
          ..moveTo(5.5, 10)
          ..lineTo(7.5, 9.5)
          ..moveTo(16.5, 9.5)
          ..lineTo(18.5, 9)
          ..lineTo(21, 10.5)
          ..moveTo(16.5, 13)
          ..lineTo(20, 15.5)
          ..lineTo(22, 13)
          ..moveTo(7.5, 3)
          ..lineTo(7.5, 21)
          ..moveTo(16.5, 3)
          ..lineTo(16.5, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.invisibility:
      canvas.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(21, 21)
          ..moveTo(3, 10)
          ..lineTo(2, 12)
          ..cubicTo(2, 12, 6, 19, 12, 19)
          ..cubicTo(14, 19, 16, 18, 17, 17)
          ..moveTo(7, 6)
          ..cubicTo(8, 5.5, 10, 5, 12, 5)
          ..cubicTo(18, 5, 22, 12, 22, 12)
          ..cubicTo(22, 12, 21, 14, 19, 16)
          ..moveTo(9, 9)
          ..arcToPoint(
            const Offset(15, 15),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          ),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.interact:
      canvas.drawPath(
        Path()
          ..moveTo(5, 4)
          ..lineTo(19, 4)
          ..arcToPoint(
            const Offset(21, 6),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(21, 15)
          ..arcToPoint(
            const Offset(19, 17),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(11, 17)
          ..lineTo(5, 21)
          ..lineTo(5, 17)
          ..arcToPoint(
            const Offset(3, 15),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(3, 6)
          ..arcToPoint(
            const Offset(5, 4),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..close(),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(7, 10)
          ..lineTo(7.01, 10)
          ..moveTo(12, 10)
          ..lineTo(12.01, 10)
          ..moveTo(17, 10)
          ..lineTo(17.01, 10),
        (Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round),
      );
      break;
    case OnscreenGamepadButtonIcon.medicine:
      canvas.drawPath(
        Path()
          ..moveTo(9, 3)
          ..lineTo(15, 3)
          ..lineTo(15, 7)
          ..lineTo(18, 10)
          ..arcToPoint(
            const Offset(19, 12),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(19, 19)
          ..arcToPoint(
            const Offset(17, 21),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(7, 21)
          ..arcToPoint(
            const Offset(5, 19),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(5, 12)
          ..arcToPoint(
            const Offset(6, 10),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(9, 7)
          ..lineTo(9, 3)
          ..close()
          ..moveTo(8, 3)
          ..lineTo(16, 3)
          ..moveTo(9, 15)
          ..lineTo(15, 15)
          ..moveTo(12, 12)
          ..lineTo(12, 18),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.backpack:
      canvas.drawPath(
        Path()
          ..moveTo(9, 6)
          ..lineTo(9, 5)
          ..arcToPoint(
            const Offset(15, 5),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(15, 6)
          ..moveTo(8, 6)
          ..lineTo(16, 6)
          ..arcToPoint(
            const Offset(20, 10),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(20, 19)
          ..arcToPoint(
            const Offset(18, 21),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(6, 21)
          ..arcToPoint(
            const Offset(4, 19),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(4, 10)
          ..arcToPoint(
            const Offset(8, 6),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..close()
          ..moveTo(8, 13)
          ..lineTo(16, 13)
          ..lineTo(16, 18)
          ..lineTo(8, 18)
          ..close()
          ..moveTo(8, 10)
          ..lineTo(16, 10),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.pickup:
      canvas.drawPath(
        Path()
          ..moveTo(5, 13)
          ..lineTo(5, 8)
          ..arcToPoint(
            const Offset(9, 8),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(9, 12)
          ..moveTo(9, 10)
          ..lineTo(9, 5)
          ..arcToPoint(
            const Offset(13, 5),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(13, 12)
          ..moveTo(13, 9)
          ..arcToPoint(
            const Offset(17, 9),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(17, 13)
          ..moveTo(17, 11)
          ..arcToPoint(
            const Offset(21, 11),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(21, 16)
          ..lineTo(17, 21)
          ..lineTo(9, 21)
          ..lineTo(3, 15)
          ..arcToPoint(
            const Offset(5, 12),
            radius: const Radius.elliptical(2, 2),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(9, 15),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.door:
      canvas.drawPath(
        Path()
          ..moveTo(5, 21)
          ..lineTo(5, 3)
          ..lineTo(19, 3)
          ..lineTo(19, 21)
          ..moveTo(8, 21)
          ..lineTo(8, 5)
          ..lineTo(16, 3)
          ..lineTo(16, 21)
          ..lineTo(8, 18)
          ..moveTo(12, 12)
          ..lineTo(13, 12)
          ..moveTo(3, 21)
          ..lineTo(21, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.key:
      canvas.drawCircle(const Offset(8, 8), 5, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(12, 12)
          ..lineTo(21, 21)
          ..moveTo(17, 17)
          ..lineTo(20, 14)
          ..moveTo(20, 20)
          ..lineTo(22, 18),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.chest:
      canvas.drawPath(
        Path()
          ..moveTo(3, 11)
          ..lineTo(3, 8)
          ..arcToPoint(
            const Offset(7, 4),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(17, 4)
          ..arcToPoint(
            const Offset(21, 8),
            radius: const Radius.elliptical(4, 4),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(21, 11)
          ..moveTo(3, 11)
          ..lineTo(21, 11)
          ..lineTo(21, 21)
          ..lineTo(3, 21)
          ..lineTo(3, 11)
          ..close()
          ..moveTo(7, 4)
          ..lineTo(7, 11)
          ..moveTo(17, 4)
          ..lineTo(17, 11)
          ..moveTo(10, 11)
          ..lineTo(10, 16)
          ..lineTo(14, 16)
          ..lineTo(14, 11),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.food:
      canvas.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(3, 8)
          ..arcToPoint(
            const Offset(9, 8),
            radius: const Radius.elliptical(3, 3),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          )
          ..lineTo(9, 3)
          ..moveTo(6, 3)
          ..lineTo(6, 21)
          ..moveTo(17, 3)
          ..cubicTo(14, 6, 14, 10, 14, 13)
          ..lineTo(19, 13)
          ..lineTo(19, 3)
          ..lineTo(17, 3)
          ..close()
          ..moveTo(19, 13)
          ..lineTo(19, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.drink:
      canvas.drawPath(
        Path()
          ..moveTo(5, 7)
          ..lineTo(19, 7)
          ..lineTo(17, 21)
          ..lineTo(7, 21)
          ..lineTo(5, 7)
          ..close()
          ..moveTo(13, 7)
          ..lineTo(15, 3)
          ..lineTo(20, 3)
          ..moveTo(6, 12)
          ..lineTo(18, 12),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.build:
      canvas.drawPath(
        Path()
          ..moveTo(3, 11)
          ..lineTo(12, 3)
          ..lineTo(21, 11)
          ..moveTo(6, 10)
          ..lineTo(6, 21)
          ..lineTo(18, 21)
          ..lineTo(18, 10)
          ..moveTo(10, 21)
          ..lineTo(10, 14)
          ..lineTo(14, 14)
          ..lineTo(14, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.repair:
      canvas.drawPath(
        Path()
          ..moveTo(16, 3)
          ..cubicTo(12, 2, 8, 6, 9, 11)
          ..lineTo(3.5, 16.5)
          ..cubicTo(0.8, 19.2, 4.8, 23.2, 7.5, 20.5)
          ..lineTo(13, 15)
          ..cubicTo(18, 16, 22, 12, 21, 8)
          ..lineTo(17.5, 11.5)
          ..lineTo(12.5, 11.5)
          ..lineTo(12.5, 6.5)
          ..lineTo(16, 3)
          ..close(),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.craft:
      canvas.drawPath(
        Path()
          ..moveTo(3, 8)
          ..lineTo(21, 8)
          ..lineTo(17, 13)
          ..lineTo(12, 13)
          ..lineTo(12, 17)
          ..lineTo(17, 17)
          ..lineTo(17, 21)
          ..lineTo(6, 21)
          ..lineTo(6, 17)
          ..lineTo(9, 17)
          ..lineTo(9, 13)
          ..lineTo(7, 13)
          ..lineTo(3, 8)
          ..close()
          ..moveTo(7, 3)
          ..lineTo(17, 3)
          ..lineTo(17, 8),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.steering:
      canvas.drawCircle(const Offset(12, 12), 9, stroke);
      canvas.drawCircle(const Offset(12, 12), 2, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(3, 10)
          ..lineTo(10, 10)
          ..moveTo(14, 10)
          ..lineTo(21, 10)
          ..moveTo(11, 14)
          ..lineTo(9, 20)
          ..moveTo(13, 14)
          ..lineTo(15, 20),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.accelerate:
      canvas.drawPath(
        Path()
          ..moveTo(3, 17)
          ..arcToPoint(
            const Offset(21, 17),
            radius: const Radius.elliptical(9, 9),
            rotation: 0,
            largeArc: true,
            clockwise: true,
          )
          ..moveTo(12, 17)
          ..lineTo(17, 11)
          ..moveTo(5, 12)
          ..lineTo(7, 13)
          ..moveTo(8, 9)
          ..lineTo(9, 11)
          ..moveTo(16, 9)
          ..lineTo(15, 11)
          ..moveTo(3, 21)
          ..lineTo(21, 21),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 17), 1.5, stroke);
      break;
    case OnscreenGamepadButtonIcon.brake:
      canvas.drawCircle(const Offset(12, 12), 6, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(4, 4)
          ..arcToPoint(
            const Offset(4, 20),
            radius: const Radius.elliptical(11, 11),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          )
          ..moveTo(20, 4)
          ..arcToPoint(
            const Offset(20, 20),
            radius: const Radius.elliptical(11, 11),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..moveTo(12, 8)
          ..lineTo(12, 13)
          ..moveTo(12, 16)
          ..lineTo(12.01, 16),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.enterVehicle:
      canvas.drawPath(
        Path()
          ..moveTo(12, 5)
          ..lineTo(18, 5)
          ..lineTo(21, 12)
          ..lineTo(21, 19)
          ..lineTo(18, 19)
          ..lineTo(18, 16)
          ..lineTo(9, 16)
          ..lineTo(9, 19)
          ..lineTo(6, 19)
          ..lineTo(6, 13)
          ..moveTo(11, 12)
          ..lineTo(21, 12)
          ..moveTo(3, 4)
          ..lineTo(3, 10)
          ..lineTo(12, 10)
          ..moveTo(9, 7)
          ..lineTo(12, 10)
          ..lineTo(9, 13),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.horn:
      canvas.drawPath(
        Path()
          ..moveTo(3, 10)
          ..lineTo(8, 10)
          ..lineTo(15, 5)
          ..lineTo(15, 19)
          ..lineTo(8, 14)
          ..lineTo(3, 14)
          ..lineTo(3, 10)
          ..close()
          ..moveTo(8, 14)
          ..lineTo(8, 20)
          ..lineTo(5, 20)
          ..lineTo(5, 14)
          ..moveTo(19, 8)
          ..arcToPoint(
            const Offset(19, 16),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          ),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.ascend:
      canvas.drawPath(
        Path()
          ..moveTo(12, 21)
          ..lineTo(12, 4)
          ..moveTo(5, 11)
          ..lineTo(12, 4)
          ..lineTo(19, 11)
          ..moveTo(4, 21)
          ..lineTo(20, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.descend:
      canvas.drawPath(
        Path()
          ..moveTo(12, 3)
          ..lineTo(12, 17)
          ..moveTo(5, 10)
          ..lineTo(12, 17)
          ..lineTo(19, 10)
          ..moveTo(4, 21)
          ..lineTo(20, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.anchor:
      canvas.drawCircle(const Offset(12, 5), 2, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(12, 7)
          ..lineTo(12, 21)
          ..moveTo(8, 10)
          ..lineTo(16, 10)
          ..moveTo(3, 14)
          ..lineTo(3, 17)
          ..cubicTo(5, 20, 8, 21, 12, 21)
          ..cubicTo(16, 21, 19, 20, 21, 17)
          ..lineTo(21, 14)
          ..moveTo(3, 14)
          ..lineTo(6, 16)
          ..moveTo(21, 14)
          ..lineTo(18, 16),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.map:
      canvas.drawPath(
        Path()
          ..moveTo(3, 5)
          ..lineTo(9, 3)
          ..lineTo(15, 5)
          ..lineTo(21, 3)
          ..lineTo(21, 19)
          ..lineTo(15, 21)
          ..lineTo(9, 19)
          ..lineTo(3, 21)
          ..lineTo(3, 5)
          ..close()
          ..moveTo(9, 3)
          ..lineTo(9, 19)
          ..moveTo(15, 5)
          ..lineTo(15, 21),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.menu:
      canvas.drawPath(
        Path()
          ..moveTo(8, 6)
          ..lineTo(21, 6)
          ..moveTo(8, 12)
          ..lineTo(21, 12)
          ..moveTo(8, 18)
          ..lineTo(21, 18),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(3, 6)
          ..lineTo(3.01, 6)
          ..moveTo(3, 12)
          ..lineTo(3.01, 12)
          ..moveTo(3, 18)
          ..lineTo(3.01, 18),
        (Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round),
      );
      break;
    case OnscreenGamepadButtonIcon.pause:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 3, 4, 18),
          const Radius.circular(1),
        ),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(15, 3, 4, 18),
          const Radius.circular(1),
        ),
        fill,
      );
      break;
    case OnscreenGamepadButtonIcon.settings:
      canvas.drawPath(
        Path()
          ..moveTo(10, 3)
          ..lineTo(9.4, 6)
          ..lineTo(7.4, 6.9)
          ..lineTo(4.6, 5.9)
          ..lineTo(2.6, 9.3)
          ..lineTo(5, 11)
          ..lineTo(5, 13)
          ..lineTo(2.6, 14.7)
          ..lineTo(4.6, 18.1)
          ..lineTo(7.4, 17.1)
          ..lineTo(9.4, 18)
          ..lineTo(10, 21)
          ..lineTo(14, 21)
          ..lineTo(14.6, 18)
          ..lineTo(16.6, 17.1)
          ..lineTo(19.4, 18.1)
          ..lineTo(21.4, 14.7)
          ..lineTo(19, 13)
          ..lineTo(19, 11)
          ..lineTo(21.4, 9.3)
          ..lineTo(19.4, 5.9)
          ..lineTo(16.6, 6.9)
          ..lineTo(14.6, 6)
          ..lineTo(14, 3)
          ..lineTo(10, 3)
          ..close(),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 12), 3, stroke);
      break;
    case OnscreenGamepadButtonIcon.quest:
      canvas.drawPath(
        Path()
          ..moveTo(8, 5)
          ..lineTo(5, 5)
          ..lineTo(5, 21)
          ..lineTo(19, 21)
          ..lineTo(19, 5)
          ..lineTo(16, 5)
          ..moveTo(8, 3)
          ..lineTo(16, 3)
          ..lineTo(16, 7)
          ..lineTo(8, 7)
          ..lineTo(8, 3)
          ..close()
          ..moveTo(8, 12)
          ..lineTo(16, 12)
          ..moveTo(8, 17)
          ..lineTo(13, 17),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.marker:
      canvas.drawPath(
        Path()
          ..moveTo(19, 9)
          ..cubicTo(19, 14, 12, 21, 12, 21)
          ..cubicTo(12, 21, 5, 14, 5, 9)
          ..arcToPoint(
            const Offset(19, 9),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..close(),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 9), 2, stroke);
      break;
    case OnscreenGamepadButtonIcon.mic:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(9, 3, 6, 12),
          const Radius.circular(3),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5, 11)
          ..lineTo(5, 12)
          ..arcToPoint(
            const Offset(19, 12),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: false,
          )
          ..lineTo(19, 11)
          ..moveTo(12, 19)
          ..lineTo(12, 22)
          ..moveTo(8, 22)
          ..lineTo(16, 22),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.chat:
      canvas.drawPath(
        Path()
          ..moveTo(3, 4)
          ..lineTo(17, 4)
          ..lineTo(17, 15)
          ..lineTo(8, 15)
          ..lineTo(3, 19)
          ..lineTo(3, 4)
          ..close()
          ..moveTo(17, 8)
          ..lineTo(21, 8)
          ..lineTo(21, 21)
          ..lineTo(16, 18)
          ..lineTo(12, 18),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.camera:
      canvas.drawPath(
        Path()
          ..moveTo(3, 7)
          ..lineTo(8, 7)
          ..lineTo(10, 4)
          ..lineTo(14, 4)
          ..lineTo(16, 7)
          ..lineTo(21, 7)
          ..lineTo(21, 21)
          ..lineTo(3, 21)
          ..lineTo(3, 7)
          ..close(),
        stroke,
      );
      canvas.drawCircle(const Offset(12, 13), 4, stroke);
      break;
    case OnscreenGamepadButtonIcon.compass:
      canvas.drawCircle(const Offset(12, 12), 9, stroke);
      canvas.drawPath(
        Path()
          ..moveTo(16, 7)
          ..lineTo(14, 14)
          ..lineTo(8, 17)
          ..lineTo(10, 10)
          ..lineTo(16, 7)
          ..close()
          ..moveTo(10, 10)
          ..lineTo(14, 14),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.mouseLeft:
      canvas.drawPath(
        Path()
          ..moveTo(5, 10)
          ..lineTo(5, 9)
          ..arcToPoint(
            const Offset(12, 2),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(12, 10)
          ..lineTo(5, 10)
          ..close(),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 2, 14, 20),
          const Radius.circular(7),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5, 10)
          ..lineTo(19, 10)
          ..moveTo(12, 2)
          ..lineTo(12, 10),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.mouseRight:
      canvas.drawPath(
        Path()
          ..moveTo(12, 2)
          ..arcToPoint(
            const Offset(19, 9),
            radius: const Radius.elliptical(7, 7),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(19, 10)
          ..lineTo(12, 10)
          ..lineTo(12, 2)
          ..close(),
        fill,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 2, 14, 20),
          const Radius.circular(7),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(5, 10)
          ..lineTo(19, 10)
          ..moveTo(12, 2)
          ..lineTo(12, 10),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.mouseMiddle:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 2, 14, 20),
          const Radius.circular(7),
        ),
        stroke,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(10, 5, 4, 7),
          const Radius.circular(2),
        ),
        fill,
      );
      break;
    case OnscreenGamepadButtonIcon.scrollUp:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 4, 12, 18),
          const Radius.circular(6),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 8)
          ..lineTo(9, 11)
          ..moveTo(20, 14)
          ..lineTo(20, 3)
          ..moveTo(17, 6)
          ..lineTo(20, 3)
          ..lineTo(23, 6),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.scrollDown:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 2, 12, 18),
          const Radius.circular(6),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9, 6)
          ..lineTo(9, 9)
          ..moveTo(20, 10)
          ..lineTo(20, 21)
          ..moveTo(17, 18)
          ..lineTo(20, 21)
          ..lineTo(23, 18),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.keyboard:
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 5, 20, 14),
          const Radius.circular(2),
        ),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(6, 9)
          ..lineTo(6.01, 9)
          ..moveTo(10, 9)
          ..lineTo(10.01, 9)
          ..moveTo(14, 9)
          ..lineTo(14.01, 9)
          ..moveTo(18, 9)
          ..lineTo(18.01, 9)
          ..moveTo(6, 13)
          ..lineTo(6.01, 13)
          ..moveTo(10, 13)
          ..lineTo(10.01, 13)
          ..moveTo(14, 13)
          ..lineTo(14.01, 13)
          ..moveTo(18, 13)
          ..lineTo(18.01, 13)
          ..moveTo(8, 16)
          ..lineTo(16, 16),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.gamepad:
      canvas.drawPath(
        Path()
          ..moveTo(8, 6)
          ..lineTo(16, 6)
          ..cubicTo(19, 6, 20, 9, 21, 13)
          ..lineTo(22, 18)
          ..cubicTo(22, 21, 19, 21, 17, 18)
          ..lineTo(15, 16)
          ..lineTo(9, 16)
          ..lineTo(7, 18)
          ..cubicTo(5, 21, 2, 21, 2, 18)
          ..lineTo(3, 13)
          ..cubicTo(4, 9, 5, 6, 8, 6)
          ..close()
          ..moveTo(7, 9)
          ..lineTo(7, 15)
          ..moveTo(4, 12)
          ..lineTo(10, 12)
          ..moveTo(16, 10)
          ..lineTo(16.01, 10)
          ..moveTo(19, 13)
          ..lineTo(19.01, 13),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.dpad:
      canvas.drawPath(
        Path()
          ..moveTo(8, 3)
          ..lineTo(16, 3)
          ..lineTo(16, 8)
          ..lineTo(21, 8)
          ..lineTo(21, 16)
          ..lineTo(16, 16)
          ..lineTo(16, 21)
          ..lineTo(8, 21)
          ..lineTo(8, 16)
          ..lineTo(3, 16)
          ..lineTo(3, 8)
          ..lineTo(8, 8)
          ..lineTo(8, 3)
          ..close()
          ..moveTo(10, 6)
          ..lineTo(14, 6)
          ..moveTo(10, 18)
          ..lineTo(14, 18)
          ..moveTo(6, 10)
          ..lineTo(6, 14)
          ..moveTo(18, 10)
          ..lineTo(18, 14),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.stick:
      canvas.drawCircle(const Offset(12, 8), 5, stroke);
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(12, 19), width: 18, height: 6),
        stroke,
      );
      canvas.drawPath(
        Path()
          ..moveTo(12, 13)
          ..lineTo(12, 19),
        stroke,
      );
      break;
    case OnscreenGamepadButtonIcon.trigger:
      canvas.drawPath(
        Path()
          ..moveTo(4, 17)
          ..lineTo(4, 8)
          ..arcToPoint(
            const Offset(9, 3),
            radius: const Radius.elliptical(5, 5),
            rotation: 0,
            largeArc: false,
            clockwise: true,
          )
          ..lineTo(18, 3)
          ..lineTo(20, 7)
          ..lineTo(20, 17)
          ..lineTo(4, 17)
          ..close()
          ..moveTo(8, 17)
          ..lineTo(8, 21)
          ..lineTo(16, 21)
          ..lineTo(16, 17)
          ..moveTo(8, 8)
          ..lineTo(16, 8)
          ..moveTo(8, 12)
          ..lineTo(13, 12),
        stroke,
      );
      break;
  }
}
