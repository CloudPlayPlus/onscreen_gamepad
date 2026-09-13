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

  testWidgets(
    'double tap is immediate, horizontal only and once per excursion',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(260, 420));
      await pointer.moveBy(const Offset(160, -160));
      final output = values(events);
      expect(output, hasLength(3));
      expect(output[0].dx, greaterThan(.35));
      expect(output[1], Offset(0, output[0].dy));
      expect(output[2], output[0]);
      events.clear();
      await pointer.moveBy(const Offset(1, 0));
      expect(values(events).where((v) => v.dx == 0), isEmpty);
      expect(
        events.where(
          (e) => e.input.kind == OnscreenGamepadInputKind.keyboardKey,
        ),
        isEmpty,
      );
      await pointer.up();
      expect(values(events).last, Offset.zero);
      events.clear();
      await tester.pump(const Duration(seconds: 1));
      expect(events, isEmpty);
    },
  );

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
    expect(values(events).map((v) => v.dx), [1, 0, 1]);
    events.clear();
    await pointer.moveTo(const Offset(100, 420));
    expect(values(events).map((v) => v.dx), [-1, 0, -1]);
    await pointer.moveTo(const Offset(260, 420));
    events.clear();
    await pointer.moveTo(const Offset(100, 420));
    expect(values(events).map((v) => v.dx), [-1, 0, -1]);
    await pointer.cancel();
    expect(values(events).last, Offset.zero);
  });
}
