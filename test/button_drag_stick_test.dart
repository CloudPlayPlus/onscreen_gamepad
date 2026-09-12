import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final button = kOnscreenGamepadXboxProfile.controls
      .firstWhere((c) => c.id == 'a')
      .copyWith(
        mouseDrag: true,
        input: const OnscreenGamepadInput.keyboardKey('ShiftLeft'),
      );
  test('right stick is default and output survives serialization', () {
    expect(button.dragOutput, OnscreenGamepadDragOutput.rightStick);
    for (final output in OnscreenGamepadDragOutput.values) {
      expect(
        OnscreenGamepadControl.fromJson(
          button.copyWith(dragOutput: output).toJson(),
        ).dragOutput,
        output,
      );
    }
  });
  for (final output in [
    OnscreenGamepadDragOutput.rightStick,
    OnscreenGamepadDragOutput.leftStick,
  ]) {
    testWidgets(
      '$output holds normalized vector and releases without unlocking sprint',
      (tester) async {
        final events = <OnscreenGamepadEvent>[];
        final control = button.copyWith(
          dragOutput: output,
          buttonPressMode: OnscreenGamepadButtonPressMode.toggle,
        );
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: OnscreenGamepadOverlay(
              profile: kOnscreenGamepadXboxProfile.copyWith(
                controls: [control],
              ),
              onEvent: events.add,
            ),
          ),
        );
        final center = tester.getCenter(find.text('A'));
        final finger = await tester.startGesture(center);
        expect(events.single.input.code, 'ShiftLeft');
        await finger.moveBy(const Offset(15, -20));
        expect(events.last.value, const Offset(.3, -.4));
        expect(events.last.input.code, output.name);
        final count = events.length;
        await tester.pump(const Duration(seconds: 1));
        expect(events.length, count);
        await finger.moveTo(center + const Offset(100, -100));
        expect(events.last.value!.distance, closeTo(1, .0001));
        await finger.up();
        expect(events.last.value, Offset.zero);
        expect(events.where((e) => e.isUp), isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  }
  testWidgets('output changes release old axis and discard captured touch', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    Future<void> mount(OnscreenGamepadControl control) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OnscreenGamepadOverlay(
          profile: kOnscreenGamepadXboxProfile.copyWith(controls: [control]),
          onEvent: events.add,
        ),
      ),
    );
    await mount(button);
    final finger = await tester.startGesture(tester.getCenter(find.text('A')));
    await finger.moveBy(const Offset(-25, 0));
    await mount(
      button.copyWith(dragOutput: OnscreenGamepadDragOutput.leftStick),
    );
    expect(
      events.where((e) => e.value == Offset.zero).single.input.code,
      'rightStick',
    );
    final count = events.length;
    await finger.moveBy(const Offset(-20, 0));
    await finger.up();
    expect(events.length, count);
  });
}
