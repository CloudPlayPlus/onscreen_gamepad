import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onscreen_gamepad_layout.dart';
import 'onscreen_gamepad_models.dart';

typedef OnscreenGamepadControlEvent =
    void Function(OnscreenGamepadControl control);
typedef OnscreenGamepadStickEvent =
    void Function(OnscreenGamepadControl control, Offset value);

class OnscreenGamepadOverlay extends StatelessWidget {
  const OnscreenGamepadOverlay({
    super.key,
    required this.profile,
    this.layoutEngine = const OnscreenGamepadLayoutEngine(),
    this.logicalSize,
    this.showZones = false,
    this.activeControlIds = const {},
    this.onControlDown,
    this.onControlUp,
    this.onStickChanged,
  });

  final OnscreenGamepadProfile profile;
  final OnscreenGamepadLayoutEngine layoutEngine;
  final Size? logicalSize;
  final bool showZones;
  final Set<String> activeControlIds;
  final OnscreenGamepadControlEvent? onControlDown;
  final OnscreenGamepadControlEvent? onControlUp;
  final OnscreenGamepadStickEvent? onStickChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderSize = Size(
          math.max(1.0, constraints.maxWidth),
          math.max(1.0, constraints.maxHeight),
        );
        final result = layoutEngine.layout(
          renderSize: renderSize,
          logicalSize: logicalSize,
          profile: profile,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (showZones)
              for (final entry in result.zones.entries)
                Positioned.fromRect(
                  rect: entry.value,
                  child: _ZonePaint(anchor: entry.key),
                ),
            for (final placed in result.controls)
              Positioned.fromRect(
                rect: placed.hitRect,
                child: _ControlButton(
                  key: ValueKey(placed.control.id),
                  placed: placed,
                  profile: profile,
                  isActive: activeControlIds.contains(placed.control.id),
                  onDown: onControlDown,
                  onUp: onControlUp,
                  onStickChanged: onStickChanged,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    super.key,
    required this.placed,
    required this.profile,
    required this.isActive,
    this.onDown,
    this.onUp,
    this.onStickChanged,
  });

  final OnscreenGamepadPlacedControl placed;
  final OnscreenGamepadProfile profile;
  final bool isActive;
  final OnscreenGamepadControlEvent? onDown;
  final OnscreenGamepadControlEvent? onUp;
  final OnscreenGamepadStickEvent? onStickChanged;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  int? _activePointer;
  Offset _stickValue = Offset.zero;

  @override
  void didUpdateWidget(covariant _ControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placed.control.id != widget.placed.control.id) {
      _activePointer = null;
      _stickValue = Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.placed.control;
    final color = _withOpacity(
      control.color ?? widget.profile.defaultColor,
      widget.profile.opacity,
    );
    final activeColor = Color.alphaBlend(
      _withOpacity(Colors.white, 0.22),
      color,
    );
    final fillColor = widget.isActive || _activePointer != null
        ? activeColor
        : color;
    final foreground = _bestTextColor(fillColor);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Center(
        child: _ControlVisual(
          control: control,
          fillColor: fillColor,
          foreground: foreground,
          size: widget.placed.visualSize,
          isActive: widget.isActive || _activePointer != null,
          stickValue: _stickValue,
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointer != null) {
      return;
    }
    _activePointer = event.pointer;
    final control = widget.placed.control;
    widget.onDown?.call(control);
    if (_isStick(control)) {
      _updateStick(event.localPosition);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer || !_isStick(widget.placed.control)) {
      return;
    }
    _updateStick(event.localPosition);
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _releasePointer();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    _releasePointer();
  }

  void _releasePointer() {
    final control = widget.placed.control;
    if (_isStick(control)) {
      _setStickValue(Offset.zero);
    }
    widget.onUp?.call(control);
    _activePointer = null;
  }

  void _updateStick(Offset localPosition) {
    final half = widget.placed.hitSize / 2;
    final raw = Offset(
      (localPosition.dx - half) / half,
      (localPosition.dy - half) / half,
    );
    final distance = raw.distance;
    final value = distance <= 1 || distance == 0 ? raw : raw / distance;
    _setStickValue(value);
  }

  void _setStickValue(Offset value) {
    if ((_stickValue - value).distance < 0.001) {
      return;
    }
    setState(() => _stickValue = value);
    widget.onStickChanged?.call(widget.placed.control, value);
  }

  bool _isStick(OnscreenGamepadControl control) {
    return control.kind == OnscreenGamepadControlKind.stick;
  }
}

class _ControlVisual extends StatelessWidget {
  const _ControlVisual({
    required this.control,
    required this.fillColor,
    required this.foreground,
    required this.size,
    required this.isActive,
    required this.stickValue,
  });

  final OnscreenGamepadControl control;
  final Color fillColor;
  final Color foreground;
  final double size;
  final bool isActive;
  final Offset stickValue;

  @override
  Widget build(BuildContext context) {
    final shape = switch (control.kind) {
      OnscreenGamepadControlKind.circle ||
      OnscreenGamepadControlKind.stick => BoxShape.circle,
      OnscreenGamepadControlKind.square => BoxShape.rectangle,
    };
    final borderRadius = control.kind == OnscreenGamepadControlKind.square
        ? BorderRadius.circular(math.min(10, size * 0.22))
        : null;

    return AnimatedScale(
      duration: const Duration(milliseconds: 90),
      scale: isActive ? 0.94 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: borderRadius,
          color: fillColor,
          border: Border.all(
            color: _withOpacity(Colors.white, isActive ? 0.72 : 0.38),
            width: math.max(1.0, size * 0.035),
          ),
          boxShadow: [
            BoxShadow(
              color: _withOpacity(Colors.black, 0.22),
              blurRadius: size * 0.18,
              offset: Offset(0, size * 0.05),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: size,
          child: control.kind == OnscreenGamepadControlKind.stick
              ? _StickFace(
                  color: foreground,
                  size: size,
                  label: control.label,
                  value: stickValue,
                )
              : Center(
                  child: Text(
                    control.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: foreground,
                      fontSize: math.max(11, size * 0.25),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StickFace extends StatelessWidget {
  const _StickFace({
    required this.color,
    required this.size,
    required this.label,
    required this.value,
  });

  final Color color;
  final double size;
  final String label;
  final Offset value;

  @override
  Widget build(BuildContext context) {
    final knobSize = size * 0.22;
    final outerBorder = math.max(1.0, size * 0.035);
    final maxTravel = math.max(0.0, size / 2 - outerBorder);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _withOpacity(color, 0.44),
              fontSize: math.max(10, size * 0.16),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          Transform.translate(
            offset: Offset(value.dx * maxTravel, value.dy * maxTravel),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _withOpacity(color, 0.48),
                border: Border.all(
                  color: _withOpacity(color, 0.18),
                  width: math.max(1.0, size * 0.018),
                ),
              ),
              child: SizedBox.square(dimension: knobSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZonePaint extends StatelessWidget {
  const _ZonePaint({required this.anchor});

  final OnscreenGamepadAnchor anchor;

  @override
  Widget build(BuildContext context) {
    final color = switch (anchor) {
      OnscreenGamepadAnchor.topLeft => const Color(0xFF6BE6C8),
      OnscreenGamepadAnchor.topRight => const Color(0xFFFFD166),
      OnscreenGamepadAnchor.bottomLeft => const Color(0xFF69A7FF),
      OnscreenGamepadAnchor.bottomCenter => const Color(0xFFFF7A90),
      OnscreenGamepadAnchor.bottomRight => const Color(0xFFA98BFF),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _withOpacity(color, 0.06),
        border: Border.all(color: _withOpacity(color, 0.36)),
      ),
    );
  }
}

Color _bestTextColor(Color color) {
  return color.computeLuminance() > 0.48
      ? const Color(0xFF10151F)
      : Colors.white;
}

Color _withOpacity(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0, 1) * 255).round());
}
