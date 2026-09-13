import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final left = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'left-stick',
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
  List<OnscreenGamepadEventPhase> keys(List<OnscreenGamepadEvent> events) =>
      events
          .where((e) => e.input.kind == OnscreenGamepadInputKind.keyboardKey)
          .map((e) => e.phase)
          .toList();

  test('sprint preferences survive serialization and copying', () {
    expect(left.sprintEnabled, isFalse);
    expect(left.sprintKey.code, 'ShiftLeft');
    expect(left.effectiveSprintThreshold, .70);
    final restored = OnscreenGamepadControl.fromJson(
      left
          .copyWith(
            sprintEnabled: true,
            sprintThreshold: .7,
            sprintKey: const OnscreenGamepadInput.keyboardKey('KeyR'),
          )
          .toJson(),
    ).copyWith(label: 'move');
    expect(restored.sprintEnabled, isTrue);
    expect(restored.sprintKey.code, 'KeyR');
    expect(restored.effectiveSprintThreshold, .7);
    expect(
      left.copyWith(sprintThreshold: double.nan).effectiveSprintThreshold,
      .70,
    );
  });

  for (final code in ['leftStick', 'rightTrigger']) {
    testWidgets('gamepad sprint $code presses and releases at threshold', (
      tester,
    ) async {
      final events = <OnscreenGamepadEvent>[];
      final control = OnscreenGamepadControl.fromJson(
        left
            .copyWith(
              sprintEnabled: true,
              autoRun: false,
              sprintKey: OnscreenGamepadInput.gamepadButton(code),
            )
            .toJson(),
      );
      expect(control.sprintKeyEnabled, isTrue);
      await mount(tester, control, events);
      const origin = Offset(260, 420);
      final pointer = await tester.startGesture(origin);
      await pointer.moveBy(const Offset(160, 0));
      final press = events
          .where(
            (e) =>
                e.input.kind == OnscreenGamepadInputKind.gamepadButton &&
                e.input.code == code,
          )
          .single;
      expect(press.type, OnscreenGamepadEventType.gamepadButton);
      expect(press.isDown, isTrue);
      await pointer.moveTo(origin);
      expect(
        events
            .where(
              (e) =>
                  e.input.kind == OnscreenGamepadInputKind.gamepadButton &&
                  e.input.code == code,
            )
            .last
            .isUp,
        isTrue,
      );
      await pointer.cancel();
    });
  }

  testWidgets('raw distance triggers once, retreat releases, auto run holds', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, left.copyWith(sprintEnabled: true), events);
    const origin = Offset(260, 420);
    final pointer = await tester.startGesture(origin);
    await pointer.moveTo(origin + const Offset(0, -45));
    await tester.pump();
    final target = tester.getCenter(
      find.byKey(const ValueKey('left-stick-run-target')),
    );
    final minimum = (target - origin).distance - 30;
    await pointer.moveTo(origin + Offset(0, -minimum * .65));
    expect(keys(events), isEmpty);
    await pointer.moveTo(origin + Offset(0, -minimum * .75));
    expect(keys(events), [OnscreenGamepadEventPhase.down]);
    await pointer.moveTo(origin + Offset(0, -minimum * .755));
    expect(keys(events).length, 1);
    await pointer.moveTo(origin + Offset(0, -minimum * .65));
    expect(keys(events).last, OnscreenGamepadEventPhase.up);
    await pointer.moveTo(target);
    await pointer.up();
    await tester.pump();
    expect(keys(events).last, OnscreenGamepadEventPhase.down);
    final touch = await tester.startGesture(origin);
    expect(keys(events).last, OnscreenGamepadEventPhase.up);
    await touch.cancel();
  });

  testWidgets('works without auto run and releases on cancellation or rebind', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final control = left.copyWith(sprintEnabled: true, autoRun: false);
    await mount(tester, control, events);
    final pointer = await tester.startGesture(const Offset(260, 420));
    await pointer.moveBy(const Offset(180, 0));
    expect(keys(events), [OnscreenGamepadEventPhase.down]);
    await pointer.cancel();
    expect(keys(events).last, OnscreenGamepadEventPhase.up);
    final next = await tester.startGesture(const Offset(260, 420));
    await next.moveBy(const Offset(180, 0));
    await mount(
      tester,
      control.copyWith(
        sprintKey: const OnscreenGamepadInput.keyboardKey('KeyR'),
      ),
      events,
    );
    await tester.pump();
    final releases = events.where(
      (e) => e.input.kind == OnscreenGamepadInputKind.keyboardKey && e.isUp,
    );
    expect(releases.last.input.code, 'ShiftLeft');
    await next.cancel();
  });
}
