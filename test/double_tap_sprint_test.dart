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
  Future<void> mount(
    WidgetTester tester,
    OnscreenGamepadControl control,
    List<OnscreenGamepadEvent> events,
  ) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OnscreenGamepadOverlay(
        profile: kOnscreenGamepadXboxProfile.copyWith(controls: [control]),
        onEvent: events.add,
      ),
    ),
  );
  List<Offset> values(List<OnscreenGamepadEvent> events) =>
      events.where((e) => e.value != null).map((e) => e.value!).toList();

  test(
    'double tap preferences serialize and only enable keyboard movement',
    () {
      final restored = OnscreenGamepadControl.fromJson(
        left.copyWith(sprintTapIntervalMs: 90).toJson(),
      );
      expect(restored.doubleTapSprintEnabled, isTrue);
      expect(restored.sprintKeyEnabled, isFalse);
      expect(restored.effectiveSprintTapIntervalMs, 90);
      expect(
        restored
            .copyWith(behavior: OnscreenGamepadControlBehavior.normal)
            .doubleTapSprintEnabled,
        isFalse,
      );
    },
  );

  testWidgets(
    'horizontal double tap preserves vertical component and fires once',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, left, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveBy(const Offset(160, -160));
      final diagonal = values(events).last;
      await tester.pump(const Duration(milliseconds: 60));
      expect(values(events).last, Offset(0, diagonal.dy));
      await pointer.moveBy(const Offset(1, 0));
      expect(values(events).last.dx, 0);
      await tester.pump(const Duration(milliseconds: 60));
      expect(values(events).last.dx, greaterThan(.35));
      expect(values(events).every((v) => v.dy < -.35), isTrue);
      final count = values(events).length;
      await tester.pump(const Duration(seconds: 1));
      expect(values(events).length, count);
      await pointer.up();
      expect(values(events).last, Offset.zero);
      expect(
        events.where(
          (e) => e.input.kind == OnscreenGamepadInputKind.keyboardKey,
        ),
        isEmpty,
      );
    },
  );

  for (final end in ['release', 'cancel', 'rebind', 'hide', 'retreat']) {
    testWidgets('pending double tap cannot repress after $end', (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, left, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveBy(const Offset(160, 0));
      await tester.pump(const Duration(milliseconds: 60));
      switch (end) {
        case 'release':
          await pointer.up();
        case 'cancel':
          await pointer.cancel();
        case 'rebind':
          await mount(
            tester,
            left.copyWith(behaviorConfig: {'left': 37}),
            events,
          );
          await tester.pump();
        case 'hide':
          await tester.pumpWidget(const SizedBox.shrink());
        case 'retreat':
          await pointer.moveTo(const Offset(260, 420));
      }
      events.clear();
      await tester.pump(const Duration(milliseconds: 200));
      expect(values(events).where((v) => v.dx.abs() > .35), isEmpty);
      if (end == 'rebind' || end == 'retreat') await pointer.up();
    });
  }

  testWidgets('vertical motion never double taps and changing sides rearms', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, left, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveBy(const Offset(0, -160));
    final count = values(events).length;
    await tester.pump(const Duration(milliseconds: 200));
    expect(values(events).length, count);
    await pointer.moveTo(const Offset(420, 420));
    await tester.pump(const Duration(milliseconds: 120));
    await pointer.moveTo(const Offset(100, 420));
    await tester.pump(const Duration(milliseconds: 60));
    expect(values(events).last.dx, 0);
    await tester.pump(const Duration(milliseconds: 60));
    expect(values(events).last.dx, lessThan(-.35));
    await pointer.up();
  });
}
