import 'dart:ui';

enum OnscreenGamepadAnchor {
  topLeft,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum OnscreenGamepadControlKind { circle, square, stick }

enum OnscreenGamepadStickMode {
  joystick('摇杆'),
  camera('视角转动');

  const OnscreenGamepadStickMode(this.label);
  final String label;
}

enum OnscreenGamepadStickCenterMode {
  touchDown('按下位置为中心'),
  fixed('原摇杆中心');

  const OnscreenGamepadStickCenterMode(this.label);
  final String label;
}

enum OnscreenGamepadControlRole {
  primary,
  secondary,
  stick,
  dpad,
  bumper,
  trigger,
  utility,
}

enum OnscreenGamepadSizeTier { small, medium, large }

enum OnscreenGamepadInputKind {
  gamepadButton,
  gamepadStick,
  keyboardKey,
  mouseButton,
  mouseMove,
  mouseMode,
  custom,
}

enum OnscreenGamepadControlBehavior {
  normal,
  toggle,
  fpsFire,
  wasdStick,
  eightDirectionMouse,
  mouseModeCycle,
}

class OnscreenGamepadInput {
  const OnscreenGamepadInput({
    required this.kind,
    required this.code,
    this.xAxis,
    this.yAxis,
    this.buttonCode,
    this.numericCode,
    this.payload = const {},
  });

  const OnscreenGamepadInput.gamepadButton(String code, {int? numericCode})
    : this(
        kind: OnscreenGamepadInputKind.gamepadButton,
        code: code,
        numericCode: numericCode,
      );

  const OnscreenGamepadInput.gamepadStick({
    required String code,
    required String xAxis,
    required String yAxis,
    String? buttonCode,
  }) : this(
         kind: OnscreenGamepadInputKind.gamepadStick,
         code: code,
         xAxis: xAxis,
         yAxis: yAxis,
         buttonCode: buttonCode,
       );

  const OnscreenGamepadInput.keyboardKey(String code, {int? numericCode})
    : this(
        kind: OnscreenGamepadInputKind.keyboardKey,
        code: code,
        numericCode: numericCode,
      );

  const OnscreenGamepadInput.mouseButton(int buttonId)
    : this(
        kind: OnscreenGamepadInputKind.mouseButton,
        code: 'mouseButton',
        numericCode: buttonId,
      );

  const OnscreenGamepadInput.mouseMove({String code = 'mouseMove'})
    : this(kind: OnscreenGamepadInputKind.mouseMove, code: code);

  const OnscreenGamepadInput.mouseMode(String code)
    : this(kind: OnscreenGamepadInputKind.mouseMode, code: code);

  const OnscreenGamepadInput.custom(
    String code, {
    Map<String, Object?> payload = const {},
  }) : this(
         kind: OnscreenGamepadInputKind.custom,
         code: code,
         payload: payload,
       );

  final OnscreenGamepadInputKind kind;
  final String code;
  final String? xAxis;
  final String? yAxis;
  final String? buttonCode;
  final int? numericCode;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() {
    return {
      'k': kind.name,
      'c': code,
      if (xAxis != null) 'x': xAxis,
      if (yAxis != null) 'y': yAxis,
      if (buttonCode != null) 'b': buttonCode,
      if (numericCode != null) 'n': numericCode,
      if (payload.isNotEmpty) 'p': payload,
    };
  }

  factory OnscreenGamepadInput.fromJson(Map<String, Object?> json) {
    return OnscreenGamepadInput(
      kind: _enumByName(
        OnscreenGamepadInputKind.values,
        json['k'],
        OnscreenGamepadInputKind.custom,
      ),
      code: _string(json['c'], ''),
      xAxis: _nullableString(json['x']),
      yAxis: _nullableString(json['y']),
      buttonCode: _nullableString(json['b']),
      numericCode: _nullableInt(json['n']),
      payload: _map(json['p']),
    );
  }
}

class OnscreenGamepadLayoutParams {
  const OnscreenGamepadLayoutParams({
    this.bottomBias = 0.04,
    this.bottomSlope = 1.20,
    this.maxBottomHeight = 6 / 7,
    this.topRatio = 0.12,
    this.centerRatio = 0.20,
    this.gapStartWidth = 393,
    this.gapSlope = 0.15,
    this.gapMaxWidth = 180,
  });

  final double bottomBias;
  final double bottomSlope;
  final double maxBottomHeight;
  final double topRatio;
  final double centerRatio;
  final double gapStartWidth;
  final double gapSlope;
  final double gapMaxWidth;

  Map<String, Object?> toJson() {
    return {
      'bb': bottomBias,
      'bs': bottomSlope,
      'mbh': maxBottomHeight,
      'tr': topRatio,
      'cr': centerRatio,
      'gsw': gapStartWidth,
      'gs': gapSlope,
      'gmw': gapMaxWidth,
    };
  }

  factory OnscreenGamepadLayoutParams.fromJson(Map<String, Object?> json) {
    return OnscreenGamepadLayoutParams(
      bottomBias: _double(json['bb'], 0.04),
      bottomSlope: _double(json['bs'], 1.20),
      maxBottomHeight: _double(json['mbh'], 6 / 7),
      topRatio: _double(json['tr'], 0.12),
      centerRatio: _double(json['cr'], 0.20),
      gapStartWidth: _double(json['gsw'], 393),
      gapSlope: _double(json['gs'], 0.15),
      gapMaxWidth: _double(json['gmw'], 180),
    );
  }
}

class OnscreenGamepadSizeRule {
  const OnscreenGamepadSizeRule({
    required this.ratio,
    required this.min,
    required this.max,
  });

  final double ratio;
  final double min;
  final double max;
}

class OnscreenGamepadControl {
  const OnscreenGamepadControl({
    required this.id,
    required this.label,
    required this.anchor,
    required this.offset,
    required this.kind,
    required this.role,
    required this.sizeTier,
    required this.input,
    this.behavior = OnscreenGamepadControlBehavior.normal,
    this.behaviorConfig = const {},
    this.positionFeedback,
    this.positionFeedbackLocation,
    this.stickCenterMode = OnscreenGamepadStickCenterMode.touchDown,
    this.regionTrigger = true,
    this.stickMode = OnscreenGamepadStickMode.joystick,
    this.mouseSensitivity = 1,
    this.autoRun = true,
    this.sizeScale = 1,
    this.color,
    this.sortOrder = 0,
  });

  final String id;
  final String label;
  final OnscreenGamepadAnchor anchor;
  final Offset offset;
  final OnscreenGamepadControlKind kind;
  final OnscreenGamepadControlRole role;
  final OnscreenGamepadSizeTier sizeTier;
  final OnscreenGamepadInput input;
  final OnscreenGamepadControlBehavior behavior;
  final Map<String, Object?> behaviorConfig;

  /// Optional per-control preference; absent values use the input's default.
  final bool? positionFeedback;

  /// 提示中心在屏幕宽高中的比例，未设置时使用摇杆上方的默认位置。
  final Offset? positionFeedbackLocation;
  final OnscreenGamepadStickCenterMode stickCenterMode;
  final bool regionTrigger;
  final OnscreenGamepadStickMode stickMode;
  final double mouseSensitivity;
  final bool autoRun;

  bool get isRightStick =>
      kind == OnscreenGamepadControlKind.stick &&
      (input.code == 'rightStick' || input.xAxis == 'rightX');
  bool get isCameraStick =>
      isRightStick && stickMode == OnscreenGamepadStickMode.camera;
  bool get regionTriggerEnabled =>
      isCameraStick || (isMovementStick && regionTrigger);
  bool get autoRunEnabled => isMovementStick && !isCameraStick && autoRun;
  double get effectiveMouseSensitivity =>
      mouseSensitivity.isFinite ? mouseSensitivity.clamp(.1, 5) : 1;

  bool get isMovementStick =>
      kind == OnscreenGamepadControlKind.stick &&
      (behavior == OnscreenGamepadControlBehavior.wasdStick ||
          input.code == 'wasdStick' ||
          input.code == 'leftStick' ||
          input.xAxis == 'leftX');

  bool get positionFeedbackEnabled =>
      !isCameraStick &&
      kind == OnscreenGamepadControlKind.stick &&
      stickCenterMode == OnscreenGamepadStickCenterMode.fixed &&
      (positionFeedback ?? isMovementStick);

  final double sizeScale;
  final Color? color;
  final int sortOrder;

  OnscreenGamepadControl copyWith({
    String? id,
    String? label,
    OnscreenGamepadAnchor? anchor,
    Offset? offset,
    OnscreenGamepadControlKind? kind,
    OnscreenGamepadControlRole? role,
    OnscreenGamepadSizeTier? sizeTier,
    OnscreenGamepadInput? input,
    OnscreenGamepadControlBehavior? behavior,
    Map<String, Object?>? behaviorConfig,
    bool? positionFeedback,
    Offset? positionFeedbackLocation,
    OnscreenGamepadStickCenterMode? stickCenterMode,
    bool? regionTrigger,
    OnscreenGamepadStickMode? stickMode,
    double? mouseSensitivity,
    bool? autoRun,
    double? sizeScale,
    Color? color,
    int? sortOrder,
  }) {
    return OnscreenGamepadControl(
      id: id ?? this.id,
      label: label ?? this.label,
      anchor: anchor ?? this.anchor,
      offset: offset ?? this.offset,
      kind: kind ?? this.kind,
      role: role ?? this.role,
      sizeTier: sizeTier ?? this.sizeTier,
      input: input ?? this.input,
      behavior: behavior ?? this.behavior,
      behaviorConfig: behaviorConfig ?? this.behaviorConfig,
      positionFeedback: positionFeedback ?? this.positionFeedback,
      positionFeedbackLocation:
          positionFeedbackLocation ?? this.positionFeedbackLocation,
      stickCenterMode: stickCenterMode ?? this.stickCenterMode,
      regionTrigger: regionTrigger ?? this.regionTrigger,
      stickMode: stickMode ?? this.stickMode,
      mouseSensitivity: mouseSensitivity ?? this.mouseSensitivity,
      autoRun: autoRun ?? this.autoRun,
      sizeScale: sizeScale ?? this.sizeScale,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'l': label,
      'a': anchor.name,
      'o': _offsetToJson(offset),
      'k': kind.name,
      'r': role.name,
      's': sizeTier.name,
      'in': input.toJson(),
      if (behavior != OnscreenGamepadControlBehavior.normal)
        'bh': behavior.name,
      if (behaviorConfig.isNotEmpty) 'bc': behaviorConfig,
      if (positionFeedback != null) 'af': positionFeedback,
      if (!regionTrigger) 'rt': false,
      if (stickMode != OnscreenGamepadStickMode.joystick) 'sm': stickMode.name,
      if (mouseSensitivity != 1) 'ms': effectiveMouseSensitivity,
      if (!autoRun) 'ar': false,
      if (stickCenterMode != OnscreenGamepadStickCenterMode.touchDown)
        'cm': stickCenterMode.name,
      if (positionFeedbackLocation != null)
        'fp': _offsetToJson(positionFeedbackLocation!),
      if (sizeScale != 1) 'z': sizeScale,
      if (color != null) 'co': color!.toARGB32(),
      if (sortOrder != 0) 'so': sortOrder,
    };
  }

  factory OnscreenGamepadControl.fromJson(Map<String, Object?> json) {
    return OnscreenGamepadControl(
      id: _string(json['id'], ''),
      label: _string(json['l'], ''),
      anchor: _enumByName(
        OnscreenGamepadAnchor.values,
        json['a'],
        OnscreenGamepadAnchor.bottomCenter,
      ),
      offset: _offsetFromJson(json['o']),
      kind: _enumByName(
        OnscreenGamepadControlKind.values,
        json['k'],
        OnscreenGamepadControlKind.circle,
      ),
      role: _enumByName(
        OnscreenGamepadControlRole.values,
        json['r'],
        OnscreenGamepadControlRole.secondary,
      ),
      sizeTier: _enumByName(
        OnscreenGamepadSizeTier.values,
        json['s'],
        OnscreenGamepadSizeTier.medium,
      ),
      input: OnscreenGamepadInput.fromJson(_map(json['in'])),
      behavior: _enumByName(
        OnscreenGamepadControlBehavior.values,
        json['bh'],
        OnscreenGamepadControlBehavior.normal,
      ),
      behaviorConfig: _map(json['bc']),
      positionFeedback: json['af'] is bool ? json['af'] as bool : null,
      regionTrigger: json['rt'] is bool ? json['rt'] as bool : true,
      stickMode: _enumByName(
        OnscreenGamepadStickMode.values,
        json['sm'],
        OnscreenGamepadStickMode.joystick,
      ),
      mouseSensitivity: _double(json['ms'], 1),
      autoRun: json['ar'] is bool ? json['ar'] as bool : true,
      stickCenterMode: _enumByName(
        OnscreenGamepadStickCenterMode.values,
        json['cm'],
        OnscreenGamepadStickCenterMode.touchDown,
      ),
      positionFeedbackLocation: json['fp'] is Map
          ? _offsetFromJson(json['fp'])
          : null,
      sizeScale: _double(json['z'], 1),
      color: _nullableColor(json['co']),
      sortOrder: _int(json['so'], 0),
    );
  }
}

class OnscreenGamepadProfile {
  const OnscreenGamepadProfile({
    required this.id,
    required this.name,
    required this.controls,
    this.defaultColor = const Color(0xFF000000),
    this.backgroundOpacity = 0.12,
    this.foregroundOpacity = 0.48,
  });

  final String id;
  final String name;
  final List<OnscreenGamepadControl> controls;
  final Color defaultColor;
  final double backgroundOpacity;
  final double foregroundOpacity;

  double get semicircleOpacity => (foregroundOpacity + 0.12).clamp(0.0, 1.0);

  OnscreenGamepadProfile copyWith({
    String? id,
    String? name,
    List<OnscreenGamepadControl>? controls,
    Color? defaultColor,
    double? backgroundOpacity,
    double? foregroundOpacity,
  }) {
    return OnscreenGamepadProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      controls: controls ?? this.controls,
      defaultColor: defaultColor ?? this.defaultColor,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      foregroundOpacity: foregroundOpacity ?? this.foregroundOpacity,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'n': name,
      'dc': defaultColor.toARGB32(),
      'bo': backgroundOpacity,
      'fo': foregroundOpacity,
      'b': controls.map((control) => control.toJson()).toList(),
    };
  }

  factory OnscreenGamepadProfile.fromJson(Map<String, Object?> json) {
    return OnscreenGamepadProfile(
      id: _string(json['id'], ''),
      name: _string(json['n'], ''),
      defaultColor: _color(json['dc'], const Color(0xFF000000)),
      backgroundOpacity: _double(json['bo'], 0.12),
      foregroundOpacity: _double(json['fo'], 0.48),
      controls: _list(json['b'])
          .whereType<Map>()
          .map((item) => OnscreenGamepadControl.fromJson(_map(item)))
          .toList(),
    );
  }
}

class OnscreenGamepadZoneMetrics {
  const OnscreenGamepadZoneMetrics({
    required this.wideShare,
    required this.bottomHeight,
    required this.topHeight,
    required this.bottomY,
    required this.centerWidth,
    required this.centerWidthDp,
    required this.gapWidthDp,
    required this.sideWidthDp,
  });

  final double wideShare;
  final double bottomHeight;
  final double topHeight;
  final double bottomY;
  final double centerWidth;
  final double centerWidthDp;
  final double gapWidthDp;
  final double sideWidthDp;
}

class OnscreenGamepadPlacedControl {
  const OnscreenGamepadPlacedControl({
    required this.control,
    required this.center,
    required this.hitSize,
    required this.visualSize,
    required this.hitRect,
    required this.visualRect,
  });

  final OnscreenGamepadControl control;
  final Offset center;
  final double hitSize;
  final double visualSize;
  final Rect hitRect;
  final Rect visualRect;

  Offset positionFeedbackCenter(Size renderSize) {
    final location = control.positionFeedbackLocation;
    final target = location == null
        ? center +
              Offset(
                (center.dx < renderSize.width / 2 ? 1 : -1) * visualSize * .9,
                -visualSize * 1.4,
              )
        : Offset(
            location.dx * renderSize.width,
            location.dy * renderSize.height,
          );
    final marginX = (visualSize * .34 + 8).clamp(0.0, renderSize.width / 2);
    final marginY = (visualSize * .34 + 8).clamp(0.0, renderSize.height / 2);
    return Offset(
      target.dx.clamp(marginX, renderSize.width - marginX),
      target.dy.clamp(marginY, renderSize.height - marginY),
    );
  }
}

class OnscreenGamepadLayoutResult {
  const OnscreenGamepadLayoutResult({
    required this.renderSize,
    required this.logicalSize,
    required this.zones,
    required this.metrics,
    required this.controls,
  });

  final Size renderSize;
  final Size logicalSize;
  final Map<OnscreenGamepadAnchor, Rect> zones;
  final OnscreenGamepadZoneMetrics metrics;
  final List<OnscreenGamepadPlacedControl> controls;

  Rect zoneOf(OnscreenGamepadAnchor anchor) => zones[anchor] ?? Rect.zero;
}

Map<String, Object?> _offsetToJson(Offset offset) {
  return {'x': offset.dx, 'y': offset.dy};
}

Offset _offsetFromJson(Object? value) {
  final json = _map(value);
  return Offset(_double(json['x'], 0), _double(json['y'], 0));
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  if (name is! String) {
    return fallback;
  }
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry('$key', item));
  }
  return const {};
}

List<Object?> _list(Object? value) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  return const [];
}

String _string(Object? value, String fallback) {
  return value is String ? value : fallback;
}

String? _nullableString(Object? value) {
  return value is String ? value : null;
}

double _double(Object? value, double fallback) {
  if (value is num) {
    return value.toDouble();
  }
  return fallback;
}

int _int(Object? value, int fallback) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

int? _nullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

Color _color(Object? value, Color fallback) {
  return _nullableColor(value) ?? fallback;
}

Color? _nullableColor(Object? value) {
  if (value is int) {
    return Color(value);
  }
  if (value is String) {
    final normalized = value.startsWith('#') ? value.substring(1) : value;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed != null) {
      return Color(normalized.length <= 6 ? parsed | 0xFF000000 : parsed);
    }
  }
  return null;
}
