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
      sizeScale: sizeScale ?? this.sizeScale,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
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
