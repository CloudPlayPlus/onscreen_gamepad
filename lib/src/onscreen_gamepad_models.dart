import 'dart:ui';

enum OnscreenGamepadAnchor {
  topLeft,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum OnscreenGamepadControlKind { circle, square, stick }

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
  custom,
}

class OnscreenGamepadInput {
  const OnscreenGamepadInput({
    required this.kind,
    required this.code,
    this.xAxis,
    this.yAxis,
  });

  const OnscreenGamepadInput.gamepadButton(String code)
    : this(kind: OnscreenGamepadInputKind.gamepadButton, code: code);

  const OnscreenGamepadInput.gamepadStick({
    required String code,
    required String xAxis,
    required String yAxis,
  }) : this(
         kind: OnscreenGamepadInputKind.gamepadStick,
         code: code,
         xAxis: xAxis,
         yAxis: yAxis,
       );

  const OnscreenGamepadInput.keyboardKey(String code)
    : this(kind: OnscreenGamepadInputKind.keyboardKey, code: code);

  const OnscreenGamepadInput.custom(String code)
    : this(kind: OnscreenGamepadInputKind.custom, code: code);

  final OnscreenGamepadInputKind kind;
  final String code;
  final String? xAxis;
  final String? yAxis;

  Map<String, Object?> toJson() {
    return {
      'k': kind.name,
      'c': code,
      if (xAxis != null) 'x': xAxis,
      if (yAxis != null) 'y': yAxis,
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
    this.defaultColor = const Color(0xFFE7F0FF),
    this.opacity = 0.72,
  });

  final String id;
  final String name;
  final List<OnscreenGamepadControl> controls;
  final Color defaultColor;
  final double opacity;

  OnscreenGamepadProfile copyWith({
    String? id,
    String? name,
    List<OnscreenGamepadControl>? controls,
    Color? defaultColor,
    double? opacity,
  }) {
    return OnscreenGamepadProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      controls: controls ?? this.controls,
      defaultColor: defaultColor ?? this.defaultColor,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'n': name,
      'dc': defaultColor.toARGB32(),
      'op': opacity,
      'b': controls.map((control) => control.toJson()).toList(),
    };
  }

  factory OnscreenGamepadProfile.fromJson(Map<String, Object?> json) {
    return OnscreenGamepadProfile(
      id: _string(json['id'], ''),
      name: _string(json['n'], ''),
      defaultColor: _color(json['dc'], const Color(0xFFE7F0FF)),
      opacity: _double(json['op'], 0.72),
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
