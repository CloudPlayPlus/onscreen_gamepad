import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  const engine = OnscreenGamepadLayoutEngine();

  test('phone portrait keeps bottom zones contiguous', () {
    final result = engine.layout(
      renderSize: const Size(393, 852),
      profile: kOnscreenGamepadXboxProfile,
    );
    final bottomLeft = result.zoneOf(OnscreenGamepadAnchor.bottomLeft);
    final bottomCenter = result.zoneOf(OnscreenGamepadAnchor.bottomCenter);
    final bottomRight = result.zoneOf(OnscreenGamepadAnchor.bottomRight);

    expect(result.metrics.gapWidthDp, 0);
    expect(bottomCenter.width, closeTo(393 * 0.20, 0.01));
    expect(bottomLeft.right, closeTo(bottomCenter.left, 0.01));
    expect(bottomCenter.right, closeTo(bottomRight.left, 0.01));
  });

  test('wide screens increase bottom gaps linearly until capped', () {
    final phoneWide = engine.layout(
      renderSize: const Size(852, 393),
      profile: kOnscreenGamepadXboxProfile,
    );
    final tabletWide = engine.layout(
      renderSize: const Size(1194, 834),
      profile: kOnscreenGamepadXboxProfile,
    );
    final desktopWide = engine.layout(
      renderSize: const Size(2400, 900),
      profile: kOnscreenGamepadXboxProfile,
    );

    expect(phoneWide.metrics.gapWidthDp, closeTo((852 - 393) * 0.15, 0.01));
    expect(tabletWide.metrics.gapWidthDp, closeTo((1194 - 393) * 0.15, 0.01));
    expect(desktopWide.metrics.gapWidthDp, 180);
  });

  test('top band remains 12 percent of bottom band', () {
    final result = engine.layout(
      renderSize: const Size(1194, 834),
      profile: kOnscreenGamepadXboxProfile,
    );

    expect(
      result.metrics.topHeight,
      closeTo(result.metrics.bottomHeight * 0.12, 0.0001),
    );
  });

  test('default ABXY controls share the same hit size', () {
    final result = engine.layout(
      renderSize: const Size(852, 393),
      profile: kOnscreenGamepadXboxProfile,
    );
    final controls = {
      for (final placed in result.controls) placed.control.id: placed,
    };
    final size = controls['a']!.hitSize;

    expect(controls['b']!.hitSize, size);
    expect(controls['x']!.hitSize, size);
    expect(controls['y']!.hitSize, size);
  });

  test('default controls stay inside the render bounds', () {
    final result = engine.layout(
      renderSize: const Size(393, 852),
      profile: kOnscreenGamepadXboxProfile,
    );
    final bounds = (Offset.zero & result.renderSize).inflate(0.01);

    for (final placed in result.controls) {
      expect(bounds.contains(placed.hitRect.topLeft), isTrue);
      expect(bounds.contains(placed.hitRect.bottomRight), isTrue);
    }
  });
}
