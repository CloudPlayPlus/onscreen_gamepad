import 'dart:ui';

import 'onscreen_gamepad_models.dart';

enum OnscreenGamepadEventType {
  gamepadButton,
  gamepadStick,
  keyboardKey,
  mouseButton,
  mouseMove,
  mouseMode,
  custom,
}

enum OnscreenGamepadEventPhase { down, up, change }

class OnscreenGamepadEvent {
  const OnscreenGamepadEvent({
    required this.type,
    required this.phase,
    required this.control,
    required this.input,
    this.value,
    this.delta,
    this.isAbsolute = false,
    this.mode,
  });

  factory OnscreenGamepadEvent.control({
    required OnscreenGamepadControl control,
    required OnscreenGamepadEventPhase phase,
  }) {
    return OnscreenGamepadEvent(
      type: _eventTypeForInput(control.input),
      phase: phase,
      control: control,
      input: control.input,
    );
  }

  factory OnscreenGamepadEvent.stickChanged({
    required OnscreenGamepadControl control,
    required Offset value,
  }) {
    return OnscreenGamepadEvent(
      type: OnscreenGamepadEventType.gamepadStick,
      phase: OnscreenGamepadEventPhase.change,
      control: control,
      input: control.input,
      value: value,
    );
  }

  factory OnscreenGamepadEvent.mouseMove({
    required OnscreenGamepadControl control,
    required Offset delta,
    bool isAbsolute = false,
  }) {
    return OnscreenGamepadEvent(
      type: OnscreenGamepadEventType.mouseMove,
      phase: OnscreenGamepadEventPhase.change,
      control: control,
      input: control.input,
      delta: delta,
      isAbsolute: isAbsolute,
    );
  }

  factory OnscreenGamepadEvent.mouseMode({
    required OnscreenGamepadControl control,
    required String mode,
    required OnscreenGamepadEventPhase phase,
  }) {
    return OnscreenGamepadEvent(
      type: OnscreenGamepadEventType.mouseMode,
      phase: phase,
      control: control,
      input: control.input,
      mode: mode,
    );
  }

  final OnscreenGamepadEventType type;
  final OnscreenGamepadEventPhase phase;
  final OnscreenGamepadControl control;
  final OnscreenGamepadInput input;
  final Offset? value;
  final Offset? delta;
  final bool isAbsolute;
  final String? mode;

  bool get isDown => phase == OnscreenGamepadEventPhase.down;
  bool get isUp => phase == OnscreenGamepadEventPhase.up;
  bool get isChange => phase == OnscreenGamepadEventPhase.change;
}

typedef OnscreenGamepadEventCallback =
    void Function(OnscreenGamepadEvent event);

OnscreenGamepadEventType _eventTypeForInput(OnscreenGamepadInput input) {
  return switch (input.kind) {
    OnscreenGamepadInputKind.gamepadButton =>
      OnscreenGamepadEventType.gamepadButton,
    OnscreenGamepadInputKind.gamepadStick =>
      OnscreenGamepadEventType.gamepadStick,
    OnscreenGamepadInputKind.keyboardKey =>
      OnscreenGamepadEventType.keyboardKey,
    OnscreenGamepadInputKind.mouseButton =>
      OnscreenGamepadEventType.mouseButton,
    OnscreenGamepadInputKind.mouseMove => OnscreenGamepadEventType.mouseMove,
    OnscreenGamepadInputKind.mouseMode => OnscreenGamepadEventType.mouseMode,
    OnscreenGamepadInputKind.custom => OnscreenGamepadEventType.custom,
  };
}
