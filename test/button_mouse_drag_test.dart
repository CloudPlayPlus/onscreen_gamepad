import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final button = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'a',
  );
  Future<void> mount(
    WidgetTester tester,
    List<OnscreenGamepadControl> controls,
    List<OnscreenGamepadEvent> events,
  ) => tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: OnscreenGamepadOverlay(
        profile: kOnscreenGamepadXboxProfile.copyWith(controls: controls),
        onEvent: events.add,
      ),
    ),
  );

  test('mouse drag is opt-in and survives JSON and binding changes', () {
    expect(button.mouseDrag, isFalse);
    final configured = button.copyWith(
      mouseDrag: true,
      dragOutput: OnscreenGamepadDragOutput.mouse,
      mouseSensitivity: 2.5,
    );
    final restored = OnscreenGamepadControl.fromJson(
      jsonDecode(jsonEncode(configured.toJson())) as Map<String, dynamic>,
    ).copyWith(input: const OnscreenGamepadInput.keyboardKey('ShiftLeft'));
    expect(restored.mouseDrag, isTrue);
    expect(restored.effectiveMouseSensitivity, 2.5);
    expect(restored.copyWith(mouseDrag: false).mouseDrag, isFalse);
  });

  for (final input in [
    const OnscreenGamepadInput.keyboardKey('ShiftLeft'),
    const OnscreenGamepadInput.mouseButton(0),
    const OnscreenGamepadInput.gamepadButton('b'),
  ]) {
    testWidgets(
      '${input.kind.name} holds binding while dragging outside button',
      (tester) async {
        final events = <OnscreenGamepadEvent>[];
        await mount(tester, [
          button.copyWith(
            input: input,
            mouseDrag: true,
            dragOutput: OnscreenGamepadDragOutput.mouse,
            mouseSensitivity: 2,
          ),
        ], events);
        final finger = await tester.startGesture(
          tester.getCenter(find.text('A')),
        );
        expect(events.single.isDown, isTrue);
        expect(events.single.input.code, input.code);
        await finger.moveBy(const Offset(-150, -100));
        expect(events.last.delta, const Offset(-300, -200));
        await finger.moveBy(const Offset(3, 4));
        expect(events.last.delta, const Offset(6, 8));
        await finger.up();
        expect(events.last.isUp, isTrue);
        expect(events.where((e) => e.isDown).length, 1);
        expect(events.where((e) => e.isUp).length, 1);
      },
    );
  }

  testWidgets('disabled property leaves ordinary button drags unchanged', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [button], events);
    final finger = await tester.startGesture(tester.getCenter(find.text('A')));
    await finger.moveBy(const Offset(-100, -50));
    await finger.up();
    expect(events.map((e) => e.phase), [
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.up,
    ]);
  });

  testWidgets(
    'toggled binding stays held after touch ends but mouse movement stops',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, [
        button.copyWith(
          mouseDrag: true,
          dragOutput: OnscreenGamepadDragOutput.mouse,
          buttonPressMode: OnscreenGamepadButtonPressMode.toggle,
        ),
      ], events);
      final center = tester.getCenter(find.text('A'));
      final finger = await tester.startGesture(center);
      await finger.moveBy(const Offset(2, 1));
      await finger.up();
      expect(events.where((e) => e.isUp), isEmpty);
      expect(events.last.delta, const Offset(20, 10));
      final count = events.length;
      await tester.pump(const Duration(seconds: 1));
      expect(events.length, count);
      final unlock = await tester.startGesture(center);
      expect(events.last.isUp, isTrue);
      await unlock.moveBy(const Offset(1, 2));
      expect(events.last.delta, const Offset(10, 20));
      await unlock.up();
    },
  );

  testWidgets('changing property cancels old pointer and releases binding', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [button.copyWith(mouseDrag: true)], events);
    final finger = await tester.startGesture(tester.getCenter(find.text('A')));
    await mount(tester, [button.copyWith(mouseDrag: false)], events);
    expect(events.last.isUp, isTrue);
    final count = events.length;
    await finger.moveBy(const Offset(-20, 0));
    await finger.up();
    expect(events.length, count);
  });

  testWidgets('cancel stops movement and a new finger starts without a jump', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [
      button.copyWith(
        mouseDrag: true,
        dragOutput: OnscreenGamepadDragOutput.mouse,
        mouseSensitivity: 1,
      ),
    ], events);
    final center = tester.getCenter(find.text('A'));
    final finger = await tester.startGesture(center);
    await finger.moveBy(const Offset(-20, 0));
    await finger.cancel();
    expect(events.last.isUp, isTrue);
    final other = await tester.startGesture(center);
    expect(events.last.isDown, isTrue);
    await other.moveBy(const Offset(1, 2));
    expect(events.last.delta, const Offset(1, 2));
    await other.up();
  });

  testWidgets('slide hold uses only the source mouse drag setting', (
    tester,
  ) async {
    final source = button.copyWith(
      mouseDrag: true,
      dragOutput: OnscreenGamepadDragOutput.mouse,
      mouseSensitivity: 2,
      buttonPressMode: OnscreenGamepadButtonPressMode.slideHold,
    );
    final target = button.copyWith(
      id: 'b',
      label: 'B',
      anchor: OnscreenGamepadAnchor.topLeft,
      offset: Offset.zero,
      mouseDrag: true,
      dragOutput: OnscreenGamepadDragOutput.mouse,
      mouseSensitivity: 50,
    );
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [source, target], events);
    final start = tester.getCenter(find.text('A'));
    final end = tester.getCenter(find.text('B'));
    final finger = await tester.startGesture(start);
    await finger.moveTo(end);
    expect(
      events.where((e) => e.delta != null).single.delta,
      (end - start) * 2,
    );
    expect(events.where((e) => e.isDown).map((e) => e.control.id), ['a', 'b']);
    await finger.up();
    expect(events.where((e) => e.isUp).map((e) => e.control.id).toSet(), {
      'a',
      'b',
    });
  });

  testWidgets('camera R3 drag and half-screen drag keep separate positions', (
    tester,
  ) async {
    final right = kOnscreenGamepadXboxProfile.controls
        .firstWhere((c) => c.id == 'right-stick')
        .copyWith(
          stickMode: OnscreenGamepadStickMode.camera,
          mouseDrag: true,
          dragOutput: OnscreenGamepadDragOutput.mouse,
          mouseSensitivity: 2,
        );
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, [right], events);
    final center = tester.getCenter(find.text('R3'));
    final r3 = await tester.startGesture(center, pointer: 1);
    final camera = await tester.startGesture(
      const Offset(600, 100),
      pointer: 2,
    );
    await r3.moveBy(const Offset(3, 4));
    expect(events.last.delta, const Offset(6, 8));
    await camera.moveBy(const Offset(-5, 1));
    expect(events.last.delta, const Offset(-10, 2));
    await r3.up();
    expect(events.last.isUp, isTrue);
    await camera.moveBy(const Offset(1, 1));
    expect(events.last.delta, const Offset(2, 2));
    await camera.up();
  });
}
