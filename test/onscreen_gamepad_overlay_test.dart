import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  testWidgets('overlay separates zero background and foreground opacity', (
    tester,
  ) async {
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      backgroundOpacity: 0,
      foregroundOpacity: 0,
      controls: [
        kOnscreenGamepadXboxProfile.controls.firstWhere(
          (control) => control.id == 'a',
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 300,
          child: OnscreenGamepadOverlay(profile: profile),
        ),
      ),
    );

    final control = find.byKey(const ValueKey('a'));
    final visual = tester.widget<DecoratedBox>(
      find.descendant(of: control, matching: find.byType(DecoratedBox)).first,
    );
    final decoration = visual.decoration as BoxDecoration;
    final label = tester.widget<Text>(find.text('A'));

    expect(decoration.color?.a, 0);
    expect(decoration.border, isNull);
    expect(label.style?.color?.a, 0);
  });

  testWidgets('stick center uses foreground opacity without a border', (
    tester,
  ) async {
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      controls: [
        kOnscreenGamepadXboxProfile.controls.firstWhere(
          (control) => control.id == 'left-stick',
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 300,
          child: OnscreenGamepadOverlay(profile: profile),
        ),
      ),
    );

    final control = find.byKey(const ValueKey('left-stick'));
    final visuals = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: control, matching: find.byType(DecoratedBox)),
        )
        .toList();
    final knobDecoration = visuals.last.decoration as BoxDecoration;
    final label = tester.widget<Text>(find.text('LS'));

    expect(knobDecoration.color?.a, closeTo(0.60, 0.001));
    expect(knobDecoration.border, isNull);
    expect(label.style?.color?.a, closeTo(0.60, 0.001));
  });

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

  testWidgets('stick presses use the pointer down position as center', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      controls: [
        kOnscreenGamepadXboxProfile.controls.firstWhere(
          (control) => control.id == 'left-stick',
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 300,
          child: OnscreenGamepadOverlay(profile: profile, onEvent: events.add),
        ),
      ),
    );

    final stickRect = tester.getRect(find.byKey(const ValueKey('left-stick')));
    final startPosition = stickRect.center + Offset(stickRect.width * 0.24, 0);
    final gesture = await tester.startGesture(startPosition);
    await tester.pump();

    expect(events, hasLength(1));
    expect(events.single.phase, OnscreenGamepadEventPhase.down);

    await gesture.moveBy(Offset(stickRect.width * 0.25, 0));
    await tester.pump();

    final stickEvent = events.last;
    expect(stickEvent.phase, OnscreenGamepadEventPhase.change);
    expect(stickEvent.value!.dx, closeTo(0.5, 0.001));
    expect(stickEvent.value!.dy, closeTo(0, 0.001));

    await gesture.up();
  });

  testWidgets('quick gamepad stick taps emit the stick button', (tester) async {
    final events = <OnscreenGamepadEvent>[];
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      controls: [
        kOnscreenGamepadXboxProfile.controls.firstWhere(
          (control) => control.id == 'left-stick',
        ),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 300,
          height: 300,
          child: OnscreenGamepadOverlay(profile: profile, onEvent: events.add),
        ),
      ),
    );

    final stickRect = tester.getRect(find.byKey(const ValueKey('left-stick')));
    await tester.tapAt(stickRect.center + Offset(stickRect.width * 0.24, 0));
    await tester.pump();

    expect(events.map((event) => event.phase), [
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.up,
    ]);
    expect(events[1].input.kind, OnscreenGamepadInputKind.gamepadButton);
    expect(events[1].input.code, 'leftStickButton');

    await tester.pump(const Duration(milliseconds: 32));

    expect(events.map((event) => event.phase), [
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.down,
      OnscreenGamepadEventPhase.up,
      OnscreenGamepadEventPhase.up,
    ]);
    expect(events.last.input.kind, OnscreenGamepadInputKind.gamepadButton);
    expect(events.last.input.code, 'leftStickButton');
  });
}
