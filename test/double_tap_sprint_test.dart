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
