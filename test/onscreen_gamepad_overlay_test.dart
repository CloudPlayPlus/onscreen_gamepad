import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  testWidgets('overlay emits unified down and up events for buttons', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 852,
          height: 393,
          child: OnscreenGamepadOverlay(
            profile: kOnscreenGamepadXboxProfile,
            onEvent: events.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('A'));
    await tester.pump();

    expect(events.length, 2);
    expect(events.first.control.id, 'a');
    expect(events.first.phase, OnscreenGamepadEventPhase.down);
    expect(events.last.control.id, 'a');
    expect(events.last.phase, OnscreenGamepadEventPhase.up);
  });

  testWidgets('overlay keeps legacy callbacks while emitting unified events', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final legacyEvents = <String>[];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 852,
          height: 393,
          child: OnscreenGamepadOverlay(
            profile: kOnscreenGamepadXboxProfile,
            onEvent: events.add,
            onControlDown: (control) => legacyEvents.add('${control.id}:down'),
            onControlUp: (control) => legacyEvents.add('${control.id}:up'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('B'));
    await tester.pump();

    expect(events.map((event) => event.phase), [
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.up,
    ]);
    expect(legacyEvents, ['b:down', 'b:up']);
  });

  testWidgets('overlay emits mouse mode changes with the selected mode', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      controls: [
        const OnscreenGamepadControl(
          id: 'touch-mode',
          label: 'Touch',
          anchor: OnscreenGamepadAnchor.bottomCenter,
          offset: Offset.zero,
          kind: OnscreenGamepadControlKind.square,
          role: OnscreenGamepadControlRole.utility,
          sizeTier: OnscreenGamepadSizeTier.medium,
          input: OnscreenGamepadInput.mouseMode('leftClick'),
          behavior: OnscreenGamepadControlBehavior.mouseModeCycle,
          behaviorConfig: {
            'modes': ['leftClick', 'rightClick'],
          },
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 852,
          height: 393,
          child: OnscreenGamepadOverlay(profile: profile, onEvent: events.add),
        ),
      ),
    );

    await tester.tap(find.text('Touch'));
    await tester.pump();
    await tester.tap(find.text('Touch'));
    await tester.pump();

    expect(events.map((event) => event.type), [
      OnscreenGamepadEventType.mouseMode,
      OnscreenGamepadEventType.mouseMode,
    ]);
    expect(events.map((event) => event.phase), [
      OnscreenGamepadEventPhase.change,
      OnscreenGamepadEventPhase.change,
    ]);
    expect(events.map((event) => event.mode), ['leftClick', 'rightClick']);
  });
}
