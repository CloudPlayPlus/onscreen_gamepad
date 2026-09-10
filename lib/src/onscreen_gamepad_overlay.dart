import 'dart:math' as math;

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'onscreen_gamepad_events.dart';
import 'onscreen_gamepad_button_symbol.dart';
import 'onscreen_gamepad_layout.dart';
import 'onscreen_gamepad_models.dart';

const _kStickTapThresholdRatio = 0.01;
const _kStickTapButtonDelay = Duration(milliseconds: 32);
const _kStickDeadZone = 1.0;
const _kStickTravel = 40.0;

Rect _halfScreenRect(OnscreenGamepadPlacedControl placed, Size size) {
  final left = placed.hitRect.center.dx < size.width / 2;
  return Rect.fromLTWH(
    left ? 0 : size.width / 2,
    0,
    size.width / 2,
    size.height,
  );
}

Rect _interactionRect(OnscreenGamepadPlacedControl placed, Size size) {
  return placed.control.regionTriggerEnabled
      ? _halfScreenRect(placed, size).expandToInclude(placed.hitRect)
      : placed.hitRect;
}

typedef OnscreenGamepadControlEvent =
    void Function(OnscreenGamepadControl control);
typedef OnscreenGamepadStickEvent =
    void Function(OnscreenGamepadControl control, Offset value);

class OnscreenGamepadOverlay extends StatefulWidget {
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
  State<OnscreenGamepadOverlay> createState() => _OnscreenGamepadOverlayState();
}

class _OnscreenGamepadOverlayState extends State<OnscreenGamepadOverlay> {
  final _buttons = <String, _ControlButtonState>{};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final renderSize = Size(
          math.max(1.0, constraints.maxWidth),
          math.max(1.0, constraints.maxHeight),
        );
        final result = widget.layoutEngine.layout(
          renderSize: renderSize,
          logicalSize: widget.logicalSize,
          profile: widget.profile,
        );

        final orderedControls = [
          ...result.controls.where(
            (p) => p.control.isMovementStick || p.control.isCameraStick,
          ),
          ...result.controls.where(
            (p) => !p.control.isMovementStick && !p.control.isCameraStick,
          ),
        ];
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.showZones)
              for (final entry in result.zones.entries)
                Positioned.fromRect(
                  rect: entry.value,
                  child: _ZonePaint(anchor: entry.key),
                ),
            // 移动摇杆的扩大区域置底，任何普通按钮的 hitbox 都优先响应。
            for (final placed in orderedControls)
              Positioned.fromRect(
                key: ValueKey('position-${placed.control.id}'),
                rect: _interactionRect(placed, renderSize),
                child: _StickHitPriority(
                  regionRect: placed.control.regionTriggerEnabled
                      ? _halfScreenRect(
                          placed,
                          renderSize,
                        ).shift(-_interactionRect(placed, renderSize).topLeft)
                      : null,
                  ownRect: placed.hitRect.shift(
                    -_interactionRect(placed, renderSize).topLeft,
                  ),
                  peerRects: [
                    if (placed.control.regionTriggerEnabled)
                      for (final peer in result.controls)
                        if (peer.control.kind ==
                                OnscreenGamepadControlKind.stick &&
                            peer.control.id != placed.control.id)
                          peer.hitRect.shift(
                            -_interactionRect(placed, renderSize).topLeft,
                          ),
                  ],
                  child: _ControlButton(
                    key: ValueKey(placed.control.id),
                    placed: placed,
                    buttonStates: _buttons,
                    buttonOrder: orderedControls
                        .map((p) => p.control.id)
                        .toList(),
                    renderSize: renderSize,
                    interactionRect: _interactionRect(placed, renderSize),
                    feedbackCenter:
                        placed.positionFeedbackCenter(renderSize) -
                        _interactionRect(placed, renderSize).topLeft,
                    profile: widget.profile,
                    isActive: widget.activeControlIds.contains(
                      placed.control.id,
                    ),
                    onEvent: widget.onEvent,
                    onDown: widget.onControlDown,
                    onUp: widget.onControlUp,
                    onStickChanged: widget.onStickChanged,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// 仅改变起手命中，不裁剪半月，也不影响已捕获指针的 move/up。
class _StickHitPriority extends SingleChildRenderObjectWidget {
  const _StickHitPriority({
    required this.regionRect,
    required this.ownRect,
    required this.peerRects,
    required super.child,
  });
  final Rect ownRect;
  final Rect? regionRect;
  final List<Rect> peerRects;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderStickHitPriority(ownRect, peerRects, regionRect);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderStickHitPriority renderObject,
  ) {
    renderObject
      ..ownRect = ownRect
      ..regionRect = regionRect
      ..peerRects = peerRects;
  }
}

class _RenderStickHitPriority extends RenderProxyBox {
  _RenderStickHitPriority(this.ownRect, this.peerRects, this.regionRect);
  Rect ownRect;
  Rect? regionRect;
  List<Rect> peerRects;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!ownRect.contains(position) &&
        ((regionRect != null && !regionRect!.contains(position)) ||
            peerRects.any((rect) => rect.contains(position)))) {
      return false;
    }
    return super.hitTest(result, position: position);
  }
}

class _RunIndicator extends StatelessWidget {
  const _RunIndicator({
    super.key,
    required this.color,
    required this.highlighted,
    this.arrows = false,
  });
  final Color color;
  final bool highlighted;
  final bool arrows;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: highlighted ? .28 : .12),
            border: Border.all(color: color, width: highlighted ? 2 : 1),
          ),
          child: Icon(
            arrows ? Icons.directions_run : Icons.keyboard_double_arrow_up,
            color: color,
            size: arrows ? 30 : 42,
          ),
        ),
      ),
      if (arrows)
        Positioned(
          top: 43,
          left: 8,
          right: 8,
          child: Icon(Icons.keyboard_double_arrow_up, size: 28, color: color),
        ),
    ],
  );
}

class _ControlButton extends StatefulWidget {
  const _ControlButton({
    super.key,
    required this.placed,
    required this.buttonStates,
    required this.buttonOrder,
    required this.renderSize,
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
  final Map<String, _ControlButtonState> buttonStates;
  final List<String> buttonOrder;
  final Size renderSize;
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
  int? _cameraButtonPointer;
  bool _autoRunning = false;
  Offset _stickValue = Offset.zero;
  Offset? _stickOrigin;
  Offset? _stickTouchDown;
  bool _stickTapCandidate = false;
  Offset? _lastPointerPosition;
  bool _isToggled = false;
  bool _buttonDown = false;
  bool _buttonOutputDown = false;
  final _slideHolders = <_ControlButtonState>{};
  final _slideTargets = <_ControlButtonState>{};
  bool _buttonLocked = false;
  bool _unlockGesture = false;
  Duration? _buttonDownTime;
  int _mouseModeIndex = 0;
  final _pendingStickButtonUps = <VoidCallback>{};

  @override
  void initState() {
    super.initState();
    widget.buttonStates[widget.placed.control.id] = this;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (widget.buttonStates[widget.placed.control.id] == this) {
      widget.buttonStates.remove(widget.placed.control.id);
    }
    WidgetsBinding.instance.removeObserver(this);
    _cancelInput(widget, afterFrame: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed &&
        (_activePointer != null ||
            _cameraButtonPointer != null ||
            _autoRunning ||
            _isToggled ||
            _buttonOutputDown ||
            _pendingStickButtonUps.isNotEmpty)) {
      _cancelInput(widget);
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant _ControlButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placed.control.id != widget.placed.control.id) {
      oldWidget.buttonStates.remove(oldWidget.placed.control.id);
      widget.buttonStates[widget.placed.control.id] = this;
    }
    if (oldWidget.placed.control.id != widget.placed.control.id ||
        oldWidget.placed.control.buttonPressMode !=
            widget.placed.control.buttonPressMode ||
        !const DeepCollectionEquality().equals(
          oldWidget.placed.control.input.toJson(),
          widget.placed.control.input.toJson(),
        ) ||
        oldWidget.placed.control.behavior != widget.placed.control.behavior ||
        oldWidget.placed.control.kind != widget.placed.control.kind ||
        oldWidget.placed.control.isCameraStick !=
            widget.placed.control.isCameraStick ||
        oldWidget.placed.control.stickMode != widget.placed.control.stickMode ||
        oldWidget.placed.control.mouseSensitivity !=
            widget.placed.control.mouseSensitivity ||
        oldWidget.placed.control.autoRun != widget.placed.control.autoRun ||
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
    _releaseSlideTargets(afterFrame: afterFrame);
    final buttonDown = _buttonOutputDown;
    final active = control.supportsButtonPressMode
        ? false
        : switch (control.behavior) {
            OnscreenGamepadControlBehavior.toggle => _isToggled,
            OnscreenGamepadControlBehavior.mouseModeCycle => false,
            _ => _activePointer != null || _autoRunning,
          };
    final wasMoving = _stickValue != Offset.zero;
    final pendingStickButtonUps = _pendingStickButtonUps.toList();
    // 先清除本地手势，旧命中路径后续的 move/up 不得再次输出。
    _activePointer = null;
    _cameraButtonPointer = null;
    _autoRunning = false;
    _stickValue = Offset.zero;
    _stickOrigin = null;
    _stickTouchDown = null;
    _stickTapCandidate = false;
    _lastPointerPosition = null;
    _isToggled = false;
    _buttonDown = false;
    _buttonOutputDown = false;
    _slideHolders.clear();
    _buttonLocked = false;
    _buttonDownTime = null;
    _unlockGesture = false;
    if (!active && !wasMoving && !buttonDown && pendingStickButtonUps.isEmpty) {
      return;
    }

    void release() {
      if (buttonDown) {
        _emitButtonPhase(source, OnscreenGamepadEventPhase.up);
      }
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
      if (active && !control.isCameraStick) {
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

  bool get _showRunTarget =>
      widget.placed.control.autoRunEnabled &&
      _activePointer != null &&
      _stickValue.dy < 0 &&
      _stickValue.dx.abs() <= -_stickValue.dy * math.tan(math.pi / 6);

  Offset get _runTarget {
    final center = widget.placed.control.positionFeedbackEnabled
        ? widget.feedbackCenter
        : _stickOrigin!;
    final global =
        center +
        widget.interactionRect.topLeft -
        Offset(0, widget.placed.visualSize * .34 + 100);
    final marginX = math.min(24.0, widget.renderSize.width / 2);
    final marginY = math.min(24.0, widget.renderSize.height / 2);
    return Offset(
          global.dx.clamp(marginX, widget.renderSize.width - marginX),
          global.dy.clamp(marginY, widget.renderSize.height - marginY),
        ) -
        widget.interactionRect.topLeft;
  }

  bool get _runTargetReached {
    if (!_showRunTarget || _stickValue.distance < .99) return false;
    final touch = widget.placed.control.positionFeedbackEnabled
        ? widget.feedbackCenter + _lastPointerPosition! - _stickOrigin!
        : _lastPointerPosition!;
    return (touch - _runTarget).distance <= 30;
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
    final isActive =
        widget.isActive ||
        (control.supportsButtonPressMode
            ? _buttonOutputDown
            : _activePointer != null) ||
        _isToggled;
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
          if (!control.isCameraStick &&
              _isStick(control) &&
              _activePointer != null) ...[
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
                control: control.isCameraStick
                    ? control.copyWith(
                        kind: OnscreenGamepadControlKind.circle,
                        label: control.label == 'RS' ? 'R3' : control.label,
                      )
                    : _autoRunning
                    ? control.copyWith(label: '')
                    : control,
                fillColor: fillColor,
                foreground: foreground,
                size: widget.placed.visualSize,
                isActive: isActive,
                stickValue: _stickValue,
              ),
            ),
          if (_showRunTarget)
            Positioned.fromRect(
              rect: Rect.fromCenter(center: _runTarget, width: 44, height: 44),
              child: IgnorePointer(
                child: _RunIndicator(
                  key: ValueKey('${control.id}-run-target'),
                  color: foreground,
                  highlighted: _runTargetReached,
                  arrows: true,
                ),
              ),
            ),
          if (_autoRunning)
            Positioned.fromRect(
              rect: Rect.fromCenter(
                center: widget.placed.center - widget.interactionRect.topLeft,
                width: widget.placed.visualSize,
                height: widget.placed.visualSize,
              ),
              child: IgnorePointer(
                child: _RunIndicator(
                  key: ValueKey('${control.id}-running'),
                  color: foreground,
                  highlighted: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.placed.control.isCameraStick) {
      final inButton = widget.placed.hitRect
          .shift(-widget.interactionRect.topLeft)
          .contains(event.localPosition);
      if (inButton) {
        if (_cameraButtonPointer != null) return;
        setState(() => _cameraButtonPointer = event.pointer);
        _pressButton(event.timeStamp);
      } else if (_activePointer == null) {
        _activePointer = event.pointer;
        _lastPointerPosition = event.localPosition;
      }
      return;
    }
    final wasRunning = _autoRunning;
    if (wasRunning) _cancelInput(widget);
    if (_activePointer != null) {
      return;
    }
    setState(() {
      _activePointer = event.pointer;
      _lastPointerPosition = event.localPosition;
    });
    final control = widget.placed.control;
    if (control.supportsButtonPressMode) {
      _pressButton(event.timeStamp);
      return;
    }
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
      if (wasRunning) _stickTapCandidate = false;
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.pointer == _cameraButtonPointer) {
      _trackSlideTargets(event.position);
      return;
    }
    if (event.pointer != _activePointer) {
      return;
    }
    final control = widget.placed.control;
    if (!control.isCameraStick) _trackSlideTargets(event.position);
    if (control.isCameraStick) {
      final delta =
          (event.localPosition - _lastPointerPosition!) *
          control.effectiveMouseSensitivity;
      _lastPointerPosition = event.localPosition;
      if (delta != Offset.zero) {
        widget.onEvent?.call(
          OnscreenGamepadEvent.mouseMove(control: control, delta: delta),
        );
      }
      return;
    }
    if (_isStick(control)) {
      _updateStick(event.localPosition);
    }
    if (control.behavior == OnscreenGamepadControlBehavior.fpsFire) {
      _emitFpsFireMove(event.localPosition);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_releaseCameraPointer(event.pointer, event.timeStamp)) return;
    if (event.pointer != _activePointer) {
      return;
    }
    if (widget.placed.control.supportsButtonPressMode) {
      _releaseButton(event.timeStamp);
      setState(() {
        _activePointer = null;
        _lastPointerPosition = null;
      });
      return;
    }
    if (_isStick(widget.placed.control)) _updateStick(event.localPosition);
    _releasePointer();
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_releaseCameraPointer(event.pointer, event.timeStamp, canceled: true)) {
      return;
    }
    if (event.pointer != _activePointer) {
      return;
    }
    if (widget.placed.control.supportsButtonPressMode) {
      _releaseButton(event.timeStamp, canceled: true);
      setState(() {
        _activePointer = null;
        _lastPointerPosition = null;
      });
    } else {
      _releasePointer(allowStickTap: false);
    }
  }

  void _emitButtonPhase(
    _ControlButton source,
    OnscreenGamepadEventPhase phase,
  ) {
    if (source.placed.control.isCameraStick) {
      _emitCameraButton(source, phase);
    } else {
      source.onEvent?.call(
        OnscreenGamepadEvent.control(
          control: source.placed.control,
          phase: phase,
        ),
      );
    }
    if (phase == OnscreenGamepadEventPhase.down) {
      source.onDown?.call(source.placed.control);
    } else {
      source.onUp?.call(source.placed.control);
    }
  }

  void _setButtonDown(bool down) {
    if (_buttonDown == down) return;
    setState(() => _buttonDown = down);
    _syncButtonOutput();
  }

  void _syncButtonOutput({bool afterFrame = false}) {
    final down = _buttonDown || _slideHolders.isNotEmpty;
    if (_buttonOutputDown == down) return;
    _buttonOutputDown = down;
    final source = widget;
    void emit() => _emitButtonPhase(
      source,
      down ? OnscreenGamepadEventPhase.down : OnscreenGamepadEventPhase.up,
    );
    if (afterFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
        emit();
      });
    } else {
      if (mounted) setState(() {});
      emit();
    }
  }

  void _trackSlideTargets(Offset globalPosition) {
    if (widget.placed.control.buttonPressMode !=
            OnscreenGamepadButtonPressMode.slideHold ||
        !_buttonDown) {
      return;
    }
    // 按绘制顺序命中原按钮框，扩大区域和摇杆不参与滑动连按。
    for (final id in widget.buttonOrder.reversed) {
      final target = widget.buttonStates[id];
      if (target == null || !target.mounted) continue;
      final box = target.context.findRenderObject() as RenderBox;
      if (!target.widget.placed.hitRect
          .shift(-target.widget.interactionRect.topLeft)
          .contains(box.globalToLocal(globalPosition))) {
        continue;
      }
      if (target != this &&
          target.widget.placed.control.supportsButtonPressMode &&
          _slideTargets.add(target)) {
        target._slideHolders.add(this);
        target._syncButtonOutput();
      }
      return;
    }
  }

  void _releaseSlideTargets({bool afterFrame = false}) {
    for (final target in _slideTargets) {
      if (target._slideHolders.remove(this)) {
        target._syncButtonOutput(afterFrame: afterFrame);
      }
    }
    _slideTargets.clear();
  }

  void _pressButton(Duration timeStamp) {
    _buttonDownTime = timeStamp;
    _unlockGesture = _buttonLocked;
    final mode = widget.placed.control.buttonPressMode;
    if (_buttonLocked) {
      _buttonLocked = false;
      _setButtonDown(false);
    } else {
      _buttonLocked = mode == OnscreenGamepadButtonPressMode.toggle;
      _setButtonDown(true);
    }
  }

  void _releaseButton(Duration timeStamp, {bool canceled = false}) {
    _releaseSlideTargets();
    final mode = widget.placed.control.buttonPressMode;
    if (canceled) {
      _buttonLocked = false;
    } else if (mode == OnscreenGamepadButtonPressMode.longPressToggle) {
      _buttonLocked =
          !_unlockGesture &&
          _buttonDownTime != null &&
          timeStamp - _buttonDownTime! >= const Duration(milliseconds: 500);
    }
    if (!_buttonLocked) _setButtonDown(false);
    _buttonDownTime = null;
    _unlockGesture = false;
  }

  void _emitCameraButton(
    _ControlButton source,
    OnscreenGamepadEventPhase phase,
  ) {
    source.onEvent?.call(
      OnscreenGamepadEvent(
        type: OnscreenGamepadEventType.gamepadButton,
        phase: phase,
        control: source.placed.control,
        input: OnscreenGamepadInput.gamepadButton(
          source.placed.control.input.buttonCode ?? 'rightStickButton',
        ),
      ),
    );
  }

  bool _releaseCameraPointer(
    int pointer,
    Duration timeStamp, {
    bool canceled = false,
  }) {
    if (!widget.placed.control.isCameraStick) return false;
    if (pointer == _cameraButtonPointer) {
      setState(() => _cameraButtonPointer = null);
      _releaseButton(timeStamp, canceled: canceled);
    }
    if (pointer == _activePointer) {
      _activePointer = null;
      _lastPointerPosition = null;
    }
    return true;
  }

  void _releasePointer({bool allowStickTap = true}) {
    final control = widget.placed.control;
    if (allowStickTap && _runTargetReached) {
      setState(() {
        _autoRunning = true;
        _activePointer = null;
        _stickOrigin = null;
        _stickTouchDown = null;
        _stickTapCandidate = false;
        _lastPointerPosition = null;
      });
      _setStickValue(const Offset(0, -1));
      return;
    }
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
                  child: control.buttonIcon != OnscreenGamepadButtonIcon.text
                      ? OnscreenGamepadButtonSymbol(
                          icon: control.buttonIcon,
                          color: foreground,
                          size: size * .62,
                          isActive: isActive,
                        )
                      : Text(
                          control.label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: TextStyle(
                            color: foreground,
                            fontSize: math.min(
                              size * .5,
                              math.max(11, size * 0.25),
                            ),
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
