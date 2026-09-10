import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onscreen_gamepad_events.dart';
import 'onscreen_gamepad_layout.dart';
import 'onscreen_gamepad_models.dart';

const _kStickTapThresholdRatio = 0.01;
const _kStickTapButtonDelay = Duration(milliseconds: 32);
const _kStickDeadZone = 1.0;
const _kStickTravel = 40.0;

Rect _interactionRect(OnscreenGamepadPlacedControl placed, Size size) {
  if (!placed.control.isMovementStick || !placed.control.regionTrigger) {
    return placed.hitRect;
  }
  final left = placed.hitRect.center.dx < size.width / 2;
  return Rect.fromLTWH(
    left ? 0 : size.width / 2,
    size.height * .28,
    size.width / 2,
    size.height * .72,
  ).expandToInclude(placed.hitRect);
}

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
            // 移动摇杆的扩大区域置底，任何普通按钮的 hitbox 都优先响应。
            for (final placed in [
              ...result.controls.where((p) => p.control.isMovementStick),
              ...result.controls.where((p) => !p.control.isMovementStick),
            ])
              Positioned.fromRect(
                key: ValueKey('position-${placed.control.id}'),
                rect: _interactionRect(placed, renderSize),
                child: _ControlButton(
                  key: ValueKey(placed.control.id),
                  placed: placed,
                  interactionRect: _interactionRect(placed, renderSize),
                  feedbackCenter:
                      placed.positionFeedbackCenter(renderSize) -
                      _interactionRect(placed, renderSize).topLeft,
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
    required this.feedbackCenter,
    required this.profile,
    required this.isActive,
    this.onEvent,
    this.onDown,
    this.onUp,
    this.onStickChanged,
  });

  final OnscreenGamepadPlacedControl placed;
  final Rect interactionRect;
  final Offset feedbackCenter;
  final OnscreenGamepadProfile profile;
  final bool isActive;
  final OnscreenGamepadEventCallback? onEvent;
  final OnscreenGamepadControlEvent? onDown;
  final OnscreenGamepadControlEvent? onUp;
  final OnscreenGamepadStickEvent? onStickChanged;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with WidgetsBindingObserver {
  int? _activePointer;
  Offset _stickValue = Offset.zero;
  Offset? _stickOrigin;
  Offset? _stickTouchDown;
  bool _stickTapCandidate = false;
  Offset? _lastPointerPosition;
  bool _isToggled = false;
  int _mouseModeIndex = 0;
  final _pendingStickButtonUps = <VoidCallback>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelInput(widget, afterFrame: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        (_activePointer != null ||
            _isToggled ||
            _pendingStickButtonUps.isNotEmpty)) {
      _cancelInput(widget);
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant _ControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placed.control.id != widget.placed.control.id ||
        oldWidget.placed.control.stickCenterMode !=
            widget.placed.control.stickCenterMode ||
        oldWidget.placed.control.regionTrigger !=
            widget.placed.control.regionTrigger ||
        oldWidget.interactionRect != widget.interactionRect ||
        oldWidget.placed.hitRect != widget.placed.hitRect ||
        oldWidget.placed.visualSize != widget.placed.visualSize) {
      _cancelInput(oldWidget, afterFrame: true);
    }
  }

  void _cancelInput(_ControlButton source, {bool afterFrame = false}) {
    final control = source.placed.control;
    final active = switch (control.behavior) {
      OnscreenGamepadControlBehavior.toggle => _isToggled,
      OnscreenGamepadControlBehavior.mouseModeCycle => false,
      _ => _activePointer != null,
    };
    final wasMoving = _stickValue != Offset.zero;
    final pendingStickButtonUps = _pendingStickButtonUps.toList();
    // 先清除本地手势，旧命中路径后续的 move/up 不得再次输出。
    _activePointer = null;
    _stickValue = Offset.zero;
    _stickOrigin = null;
    _stickTouchDown = null;
    _stickTapCandidate = false;
    _lastPointerPosition = null;
    _isToggled = false;
    if (!active && !wasMoving && pendingStickButtonUps.isEmpty) return;

    void release() {
      for (final up in pendingStickButtonUps) {
        up();
      }
      if (wasMoving) {
        source.onEvent?.call(
          OnscreenGamepadEvent.stickChanged(
            control: control,
            value: Offset.zero,
          ),
        );
        source.onStickChanged?.call(control, Offset.zero);
      }
      if (active) {
        source.onEvent?.call(
          OnscreenGamepadEvent.control(
            control: control,
            phase: OnscreenGamepadEventPhase.up,
          ),
        );
        source.onUp?.call(control);
      }
    }

    // build/dispose 时不可同步触发父组件 setState，回调固定到原输入消费者。
    if (afterFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) => release());
    } else {
      release();
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
      Colors.white,
      widget.profile.foregroundOpacity,
    );

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerCancel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_isStick(control) && _activePointer != null) ...[
            if (!control.positionFeedbackEnabled &&
                _stickOrigin != null &&
                _stickValue != Offset.zero)
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center: _stickOrigin!,
                  width: widget.placed.visualSize * .68,
                  height: widget.placed.visualSize * .68,
                ),
                child: IgnorePointer(
                  child: CustomPaint(
                    key: ValueKey('${control.id}-semicircle'),
                    painter: OnscreenGamepadSemicirclePainter(
                      direction: _stickValue.direction,
                      color: _withOpacity(
                        Colors.white,
                        widget.profile.semicircleOpacity,
                      ),
                    ),
                  ),
                ),
              ),
            if (control.positionFeedbackEnabled &&
                _stickOrigin != null &&
                _lastPointerPosition != null &&
                _stickValue != Offset.zero) ...[
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center: widget.feedbackCenter,
                  width: widget.placed.visualSize * .68,
                  height: widget.placed.visualSize * .68,
                ),
                child: IgnorePointer(
                  child: CustomPaint(
                    key: ValueKey('${control.id}-position-feedback'),
                    painter: OnscreenGamepadSemicirclePainter(
                      direction: _stickValue.direction,
                      color: _withOpacity(
                        Colors.white,
                        widget.profile.semicircleOpacity,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center:
                      widget.feedbackCenter +
                      _lastPointerPosition! -
                      _stickOrigin!,
                  width: 6,
                  height: 6,
                ),
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: ValueKey('${control.id}-touch-dot'),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: foreground,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: foreground.a),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ] else
            Positioned.fromRect(
              rect: Rect.fromCenter(
                center:
                    widget.placed.hitRect.center -
                    widget.interactionRect.topLeft,
                width: widget.placed.visualSize,
                height: widget.placed.visualSize,
              ),
              child: _ControlVisual(
                control: control,
                fillColor: fillColor,
                foreground: foreground,
                size: widget.placed.visualSize,
                isActive: isActive,
                stickValue: _stickValue,
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
        _stickTapCandidate = false;
        _lastPointerPosition = null;
      });
      return;
    }
    if (control.behavior == OnscreenGamepadControlBehavior.mouseModeCycle) {
      setState(() {
        _activePointer = null;
        _stickOrigin = null;
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
      _stickTouchDown = null;
      _stickTapCandidate = false;
      _lastPointerPosition = null;
    });
  }

  void _beginStick(Offset localPosition) {
    _stickTouchDown = localPosition;
    _stickOrigin =
        widget.placed.control.stickCenterMode ==
            OnscreenGamepadStickCenterMode.fixed
        ? widget.placed.center - widget.interactionRect.topLeft
        : localPosition;
    _stickTapCandidate = widget.placed.hitRect
        .shift(-widget.interactionRect.topLeft)
        .contains(localPosition);
    _updateStick(localPosition);
  }

  void _updateStick(Offset localPosition) {
    // 满力度时输入向量可能不变，触点提示仍须跟随真实手指位置。
    if (_lastPointerPosition != localPosition) {
      setState(() => _lastPointerPosition = localPosition);
    }
    final origin = _stickOrigin!;
    final delta = localPosition - origin;
    final distance = delta.distance;
    if ((localPosition - _stickTouchDown!).distance >
        widget.placed.hitSize / 2 * _kStickTapThresholdRatio) {
      _stickTapCandidate = false;
    }
    final force =
        ((distance - _kStickDeadZone) / (_kStickTravel - _kStickDeadZone))
            .clamp(0.0, 1.0);
    final value = distance == 0 ? Offset.zero : delta / distance * force;
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
    final onEvent = widget.onEvent;
    onEvent?.call(
      OnscreenGamepadEvent(
        type: OnscreenGamepadEventType.gamepadButton,
        phase: OnscreenGamepadEventPhase.down,
        control: control,
        input: buttonInput,
      ),
    );
    void release() {
      if (!_pendingStickButtonUps.remove(release)) return;
      onEvent?.call(
        OnscreenGamepadEvent(
          type: OnscreenGamepadEventType.gamepadButton,
          phase: OnscreenGamepadEventPhase.up,
          control: control,
          input: buttonInput,
        ),
      );
    }

    _pendingStickButtonUps.add(release);
    Future<void>.delayed(_kStickTapButtonDelay, release);
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

class OnscreenGamepadSemicirclePainter extends CustomPainter {
  const OnscreenGamepadSemicirclePainter({
    required this.direction,
    required this.color,
  });

  final double direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.shortestSide / 2;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(direction);
    // 略多于半圆的填充圆面，朝前端亮，向直线根部透明。
    final bounds = Rect.fromLTRB(-radius * .16, -radius, radius, radius);
    canvas.clipRect(bounds);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: color.a * .15),
          color.withValues(alpha: color.a * .53),
          color,
        ],
        stops: const [0, .276, .621, 1],
      ).createShader(bounds);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(OnscreenGamepadSemicirclePainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
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

Color _withOpacity(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0, 1) * 255).round());
}
