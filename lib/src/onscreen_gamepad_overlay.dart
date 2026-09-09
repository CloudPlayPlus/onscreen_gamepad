import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onscreen_gamepad_events.dart';
import 'onscreen_gamepad_layout.dart';
import 'onscreen_gamepad_models.dart';

const _kStickTapThresholdRatio = 0.01;
const _kStickTapButtonDelay = Duration(milliseconds: 32);
const _kFloatingStickActivationScale = 1.8;

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
                rect: _interactionRectFor(placed, result.renderSize),
                child: _ControlButton(
                  key: ValueKey(placed.control.id),
                  placed: placed,
                  interactionRect: _interactionRectFor(
                    placed,
                    result.renderSize,
                  ),
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
    required this.interactionRect,
    required this.profile,
    required this.isActive,
    this.onEvent,
    this.onDown,
    this.onUp,
    this.onStickChanged,
  });

  final OnscreenGamepadPlacedControl placed;
  final Rect interactionRect;
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
  Offset? _stickOrigin;
  Offset? _stickVisualCenter;
  bool _stickTapCandidate = false;
  Offset? _lastPointerPosition;
  bool _isToggled = false;
  int _mouseModeIndex = 0;

  @override
  void didUpdateWidget(covariant _ControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placed.control.id != widget.placed.control.id ||
        oldWidget.placed.control.stickMode != widget.placed.control.stickMode) {
      _activePointer = null;
      _stickValue = Offset.zero;
      _stickOrigin = null;
      _stickVisualCenter = null;
      _stickTapCandidate = false;
      _lastPointerPosition = null;
      _isToggled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final control = widget.placed.control;
    final backgroundColor = control.color ?? widget.profile.defaultColor;
    final backgroundOpacity = widget.profile.backgroundOpacity;
    final color = _withOpacity(backgroundColor, backgroundOpacity);
    final activeBaseColor = Color.alphaBlend(
      _withOpacity(Colors.white, 0.22),
      backgroundColor.withAlpha(255),
    );
    final activeColor = _withOpacity(activeBaseColor, backgroundOpacity);
    final isActive = widget.isActive || _activePointer != null || _isToggled;
    final fillColor = isActive ? activeColor : color;
    final foreground = _withOpacity(
      _bestTextColor(backgroundColor),
      widget.profile.foregroundOpacity,
    );
    final defaultVisualCenter =
        widget.placed.center - widget.interactionRect.topLeft;
    final visualCenter = _usesFloatingFollow(control) && _activePointer != null
        ? _stickVisualCenter ?? defaultVisualCenter
        : defaultVisualCenter;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: visualCenter.dx - widget.placed.visualSize / 2,
            top: visualCenter.dy - widget.placed.visualSize / 2,
            child: SizedBox.square(
              key: ValueKey('stick.visual.${control.id}'),
              dimension: widget.placed.visualSize,
              child: _ControlVisual(
                control: control,
                fillColor: fillColor,
                foreground: foreground,
                size: widget.placed.visualSize,
                isActive: isActive,
                stickValue: _stickValue,
                showStickDirection:
                    _usesFloatingFollow(control) && _activePointer != null,
              ),
            ),
          ),
        ],
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
      _beginStick(event.localPosition);
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
    _releasePointer(allowStickTap: false);
  }

  void _releasePointer({bool allowStickTap = true}) {
    final control = widget.placed.control;
    if (control.behavior == OnscreenGamepadControlBehavior.toggle) {
      setState(() {
        _activePointer = null;
        _stickOrigin = null;
        _stickVisualCenter = null;
        _stickTapCandidate = false;
        _lastPointerPosition = null;
      });
      return;
    }
    if (control.behavior == OnscreenGamepadControlBehavior.mouseModeCycle) {
      setState(() {
        _activePointer = null;
        _stickOrigin = null;
        _stickVisualCenter = null;
        _stickTapCandidate = false;
        _lastPointerPosition = null;
      });
      return;
    }
    final shouldEmitStickTap =
        allowStickTap && _isStick(control) && _stickTapCandidate;
    if (_isStick(control)) {
      if (shouldEmitStickTap) {
        _emitStickButtonTap(control);
      }
      _setStickValue(Offset.zero);
    }
    _emitControlPhase(OnscreenGamepadEventPhase.up);
    setState(() {
      _activePointer = null;
      _stickOrigin = null;
      _stickVisualCenter = null;
      _stickTapCandidate = false;
      _lastPointerPosition = null;
    });
  }

  void _beginStick(Offset localPosition) {
    setState(() {
      _stickOrigin = localPosition;
      _stickVisualCenter = _usesFloatingFollow(widget.placed.control)
          ? localPosition
          : null;
      _stickTapCandidate = true;
      _stickValue = Offset.zero;
    });
  }

  void _updateStick(Offset localPosition) {
    final radius = widget.placed.hitSize / 2;
    var origin =
        _stickOrigin ?? widget.placed.center - widget.interactionRect.topLeft;
    var delta = localPosition - origin;
    final dragDistance = delta.distance;
    if (_usesFloatingFollow(widget.placed.control) &&
        dragDistance > radius &&
        dragDistance > 0) {
      final direction = delta / dragDistance;
      origin = localPosition - direction * radius;
      delta = localPosition - origin;
      setState(() {
        _stickOrigin = origin;
        _stickVisualCenter = origin;
      });
    }
    final raw = delta / radius;
    final distance = raw.distance;
    if (distance > _kStickTapThresholdRatio) {
      _stickTapCandidate = false;
    }
    final value = distance <= 1 || distance == 0 ? raw : raw / distance;
    _setStickValue(value);
  }

  void _emitStickButtonTap(OnscreenGamepadControl control) {
    final buttonCode = control.input.buttonCode;
    if (control.input.kind != OnscreenGamepadInputKind.gamepadStick ||
        buttonCode == null ||
        buttonCode.isEmpty) {
      return;
    }
    final buttonInput = OnscreenGamepadInput.gamepadButton(buttonCode);
    widget.onEvent?.call(
      OnscreenGamepadEvent(
        type: OnscreenGamepadEventType.gamepadButton,
        phase: OnscreenGamepadEventPhase.down,
        control: control,
        input: buttonInput,
      ),
    );
    Future<void>.delayed(_kStickTapButtonDelay, () {
      if (!mounted) {
        return;
      }
      widget.onEvent?.call(
        OnscreenGamepadEvent(
          type: OnscreenGamepadEventType.gamepadButton,
          phase: OnscreenGamepadEventPhase.up,
          control: control,
          input: buttonInput,
        ),
      );
    });
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

  bool _usesFloatingFollow(OnscreenGamepadControl control) {
    return _isStick(control) &&
        control.stickMode == OnscreenGamepadStickMode.floatingFollow;
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
    required this.showStickDirection,
  });

  final OnscreenGamepadControl control;
  final Color fillColor;
  final Color foreground;
  final double size;
  final bool isActive;
  final Offset stickValue;
  final bool showStickDirection;

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
          boxShadow: [
            BoxShadow(
              color: _withOpacity(Colors.black, 0.40),
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
                  showDirection: showStickDirection,
                  directionKey: ValueKey('stick.direction.${control.id}'),
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
    required this.showDirection,
    required this.directionKey,
  });

  final Color color;
  final double size;
  final String label;
  final Offset value;
  final bool showDirection;
  final Key directionKey;

  @override
  Widget build(BuildContext context) {
    final knobSize = size * 0.22;
    final edgeInset = math.max(1.0, size * 0.035);
    final maxTravel = math.max(0.0, size / 2 - edgeInset);

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: math.max(10, size * 0.16),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          if (showDirection && value.distance > 0.08)
            Positioned.fill(
              key: directionKey,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _StickDirectionPainter(color: color, value: value),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(value.dx * maxTravel, value.dy * maxTravel),
            child: DecoratedBox(
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: SizedBox.square(dimension: knobSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickDirectionPainter extends CustomPainter {
  const _StickDirectionPainter({required this.color, required this.value});

  final Color color;
  final Offset value;

  @override
  void paint(Canvas canvas, Size size) {
    final distance = value.distance;
    if (distance <= 0) {
      return;
    }
    final direction = value / distance;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const sectorCount = 8;
    const sectorSweep = math.pi * 2 / sectorCount;
    final directionAngle = math.atan2(direction.dy, direction.dx);
    final activeSector =
        ((directionAngle + sectorSweep / 2) / sectorSweep).floor() %
        sectorCount;
    final ringRadius = radius * 1.08;
    final ringBounds = Rect.fromCircle(center: center, radius: ringRadius);
    final gap = math.max(0.055, 5 / ringRadius);
    final inactivePaint = Paint()
      ..color = color.withAlpha((color.a * 255 * 0.28).round())
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(3.0, radius * 0.13);
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(4.0, radius * 0.21);

    for (var index = 0; index < sectorCount; index += 1) {
      final sectorCenter = index * sectorSweep;
      final startAngle = sectorCenter - sectorSweep / 2 + gap / 2;
      canvas.drawArc(
        ringBounds,
        startAngle,
        sectorSweep - gap,
        false,
        index == activeSector ? activePaint : inactivePaint,
      );
    }

    final activeCenter = activeSector * sectorSweep;
    final boundaryPaint = Paint()
      ..color = color.withAlpha((color.a * 255 * 0.86).round())
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.5, radius * 0.035);
    for (final boundaryAngle in [
      activeCenter - sectorSweep / 2,
      activeCenter + sectorSweep / 2,
    ]) {
      final unit = Offset(math.cos(boundaryAngle), math.sin(boundaryAngle));
      canvas.drawLine(
        center + unit * radius * 0.78,
        center + unit * radius * 1.28,
        boundaryPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StickDirectionPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.value != value;
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

Rect _interactionRectFor(OnscreenGamepadPlacedControl placed, Size renderSize) {
  if (placed.control.kind != OnscreenGamepadControlKind.stick ||
      placed.control.stickMode != OnscreenGamepadStickMode.floatingFollow) {
    return placed.hitRect;
  }
  final expanded = Rect.fromCenter(
    center: placed.center,
    width: placed.hitSize * _kFloatingStickActivationScale,
    height: placed.hitSize * _kFloatingStickActivationScale,
  );
  return expanded.intersect(Offset.zero & renderSize);
}
