import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final left = kOnscreenGamepadXboxProfile.controls
      .firstWhere((c) => c.id == 'left-stick')
      .copyWith(
        behavior: OnscreenGamepadControlBehavior.wasdStick,
        input: const OnscreenGamepadInput.custom('wasdStick'),
        sprintEnabled: true,
        sprintDoubleTap: true,
        autoRun: false,
      );
  Future<void> mount(WidgetTester tester, List<OnscreenGamepadEvent> events) =>
      tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OnscreenGamepadOverlay(
            profile: kOnscreenGamepadXboxProfile.copyWith(controls: [left]),
            onEvent: events.add,
          ),
        ),
      );
  List<Offset> values(List<OnscreenGamepadEvent> events) =>
      events.where((e) => e.value != null).map((e) => e.value!).toList();

  testWidgets('double tap mode still latches auto run on target release', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OnscreenGamepadOverlay(
          profile: kOnscreenGamepadXboxProfile.copyWith(
            controls: [left.copyWith(autoRun: true)],
          ),
          onEvent: events.add,
        ),
      ),
    );
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveBy(const Offset(0, -45));
    await tester.pump();
    await pointer.moveTo(
      tester.getCenter(find.byKey(const ValueKey('left-stick-run-target'))),
    );
    await pointer.up();
    await tester.pump();
    expect(find.byKey(const ValueKey('left-stick-running')), findsOneWidget);
    expect(values(events).last, const Offset(0, -1));
    final stop = await tester.startGesture(const Offset(260, 420));
    await stop.cancel();
    await tester.pump();
    expect(find.byKey(const ValueKey('left-stick-running')), findsNothing);
    expect(values(events).last, Offset.zero);
  });

  for (final feedback in [false, true]) {
    for (final delta in [const Offset(160, 0), const Offset(160, -160)]) {
      testWidgets(
        'half circle stays visible and directed during double tap $feedback/$delta',
        (tester) async {
          final events = <OnscreenGamepadEvent>[];
          final profile = kOnscreenGamepadXboxProfile.copyWith(
            controls: [
              left.copyWith(
                positionFeedback: feedback,
                stickCenterMode: OnscreenGamepadStickCenterMode.fixed,
              ),
            ],
          );
          final origin = const OnscreenGamepadLayoutEngine()
              .layout(renderSize: const Size(800, 600), profile: profile)
              .controls
              .single
              .center;
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: OnscreenGamepadOverlay(
                profile: profile,
                onEvent: events.add,
              ),
            ),
          );
          final pointer = await tester.startGesture(origin);
          await pointer.moveBy(delta / 8);
          await pointer.moveTo(
            origin + delta,
            timeStamp: const Duration(milliseconds: 250),
          );
          final half = find.byKey(
            ValueKey(
              feedback
                  ? 'left-stick-position-feedback'
                  : 'left-stick-semicircle',
            ),
          );
          for (var phase = 0; phase <= 3; phase++) {
            await tester.pump(Duration(milliseconds: phase == 0 ? 0 : 50));
            expect(half, findsOneWidget);
            final painter =
                tester.widget<CustomPaint>(half).painter!
                    as OnscreenGamepadSemicirclePainter;
            expect(painter.direction, closeTo(delta.direction, .0001));
            if (phase == 0 || phase == 2) expect(values(events).last.dx, 0);
          }
          await pointer.up();
          await tester.pump();
          expect(half, findsNothing);
        },
      );
    }
  }

  testWidgets(
    'all four diagonals use the same radial threshold as horizontal',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      Future<int> triggerRadius(Offset unit) async {
        final pointer = await tester.startGesture(const Offset(260, 420));
        for (var radius = 20; radius <= 160; radius++) {
          events.clear();
          await pointer.moveTo(
            const Offset(260, 420) + unit * radius.toDouble(),
          );
          if (values(events).any((v) => v.dx == 0)) {
            await pointer.up();
            return radius;
          }
        }
        await pointer.up();
        fail('No sprint trigger for $unit');
      }

      final horizontal = await triggerRadius(const Offset(1, 0));
      for (final x in [-1.0, 1.0]) {
        for (final y in [-1.0, 1.0]) {
          expect(
            await triggerRadius(Offset(x, y) / math.sqrt(2)),
            closeTo(horizontal, 1),
          );
        }
      }
    },
  );

  for (final x in [-1.0, 1.0]) {
    for (final y in [-1.0, 1.0]) {
      testWidgets(
        'angle gate $x/$y requires horizontal sector and preserves running',
        (tester) async {
          final events = <OnscreenGamepadEvent>[];
          await mount(tester, events);
          final pointer = await tester.startGesture(const Offset(260, 420));
          await pointer.moveBy(Offset(x * 70, y * 130));
          expect(values(events).where((v) => v.dx == 0), isEmpty);
          events.clear();
          await pointer.moveTo(
            const Offset(260, 420) + Offset(x * 80, y * 80 * math.sqrt(3)),
          );
          expect(values(events).where((v) => v.dx == 0), hasLength(1));
          await tester.pump(const Duration(milliseconds: 50));
          events.clear();
          await pointer.moveTo(
            const Offset(260, 420) + Offset(x * 70, y * 130),
          );
          expect(values(events).where((v) => v.dx == 0), isEmpty);
          await pointer.up();
        },
      );
    }
  }

  test(
    'double tap preference serializes and only enables keyboard movement',
    () {
      final restored = OnscreenGamepadControl.fromJson(left.toJson());
      expect(restored.doubleTapSprintEnabled, isTrue);
      expect(restored.sprintKeyEnabled, isFalse);
      expect(
        restored
            .copyWith(behavior: OnscreenGamepadControlBehavior.normal)
            .doubleTapSprintEnabled,
        isFalse,
      );
    },
  );

  testWidgets('double tap waits 50ms, horizontal only and stays running', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveBy(const Offset(160, -160));
    final output = values(events);
    expect(output, hasLength(2));
    expect(output[0].dx, greaterThan(.35));
    expect(output[1], Offset(0, output[0].dy));
    await tester.pump(const Duration(milliseconds: 49));
    expect(values(events).last.dx, 0);
    await pointer.moveBy(const Offset(1, 0));
    expect(values(events).last.dx, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(values(events).last.dx, greaterThan(.35));
    events.clear();
    await pointer.moveBy(const Offset(1, 0));
    expect(values(events).where((v) => v.dx == 0), isEmpty);
    expect(
      events.where((e) => e.input.kind == OnscreenGamepadInputKind.keyboardKey),
      isEmpty,
    );
    await pointer.up();
    expect(values(events).last, Offset.zero);
    events.clear();
    await tester.pump(const Duration(seconds: 1));
    expect(events, isEmpty);
  });

  testWidgets('running survives retreat below sprint threshold until release', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveTo(const Offset(420, 420));
    await tester.pump(const Duration(milliseconds: 50));
    events.clear();
    await pointer.moveTo(const Offset(285, 420));
    await pointer.moveTo(const Offset(420, 420));
    await tester.pump(const Duration(milliseconds: 200));
    expect(values(events).where((v) => v.dx == 0), isEmpty);
    await pointer.up();
  });

  for (final elapsed in [199, 200, 250]) {
    testWidgets('first press age ${elapsed}ms chooses single or full tap', (
      tester,
    ) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveTo(
        const Offset(285, 420),
        timeStamp: const Duration(milliseconds: 10),
      );
      events.clear();
      await pointer.moveTo(
        const Offset(420, 420),
        timeStamp: Duration(milliseconds: 10 + elapsed),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(values(events).last.dx, 1);
      await tester.pump(const Duration(milliseconds: 50));
      expect(values(events).last.dx, elapsed < 200 ? 1 : 0);
      await tester.pump(const Duration(milliseconds: 50));
      expect(values(events).last.dx, 1);
      await pointer.up();
    });
  }

  testWidgets('vertical press after right requires full double tap', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveTo(
      const Offset(285, 420),
      timeStamp: const Duration(milliseconds: 10),
    );
    await pointer.moveTo(
      const Offset(285, 445),
      timeStamp: const Duration(milliseconds: 20),
    );
    events.clear();
    await pointer.moveTo(
      const Offset(420, 580),
      timeStamp: const Duration(milliseconds: 30),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    expect(values(events).last.dx, 0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(values(events).last.dx, greaterThan(.35));
    expect(values(events).every((v) => v.dy > .35), isTrue);
    await pointer.up();
  });

  testWidgets('vertical motion never double taps, retreat and sides rearm', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveBy(const Offset(0, -160));
    expect(values(events), hasLength(1));
    expect(values(events).single.dx, 0);
    events.clear();
    await pointer.moveTo(const Offset(420, 420));
    expect(values(events).map((v) => v.dx), [1, 0]);
    await tester.pump(const Duration(milliseconds: 50));
    expect(values(events).last.dx, 1);
    events.clear();
    await pointer.moveTo(const Offset(100, 420));
    expect(values(events).map((v) => v.dx), [-1, 0]);
    await tester.pump(const Duration(milliseconds: 50));
    expect(values(events).last.dx, -1);
    await pointer.moveTo(const Offset(260, 420));
    events.clear();
    await pointer.moveTo(const Offset(100, 420));
    expect(values(events).map((v) => v.dx), [-1, 0]);
    await tester.pump(const Duration(milliseconds: 50));
    expect(values(events).last.dx, -1);
    await pointer.cancel();
    expect(values(events).last, Offset.zero);
  });
  for (final elapsed in [0, 50, 100]) {
    testWidgets('full double tap cancels at ${elapsed}ms', (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveTo(const Offset(285, 420));
      await pointer.moveTo(
        const Offset(420, 420),
        timeStamp: const Duration(milliseconds: 250),
      );
      if (elapsed >= 50) await tester.pump(const Duration(milliseconds: 50));
      if (elapsed >= 100) await tester.pump(const Duration(milliseconds: 50));
      await pointer.moveTo(const Offset(260, 420));
      events.clear();
      await tester.pump(const Duration(milliseconds: 200));
      expect(values(events).where((v) => v.dx != 0), isEmpty);
      await pointer.up();
    });
  }

  for (final action in ['up', 'cancel', 'hide', 'retreat']) {
    testWidgets('gap cannot repress after $action', (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveBy(const Offset(160, 0));
      switch (action) {
        case 'up':
          await pointer.up();
        case 'cancel':
          await pointer.cancel();
        case 'hide':
          await tester.pumpWidget(const SizedBox.shrink());
        case 'retreat':
          await pointer.moveTo(const Offset(260, 420));
      }
      events.clear();
      await tester.pump(const Duration(milliseconds: 100));
      expect(values(events).where((v) => v.dx != 0), isEmpty);
      if (action == 'retreat') await pointer.up();
    });
  }
}
