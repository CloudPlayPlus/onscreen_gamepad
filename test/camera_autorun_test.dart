import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final left = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'left-stick',
  );
  final right = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'right-stick',
  );
  Future<void> mount(
    WidgetTester tester,
    List<OnscreenGamepadControl> controls,
    List<OnscreenGamepadEvent> events,
  ) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 800,
        height: 600,
        child: OnscreenGamepadOverlay(
          profile: kOnscreenGamepadXboxProfile.copyWith(controls: controls),
          onEvent: events.add,
        ),
      ),
    ),
  );

  test(
    'camera mode forces region and persists speed and auto run settings',
    () {
      expect(right.effectiveMouseSensitivity, 10);
      expect(
        OnscreenGamepadControl.fromJson(right.toJson()).mouseSensitivity,
        10,
      );
      expect(
        right.copyWith(mouseSensitivity: 50).effectiveMouseSensitivity,
        50,
      );
      expect(
        right.copyWith(mouseSensitivity: 100).effectiveMouseSensitivity,
        50,
      );
      final configured = right.copyWith(
        stickMode: OnscreenGamepadStickMode.camera,
        regionTrigger: false,
        mouseSensitivity: 2.5,
        autoRun: false,
      );
      final restored = OnscreenGamepadControl.fromJson(
        configured.toJson(),
      ).copyWith(label: 'copy');
      expect(restored.isCameraStick, isTrue);
      expect(restored.regionTriggerEnabled, isTrue);
      expect(restored.positionFeedbackEnabled, isFalse);
      expect(restored.effectiveMouseSensitivity, 2.5);
      expect(restored.autoRun, isFalse);
      expect(left.autoRunEnabled, isTrue);
      expect(right.autoRunEnabled, isFalse);
    },
  );

  test('camera R3 uses ordinary button size and allows quarter scale', () {
    final button = kOnscreenGamepadXboxProfile.controls.firstWhere(
      (c) => c.id == 'a',
    );
    OnscreenGamepadPlacedControl placed(OnscreenGamepadControl control) =>
        const OnscreenGamepadLayoutEngine()
            .layout(
              renderSize: const Size(800, 600),
              profile: kOnscreenGamepadXboxProfile.copyWith(
                controls: [control],
              ),
            )
            .controls
            .single;
    final camera = placed(
      right.copyWith(stickMode: OnscreenGamepadStickMode.camera),
    );
    final ordinary = placed(button.copyWith(sizeScale: right.sizeScale));
    expect(camera.hitSize, ordinary.hitSize);
    expect(camera.visualSize, ordinary.visualSize);
    expect(camera.hitSize, lessThan(placed(right).hitSize));
    final small = placed(button.copyWith(sizeScale: .25));
    expect(small.hitSize, closeTo(placed(button).hitSize * .25, 1));
    expect(small.visualSize, closeTo(placed(button).visualSize * .25, 1));
  });

  testWidgets(
    'cross-center stick bounds do not capture the opposite half gap',
    (tester) async {
      for (final (control, x) in [
        (left, -.1),
        (right.copyWith(stickMode: OnscreenGamepadStickMode.camera), .1),
      ]) {
        final moved = control.copyWith(
          anchor: OnscreenGamepadAnchor.bottomCenter,
          offset: Offset(x, 0),
        );
        final profile = kOnscreenGamepadXboxProfile.copyWith(controls: [moved]);
        final placed = const OnscreenGamepadLayoutEngine()
            .layout(renderSize: const Size(800, 600), profile: profile)
            .controls
            .single;
        expect(placed.hitRect.left, lessThan(400));
        expect(placed.hitRect.right, greaterThan(400));
        final oppositeX = x < 0
            ? placed.hitRect.right - 2
            : placed.hitRect.left + 2;
        final events = <OnscreenGamepadEvent>[];
        await mount(tester, [moved], events);
        await tester.tapAt(Offset(oppositeX, 50));
        expect(events, isEmpty);
        await tester.tapAt(Offset(oppositeX, placed.center.dy));
        await tester.pump(const Duration(milliseconds: 40));
        expect(events, isNotEmpty);
        events.clear();
        final pointer = await tester.startGesture(Offset(x < 0 ? 20 : 780, 50));
        await pointer.moveBy(const Offset(10, 0));
        expect(events.any((e) => e.value != null || e.delta != null), isTrue);
        await pointer.cancel();
      }
    },
  );

  testWidgets('whole half starts above the former 72 percent region', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [left], events);
    final pointer = await tester.startGesture(const Offset(340, 50));
    await pointer.moveBy(const Offset(40, 0));
    expect(events.last.value, const Offset(1, 0));
    await pointer.cancel();
  });

  testWidgets('camera sends relative mouse deltas and independently holds R3', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final camera = right.copyWith(
      stickMode: OnscreenGamepadStickMode.camera,
      mouseSensitivity: 2,
      regionTrigger: false,
    );
    await mount(tester, [camera], events);
    final drag = await tester.startGesture(const Offset(700, 50), pointer: 1);
    expect(events, isEmpty);
    await drag.moveBy(const Offset(10, -4));
    expect(events.single.delta, const Offset(20, -8));
    expect(events.single.isAbsolute, isFalse);
    final button = await tester.startGesture(
      tester.getCenter(find.text('R3')),
      pointer: 2,
    );
    expect(events.last.type, OnscreenGamepadEventType.gamepadButton);
    expect(events.last.input.code, right.input.buttonCode);
    expect(events.last.isDown, isTrue);
    final count = events.length;
    await button.moveBy(const Offset(80, -50));
    expect(events.length, count);
    await drag.moveBy(const Offset(-5, 3));
    expect(events.last.delta, const Offset(-10, 6));
    await button.up();
    expect(events.last.isUp, isTrue);
    await drag.up();
    expect(events.where((e) => e.value != null), isEmpty);
  });

  testWidgets(
    'auto run locks only on target release and cancels on next touch or background',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, [left], events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveBy(const Offset(0, -45));
      await tester.pump();
      final target = find.byKey(const ValueKey('left-stick-run-target'));
      expect(target, findsOneWidget);
      await pointer.moveTo(tester.getCenter(target));
      await pointer.up();
      await tester.pump();
      expect(find.byKey(const ValueKey('left-stick-running')), findsOneWidget);
      expect(
        events.where((e) => e.value != null).last.value,
        const Offset(0, -1),
      );
      final next = await tester.startGesture(const Offset(260, 420));
      await tester.pump();
      expect(find.byKey(const ValueKey('left-stick-running')), findsNothing);
      expect(events.where((e) => e.value != null).last.value, Offset.zero);
      await next.moveBy(const Offset(0, -45));
      await tester.pump();
      await next.moveTo(tester.getCenter(target));
      await next.up();
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey('left-stick-running')), findsNothing);
      expect(events.where((e) => e.value != null).last.value, Offset.zero);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    },
  );

  testWidgets(
    'auto run rejects sideways release, cancellation and disabled option',
    (tester) async {
      for (final enabled in [true, false]) {
        final events = <OnscreenGamepadEvent>[];
        await mount(tester, [left.copyWith(autoRun: enabled)], events);
        final pointer = await tester.startGesture(const Offset(260, 420));
        await pointer.moveBy(const Offset(100, -20));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('left-stick-run-target')),
          findsNothing,
        );
        await pointer.moveTo(const Offset(260, 300));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('left-stick-run-target')),
          enabled ? findsOneWidget : findsNothing,
        );
        await pointer.cancel();
        await tester.pump();
        expect(find.byKey(const ValueKey('left-stick-running')), findsNothing);
        expect(events.where((e) => e.value != null).last.value, Offset.zero);
      }
    },
  );

  testWidgets(
    'fixed feedback uses its touch dot to latch and disabling releases run',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      final fixed = left.copyWith(
        stickCenterMode: OnscreenGamepadStickCenterMode.fixed,
      );
      await mount(tester, [fixed], events);
      final placed = const OnscreenGamepadLayoutEngine()
          .layout(
            renderSize: const Size(800, 600),
            profile: kOnscreenGamepadXboxProfile.copyWith(controls: [fixed]),
          )
          .controls
          .single;
      final pointer = await tester.startGesture(placed.center);
      await pointer.moveBy(const Offset(0, -45));
      await tester.pump();
      final target = tester.getCenter(
        find.byKey(const ValueKey('left-stick-run-target')),
      );
      await pointer.moveTo(
        placed.center +
            target -
            placed.positionFeedbackCenter(const Size(800, 600)),
      );
      await pointer.up();
      await tester.pump();
      expect(find.byKey(const ValueKey('left-stick-running')), findsOneWidget);
      final original = placed.center;
      expect(
        (tester.getCenter(find.byKey(const ValueKey('left-stick-running'))) -
                original)
            .distance,
        lessThan(.001),
      );
      await mount(tester, [fixed.copyWith(autoRun: false)], events);
      expect(events.where((e) => e.value != null).last.value, Offset.zero);
      expect(events.last.isUp, isTrue);
    },
  );

  testWidgets('camera mode change releases R3 and ignores the old swipe', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final camera = right.copyWith(stickMode: OnscreenGamepadStickMode.camera);
    await mount(tester, [camera], events);
    final drag = await tester.startGesture(const Offset(700, 50), pointer: 1);
    final button = await tester.startGesture(
      tester.getCenter(find.text('R3')),
      pointer: 2,
    );
    await mount(tester, [right], events);
    expect(events.last.isUp, isTrue);
    final count = events.length;
    await drag.moveBy(const Offset(20, 0));
    await button.up();
    await drag.up();
    expect(events.length, count);
  });
}
