import 'dart:math' as math;
import 'dart:ui';

import 'onscreen_gamepad_models.dart';

const kOnscreenGamepadDefaultSizeRules = {
  OnscreenGamepadSizeTier.small: OnscreenGamepadSizeRule(
    ratio: 0.11,
    min: 36,
    max: 66,
  ),
  OnscreenGamepadSizeTier.medium: OnscreenGamepadSizeRule(
    ratio: 0.14,
    min: 40,
    max: 86,
  ),
  OnscreenGamepadSizeTier.large: OnscreenGamepadSizeRule(
    ratio: 0.23,
    min: 72,
    max: 154,
  ),
};

class OnscreenGamepadLayoutEngine {
  const OnscreenGamepadLayoutEngine({
    this.params = const OnscreenGamepadLayoutParams(),
    this.sizeRules = kOnscreenGamepadDefaultSizeRules,
  });

  final OnscreenGamepadLayoutParams params;
  final Map<OnscreenGamepadSizeTier, OnscreenGamepadSizeRule> sizeRules;

  OnscreenGamepadLayoutResult layout({
    required Size renderSize,
    required OnscreenGamepadProfile profile,
    Size? logicalSize,
  }) {
    final safeRenderSize = Size(
      math.max(1.0, renderSize.width),
      math.max(1.0, renderSize.height),
    );
    final safeLogicalSize = logicalSize == null
        ? safeRenderSize
        : Size(
            math.max(1.0, logicalSize.width),
            math.max(1.0, logicalSize.height),
          );
    final metrics = calculateMetrics(safeLogicalSize);
    final zones = calculateZones(safeRenderSize, metrics);
    final scale = math.min(
      safeRenderSize.width / safeLogicalSize.width,
      safeRenderSize.height / safeLogicalSize.height,
    );
    final controls = [...profile.controls]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return OnscreenGamepadLayoutResult(
      renderSize: safeRenderSize,
      logicalSize: safeLogicalSize,
      zones: zones,
      metrics: metrics,
      controls: [
        for (final control in controls)
          _placeControl(
            control: control,
            zones: zones,
            renderSize: safeRenderSize,
            logicalSize: safeLogicalSize,
            metrics: metrics,
            renderScale: scale,
          ),
      ],
    );
  }

  OnscreenGamepadZoneMetrics calculateMetrics(Size logicalSize) {
    final w = math.max(1.0, logicalSize.width);
    final h = math.max(1.0, logicalSize.height);
    final wideShare = w / (w + h);
    final bottomHeight = math.min(
      params.maxBottomHeight,
      params.bottomBias + params.bottomSlope * wideShare,
    );
    final topHeight = bottomHeight * params.topRatio;
    final bottomY = 1.0 - bottomHeight;
    final centerWidthDp = math.min(w, math.max(0.0, w * params.centerRatio));
    final gapLimitDp = math.max(0.0, (w - centerWidthDp) / 2);
    final gapWidthDp = math.min(
      params.gapMaxWidth,
      math.min(
        gapLimitDp,
        math.max(0.0, (w - params.gapStartWidth) * params.gapSlope),
      ),
    );
    final sideWidthDp = math.max(0.0, (w - centerWidthDp - gapWidthDp * 2) / 2);

    return OnscreenGamepadZoneMetrics(
      wideShare: wideShare,
      bottomHeight: bottomHeight,
      topHeight: topHeight,
      bottomY: bottomY,
      centerWidth: centerWidthDp / w,
      centerWidthDp: centerWidthDp,
      gapWidthDp: gapWidthDp,
      sideWidthDp: sideWidthDp,
    );
  }

  Map<OnscreenGamepadAnchor, Rect> calculateZones(
    Size renderSize,
    OnscreenGamepadZoneMetrics metrics,
  ) {
    final w = math.max(1.0, renderSize.width);
    final h = math.max(1.0, renderSize.height);
    final sideWidth =
        metrics.sideWidthDp /
        math.max(
          1.0,
          metrics.sideWidthDp * 2 +
              metrics.centerWidthDp +
              metrics.gapWidthDp * 2,
        );
    final gapWidth =
        metrics.gapWidthDp /
        math.max(
          1.0,
          metrics.sideWidthDp * 2 +
              metrics.centerWidthDp +
              metrics.gapWidthDp * 2,
        );

    Rect rel(double x, double y, double width, double height) {
      return Rect.fromLTWH(x * w, y * h, width * w, height * h);
    }

    return {
      OnscreenGamepadAnchor.topLeft: rel(0, 0, 0.5, metrics.topHeight),
      OnscreenGamepadAnchor.topRight: rel(0.5, 0, 0.5, metrics.topHeight),
      OnscreenGamepadAnchor.bottomLeft: rel(
        0,
        metrics.bottomY,
        sideWidth,
        metrics.bottomHeight,
      ),
      OnscreenGamepadAnchor.bottomCenter: rel(
        sideWidth + gapWidth,
        metrics.bottomY,
        metrics.centerWidth,
        metrics.bottomHeight,
      ),
      OnscreenGamepadAnchor.bottomRight: rel(
        sideWidth + gapWidth + metrics.centerWidth + gapWidth,
        metrics.bottomY,
        sideWidth,
        metrics.bottomHeight,
      ),
    };
  }

  OnscreenGamepadPlacedControl _placeControl({
    required OnscreenGamepadControl control,
    required Map<OnscreenGamepadAnchor, Rect> zones,
    required Size renderSize,
    required Size logicalSize,
    required OnscreenGamepadZoneMetrics metrics,
    required double renderScale,
  }) {
    final anchor =
        zones[control.anchor] ?? zones[OnscreenGamepadAnchor.bottomCenter]!;
    final logicalHitSize = _logicalHitSize(
      control: control,
      logicalSize: logicalSize,
      metrics: metrics,
    );
    final hitSize = (logicalHitSize * renderScale).roundToDouble();
    final visualSize = (hitSize * 0.82).roundToDouble();
    final rawCenter = Offset(
      anchor.left + anchor.width / 2 + control.offset.dx * anchor.width / 2,
      anchor.top + anchor.height / 2 + control.offset.dy * anchor.height / 2,
    );
    final center = Offset(
      _clampCenter(rawCenter.dx, hitSize / 2, renderSize.width - hitSize / 2),
      _clampCenter(rawCenter.dy, hitSize / 2, renderSize.height - hitSize / 2),
    );
    final hitRect = Rect.fromCenter(
      center: center,
      width: hitSize,
      height: hitSize,
    );
    final visualRect = Rect.fromCenter(
      center: center,
      width: visualSize,
      height: visualSize,
    );

    return OnscreenGamepadPlacedControl(
      control: control,
      center: center,
      hitSize: hitSize,
      visualSize: visualSize,
      hitRect: hitRect,
      visualRect: visualRect,
    );
  }

  double _logicalHitSize({
    required OnscreenGamepadControl control,
    required Size logicalSize,
    required OnscreenGamepadZoneMetrics metrics,
  }) {
    final rule =
        sizeRules[control.sizeTier] ??
        kOnscreenGamepadDefaultSizeRules[OnscreenGamepadSizeTier.medium]!;
    final shortSide = math.min(logicalSize.width, logicalSize.height);
    final wideScale = 0.88 + 0.18 * metrics.wideShare;
    final base = _clamp(shortSide * rule.ratio * wideScale, rule.min, rule.max);
    final sizeScale = _clamp(control.sizeScale, 0.8, 1.5);
    return base * sizeScale;
  }
}

double _clamp(double value, double min, double max) {
  return math.min(max, math.max(min, value));
}

double _clampCenter(double value, double min, double max) {
  if (min > max) {
    return (min + max) / 2;
  }
  return _clamp(value, min, max);
}
