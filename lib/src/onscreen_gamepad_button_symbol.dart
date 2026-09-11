import 'package:flutter/material.dart';
import 'onscreen_gamepad_models.dart';

part 'onscreen_gamepad_button_paths.dart';

/// 与网页预览共源的轻量矢量图案，无位图和运行时 SVG 解析。
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
    _paintButtonSymbol(canvas, icon, color, isActive);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SymbolPainter old) =>
      old.icon != icon || old.color != color || old.isActive != isActive;
}
