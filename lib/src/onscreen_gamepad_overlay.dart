import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onscreen_gamepad_events.dart';
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
    this.onEvent,
    this.onControlDown,
    this.onControlUp,
    this.onStickChanged,
  });

  final OnscreenGamepadProfile profile;
  final OnscreenGamepadLayoutEngine layoutEngine;
  final Size? logicalSize;
  final bool showZones;
  final Set<String> activeControlIds;
  final OnscreenGamepadEventCallback? onEvent;
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
                  onEvent: onEvent,
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
    this.onEvent,
    this.onDown,
    this.onUp,
    this.onStickChanged,
  });

  final OnscreenGamepadPlacedControl placed;
  final OnscreenGamepadProfile profile;
  final bool isActive;
  final OnscreenGamepadEventCallback? onEvent;
  final OnscreenGamepadControlEvent? onDown;
  final OnscreenGamepadControlEvent? onUp;
  final OnscreenGamepadStickEvent? onStickChanged;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  int? _activePointer;
  Offset _stickValue = Offset.zero;
  Offset? _lastPointerPosition;
  bool _isToggled = false;
  int _mouseModeIndex = 0;

  @override
  void didUpdateWidget(covariant _ControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placed.control.id != widget.placed.control.id) {
      _activePointer = null;
      _stickValue = Offset.zero;
      _lastPointerPosition = null;
      _isToggled = false;
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
    final isActive = widget.isActive || _activePointer != null || _isToggled;
    final fillColor = isActive ? activeColor : color;
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
          isActive: isActive,
          stickValue: _stickValue,
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_activePointer != null) {
      return;
    }
    setState(() {
      _activePointer = event.pointer;
      _lastPointerPosition = event.localPosition;
    });
    final control = widget.placed.control;
    if (control.behavior == OnscreenGamepadControlBehavior.toggle) {
      _setToggled(!_isToggled);
      return;
    }
    if (control.behavior == OnscreenGamepadControlBehavior.mouseModeCycle) {
      _cycleMouseMode(control);
      return;
    }
    _emitControlPhase(OnscreenGamepadEventPhase.down);
    if (_isStick(control)) {
      _updateStick(event.localPosition);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) {
      return;
    }
    final control = widget.placed.control;
    if (_isStick(control)) {
      _updateStick(event.localPosition);
    }
    if (control.behavior == OnscreenGamepadControlBehavior.fpsFire) {
      _emitFpsFireMove(event.localPosition);
    }
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
    if (control.behavior == OnscreenGamepadControlBehavior.toggle) {
      setState(() {
        _activePointer = null;
        _lastPointerPosition = null;
      });
      return;
    }
    if (control.behavior == OnscreenGamepadControlBehavior.mouseModeCycle) {
      setState(() {
        _activePointer = null;
        _lastPointerPosition = null;
      });
      return;
    }
    if (_isStick(control)) {
      _setStickValue(Offset.zero);
    }
    _emitControlPhase(OnscreenGamepadEventPhase.up);
    setState(() {
      _activePointer = null;
      _lastPointerPosition = null;
    });
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
    widget.onEvent?.call(
      OnscreenGamepadEvent.stickChanged(
        control: widget.placed.control,
        value: value,
      ),
    );
    widget.onStickChanged?.call(widget.placed.control, value);
  }

  void _emitControlPhase(OnscreenGamepadEventPhase phase) {
    final control = widget.placed.control;
    widget.onEvent?.call(_eventForPhase(control, phase));
    switch (phase) {
      case OnscreenGamepadEventPhase.down:
        widget.onDown?.call(control);
      case OnscreenGamepadEventPhase.up:
        widget.onUp?.call(control);
      case OnscreenGamepadEventPhase.change:
        break;
    }
  }

  OnscreenGamepadEvent _eventForPhase(
    OnscreenGamepadControl control,
    OnscreenGamepadEventPhase phase,
  ) {
    if (control.input.kind == OnscreenGamepadInputKind.mouseMode) {
      return OnscreenGamepadEvent.mouseMode(
        control: control,
        mode: control.input.code,
        phase: phase,
      );
    }
    return OnscreenGamepadEvent.control(control: control, phase: phase);
  }

  void _setToggled(bool value) {
    setState(() => _isToggled = value);
    _emitControlPhase(
      value ? OnscreenGamepadEventPhase.down : OnscreenGamepadEventPhase.up,
    );
  }

  void _cycleMouseMode(OnscreenGamepadControl control) {
    final modes = _stringListConfig('modes');
    final mode = modes.isEmpty
        ? control.input.code
        : modes[_mouseModeIndex % modes.length];
    if (modes.isNotEmpty) {
      _mouseModeIndex = (_mouseModeIndex + 1) % modes.length;
    }
    widget.onEvent?.call(
      OnscreenGamepadEvent.mouseMode(
        control: control,
        mode: mode,
        phase: OnscreenGamepadEventPhase.change,
      ),
    );
  }

  void _emitFpsFireMove(Offset localPosition) {
    final lastPosition = _lastPointerPosition;
    if (lastPosition == null) {
      _lastPointerPosition = localPosition;
      return;
    }
    final sensitivity = _doubleConfig('sensitivity', 1.0);
    final threshold = _doubleConfig('threshold', 0.5);
    final delta = (localPosition - lastPosition) * sensitivity;
    if (delta.dx.abs() > threshold || delta.dy.abs() > threshold) {
      widget.onEvent?.call(
        OnscreenGamepadEvent.mouseMove(
          control: widget.placed.control,
          delta: delta,
        ),
      );
      _lastPointerPosition = localPosition;
    }
  }

  double _doubleConfig(String key, double fallback) {
    final value = widget.placed.control.behaviorConfig[key];
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  List<String> _stringListConfig(String key) {
    final value = widget.placed.control.behaviorConfig[key];
    if (value is List) {
      return [
        for (final item in value)
          if (item is String && item.isNotEmpty) item,
      ];
    }
    return const [];
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
