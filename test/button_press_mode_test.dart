import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final button = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'a',
  );
  test('button press mode survives serialization and copying', () {
    for (final mode in OnscreenGamepadButtonPressMode.values) {
      final saved = button.copyWith(buttonPressMode: mode).toJson();
      expect(
        OnscreenGamepadControl.fromJson(
          saved,
        ).copyWith(label: 'copy').buttonPressMode,
        mode,
      );
    }
  });
  for (final camera in [false, true]) {
    for (final mode in OnscreenGamepadButtonPressMode.values.where(
      (m) => m != OnscreenGamepadButtonPressMode.slideHold,
    )) {
      testWidgets(
        '${camera ? 'R3' : 'button'} $mode releases taps and locks only as configured',
        (tester) async {
          final base = camera
              ? kOnscreenGamepadXboxProfile.controls
                    .firstWhere((c) => c.id == 'right-stick')
                    .copyWith(stickMode: OnscreenGamepadStickMode.camera)
              : button;
          final control = base.copyWith(buttonPressMode: mode);
          final events = <OnscreenGamepadEvent>[];
          Future<void> mount(OnscreenGamepadControl current) =>
              tester.pumpWidget(
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: OnscreenGamepadOverlay(
                    profile: kOnscreenGamepadXboxProfile.copyWith(
                      controls: [current],
                    ),
                    onEvent: events.add,
                  ),
                ),
              );
          await mount(control);
          final center = tester.getCenter(find.text(camera ? 'R3' : 'A'));
          final pointer = await tester.createGesture();
          await pointer.down(center, timeStamp: const Duration(seconds: 1));
          expect(events.single.isDown, isTrue);
          await pointer.up(timeStamp: const Duration(milliseconds: 1499));
          expect(
            events.length,
            mode == OnscreenGamepadButtonPressMode.toggle ? 1 : 2,
          );
          if (mode == OnscreenGamepadButtonPressMode.toggle) {
            await pointer.down(center, timeStamp: const Duration(seconds: 2));
            expect(events.last.isUp, isTrue);
            await pointer.up(timeStamp: const Duration(seconds: 3));
            expect(events.length, 2);
          }
          events.clear();
          await pointer.down(center, timeStamp: const Duration(seconds: 4));
          await pointer.up(timeStamp: const Duration(milliseconds: 4500));
          expect(
            events.length,
            mode == OnscreenGamepadButtonPressMode.normal ? 2 : 1,
          );
          if (mode != OnscreenGamepadButtonPressMode.normal) {
            await pointer.down(center, timeStamp: const Duration(seconds: 5));
            expect(events.last.isUp, isTrue);
            await pointer.up(timeStamp: const Duration(seconds: 6));
            expect(events.length, 2);
            events.clear();
            await pointer.down(center, timeStamp: const Duration(seconds: 7));
            await pointer.cancel(timeStamp: const Duration(seconds: 8));
            expect(events.length, 2);
            expect(events.last.isUp, isTrue);
            events.clear();
            await pointer.down(center, timeStamp: const Duration(seconds: 9));
            await pointer.up(timeStamp: const Duration(seconds: 10));
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.inactive,
            );
            await tester.pump();
            expect(events.length, 2);
            expect(events.last.isUp, isTrue);
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.resumed,
            );
            events.clear();
            await pointer.down(center, timeStamp: const Duration(seconds: 11));
            await pointer.up(timeStamp: const Duration(seconds: 12));
            await mount(
              control.copyWith(
                buttonPressMode: OnscreenGamepadButtonPressMode.normal,
              ),
            );
            await tester.pump();
            expect(events.length, 2);
            expect(events.last.isUp, isTrue);
          }
        },
      );
    }
  }

  testWidgets(
    'slide holds visited buttons until lift and preserves another finger',
    (tester) async {
      final a = button.copyWith(
        buttonPressMode: OnscreenGamepadButtonPressMode.slideHold,
      );
      final b = button.copyWith(
        id: 'b',
        label: 'B',
        input: const OnscreenGamepadInput.keyboardKey('Space'),
        anchor: OnscreenGamepadAnchor.topLeft,
        offset: Offset.zero,
      );
      final c = kOnscreenGamepadXboxProfile.controls
          .firstWhere((c) => c.id == 'right-stick')
          .copyWith(stickMode: OnscreenGamepadStickMode.camera);
      final events = <OnscreenGamepadEvent>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: OnscreenGamepadOverlay(
            profile: kOnscreenGamepadXboxProfile.copyWith(controls: [a, b, c]),
            onEvent: events.add,
          ),
        ),
      );
      final finger = await tester.startGesture(
        tester.getCenter(find.text('A')),
        pointer: 1,
      );
      await finger.moveTo(tester.getCenter(find.text('B')));
      await finger.moveTo(tester.getCenter(find.text('R3')));
      await finger.moveTo(const Offset(400, 100));
      expect(events.where((e) => e.isDown).map((e) => e.control.id), [
        'a',
        'b',
        'right-stick',
      ]);
      expect(events.where((e) => e.isUp), isEmpty);
      final other = await tester.startGesture(
        tester.getCenter(find.text('B')),
        pointer: 2,
      );
      expect(events.length, 3);
      await finger.up();
      expect(events.where((e) => e.isUp).map((e) => e.control.id).toSet(), {
        'a',
        'right-stick',
      });
      await other.up();
      expect(events.last.control.id, 'b');
      expect(events.last.isUp, isTrue);
      events.clear();
      final canceled = await tester.startGesture(
        tester.getCenter(find.text('A')),
      );
      await canceled.moveTo(tester.getCenter(find.text('B')));
      await canceled.cancel();
      expect(events.where((e) => e.isUp).map((e) => e.control.id).toSet(), {
        'a',
        'b',
      });
      events.clear();
      final removed = await tester.startGesture(
        tester.getCenter(find.text('A')),
      );
      await removed.moveTo(tester.getCenter(find.text('B')));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(events.where((e) => e.isUp).map((e) => e.control.id).toSet(), {
        'a',
        'b',
      });
      expect(events.length, 4);
      await removed.up();
      expect(events.length, 4);
    },
  );

  testWidgets('camera R3 forwards button phases to compatibility callbacks', (
    tester,
  ) async {
    final camera = kOnscreenGamepadXboxProfile.controls
        .firstWhere((c) => c.id == 'right-stick')
        .copyWith(
          stickMode: OnscreenGamepadStickMode.camera,
          buttonPressMode: OnscreenGamepadButtonPressMode.toggle,
        );
    final phases = <String>[];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OnscreenGamepadOverlay(
          profile: kOnscreenGamepadXboxProfile.copyWith(controls: [camera]),
          onControlDown: (c) => phases.add('${c.id}:down'),
          onControlUp: (c) => phases.add('${c.id}:up'),
        ),
      ),
    );
    final swipe = await tester.startGesture(const Offset(700, 50));
    await swipe.moveBy(const Offset(10, 0));
    await swipe.up();
    expect(phases, isEmpty);
    await tester.tap(find.text('R3'));
    expect(phases, ['right-stick:down']);
    await tester.tap(find.text('R3'));
    expect(phases, ['right-stick:down', 'right-stick:up']);
    await tester.tap(find.text('R3'));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(phases, [
      'right-stick:down',
      'right-stick:up',
      'right-stick:down',
      'right-stick:up',
    ]);
  });
}
