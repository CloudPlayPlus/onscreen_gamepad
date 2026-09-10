import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  final stick = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'left-stick',
  );
  final rightStick = kOnscreenGamepadXboxProfile.controls.firstWhere(
    (c) => c.id == 'right-stick',
  );

  test(
    'position feedback defaults follow input and explicit choices survive JSON and rebinding',
    () {
      final stick = kOnscreenGamepadXboxProfile.controls
          .firstWhere((c) => c.id == 'left-stick')
          .copyWith(stickCenterMode: OnscreenGamepadStickCenterMode.fixed);
      final rightStick = kOnscreenGamepadXboxProfile.controls
          .firstWhere((c) => c.id == 'right-stick')
          .copyWith(stickCenterMode: OnscreenGamepadStickCenterMode.fixed);
      expect(stick.positionFeedbackEnabled, isTrue);
      expect(rightStick.positionFeedbackEnabled, isFalse);
      expect(stick.toJson().containsKey('af'), isFalse);
      expect(
        OnscreenGamepadControl.fromJson(stick.toJson()).positionFeedbackEnabled,
        isTrue,
      );
      expect(
        OnscreenGamepadControl.fromJson(
          rightStick.toJson(),
        ).positionFeedbackEnabled,
        isFalse,
      );
      expect(
        rightStick
            .copyWith(behavior: OnscreenGamepadControlBehavior.wasdStick)
            .positionFeedbackEnabled,
        isTrue,
      );
      for (final enabled in [false, true]) {
        final configured = stick.copyWith(positionFeedback: enabled);
        final restored = OnscreenGamepadControl.fromJson(configured.toJson());
        expect(restored.toJson()['af'], enabled);
        expect(restored.positionFeedbackEnabled, enabled);
        expect(
          restored
              .copyWith(input: rightStick.input, behaviorConfig: {})
              .positionFeedbackEnabled,
          enabled,
        );
      }
    },
  );
  final button = kOnscreenGamepadXboxProfile.controls
      .firstWhere((c) => c.id == 'a')
      .copyWith(
        anchor: OnscreenGamepadAnchor.bottomLeft,
        offset: const Offset(.6, -.5),
        sortOrder: -1,
      );
  final profile = kOnscreenGamepadXboxProfile.copyWith(
    controls: [button, stick],
  );
  test(
    'feedback location survives copy and JSON, scales and stays on screen',
    () {
      final configured = stick.copyWith(
        positionFeedbackLocation: const Offset(.4, .3),
      );
      final restored = OnscreenGamepadControl.fromJson(
        configured.toJson(),
      ).copyWith(label: 'custom');
      expect(restored.positionFeedbackLocation, const Offset(.4, .3));
      for (final size in [const Size(800, 600), const Size(600, 800)]) {
        final placed = const OnscreenGamepadLayoutEngine()
            .layout(
              renderSize: size,
              profile: profile.copyWith(controls: [restored]),
            )
            .controls
            .single;
        expect(
          placed.positionFeedbackCenter(size),
          Offset(size.width * .4, size.height * .3),
        );
      }
      final edge = const OnscreenGamepadLayoutEngine()
          .layout(
            renderSize: const Size(800, 600),
            profile: profile.copyWith(
              controls: [
                stick.copyWith(positionFeedbackLocation: const Offset(1, 0)),
              ],
            ),
          )
          .controls
          .single;
      final center = edge.positionFeedbackCenter(const Size(800, 600));
      expect(center.dx + edge.visualSize * .34, lessThan(800));
      expect(center.dy - edge.visualSize * .34, greaterThan(0));
    },
  );
  Future<void> mount(
    WidgetTester tester,
    List<OnscreenGamepadEvent> events, {
    Size size = const Size(800, 600),
    OnscreenGamepadProfile? customProfile,
  }) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: OnscreenGamepadOverlay(
              profile: customProfile ?? profile,
              onEvent: events.add,
            ),
          ),
        ),
      ),
    );
  }

  test('region trigger defaults on and preserves explicit choices', () {
    expect(stick.regionTrigger, isTrue);
    expect(stick.isMovementStick, isTrue);
    expect(rightStick.isMovementStick, isFalse);
    expect(
      rightStick
          .copyWith(behavior: OnscreenGamepadControlBehavior.wasdStick)
          .isMovementStick,
      isTrue,
    );
    for (final enabled in [false, true]) {
      final restored = OnscreenGamepadControl.fromJson(
        stick.copyWith(regionTrigger: enabled).toJson(),
      ).copyWith(input: rightStick.input);
      expect(restored.regionTrigger, enabled);
    }
    expect(
      OnscreenGamepadControl.fromJson(stick.toJson()).regionTrigger,
      isTrue,
    );
  });

  testWidgets('region trigger controls blank starts in both center modes', (
    tester,
  ) async {
    for (final mode in OnscreenGamepadStickCenterMode.values) {
      for (final enabled in [false, true]) {
        await tester.pumpWidget(const SizedBox.shrink());
        final selected = profile.copyWith(
          controls: [
            stick.copyWith(stickCenterMode: mode, regionTrigger: enabled),
          ],
        );
        final events = <OnscreenGamepadEvent>[];
        await mount(tester, events, customProfile: selected);
        final pointer = await tester.startGesture(const Offset(340, 460));
        await pointer.moveBy(const Offset(40, 0));
        expect(
          events.any((e) => e.value != null && e.value != Offset.zero),
          enabled,
        );
        await pointer.up();
        await tester.pump();
        events.clear();
        final center = const OnscreenGamepadLayoutEngine()
            .layout(renderSize: const Size(800, 600), profile: selected)
            .controls
            .single
            .center;
        final original = await tester.startGesture(center);
        await original.moveBy(const Offset(150, 0));
        expect(events.last.value, const Offset(1, 0));
        await original.up();
        await tester.pump();
      }
    }
  });

  testWidgets(
    'changing region trigger releases input and ignores the old pointer',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(340, 460));
      await pointer.moveBy(const Offset(40, 0));
      expect(events.last.value, const Offset(1, 0));
      await mount(
        tester,
        events,
        customProfile: profile.copyWith(
          controls: [button, stick.copyWith(regionTrigger: false)],
        ),
      );
      expect(events.where((e) => e.value != null).last.value, Offset.zero);
      final count = events.length;
      await pointer.moveBy(const Offset(40, 0));
      await pointer.up();
      await tester.pump();
      expect(events.length, count);
    },
  );

  test('stick center mode defaults and survives JSON and copying', () {
    expect(stick.stickCenterMode, OnscreenGamepadStickCenterMode.touchDown);
    for (final mode in OnscreenGamepadStickCenterMode.values) {
      final restored = OnscreenGamepadControl.fromJson(
        stick.copyWith(stickCenterMode: mode).toJson(),
      );
      expect(restored.copyWith(label: 'copy').stickCenterMode, mode);
    }
  });

  testWidgets(
    'fixed mode uses original center immediately and releases on mode change',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      final fixedProfile = profile.copyWith(
        controls: [
          stick.copyWith(
            stickCenterMode: OnscreenGamepadStickCenterMode.fixed,
            positionFeedback: false,
          ),
        ],
      );
      final placed = const OnscreenGamepadLayoutEngine()
          .layout(renderSize: const Size(800, 600), profile: fixedProfile)
          .controls
          .single;
      await mount(tester, events, customProfile: fixedProfile);
      final pointer = await tester.startGesture(
        placed.center + const Offset(20.5, 0),
      );
      await tester.pump();
      expect(events.first.isDown, isTrue);
      expect(
        (events.last.value! - const Offset(.5, 0)).distance,
        lessThan(.001),
      );
      expect(
        (tester.getCenter(find.byKey(const ValueKey('left-stick-semicircle'))) -
                placed.center)
            .distance,
        lessThan(.001),
      );
      await pointer.moveTo(placed.center + const Offset(0, -40));
      expect(
        (events.last.value! - const Offset(0, -1)).distance,
        lessThan(.001),
      );
      await mount(
        tester,
        events,
        customProfile: profile.copyWith(controls: [stick]),
      );
      await tester.pump();
      expect(events[events.length - 2].value, Offset.zero);
      expect(events.last.isUp, isTrue);
      await pointer.up();
      expect(
        events.where(
          (e) => e.input.kind == OnscreenGamepadInputKind.gamepadButton,
        ),
        isEmpty,
      );
      events.clear();
      final next = await tester.startGesture(
        placed.center + const Offset(20.5, 0),
      );
      await tester.pump();
      expect(events.where((e) => e.value != null), isEmpty);
      await next.moveBy(const Offset(20.5, 0));
      expect(
        (events.last.value! - const Offset(.5, 0)).distance,
        lessThan(.001),
      );
      await next.cancel();
      await tester.pump();
    },
  );

  testWidgets('small nudges respond and shorter travel reaches full force', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    const origin = Offset(340, 460);
    final pointer = await tester.startGesture(origin);
    await pointer.moveTo(origin + const Offset(1, 0));
    await tester.pump();
    expect(events.where((event) => event.value != null), isEmpty);
    expect(find.byKey(const ValueKey('left-stick-semicircle')), findsNothing);
    await pointer.moveTo(origin + const Offset(1.5, 0));
    await tester.pump();
    expect(events.last.value!.dx, closeTo(.5 / 39, .001));
    expect(find.byKey(const ValueKey('left-stick-semicircle')), findsOneWidget);
    await pointer.moveTo(origin + const Offset(10, 0));
    expect(events.last.value!.dx, closeTo(9 / 39, .001));
    await pointer.moveTo(origin + const Offset(40, 0));
    expect(events.last.value, const Offset(1, 0));
    await pointer.moveTo(origin + const Offset(.5, 0));
    await tester.pump();
    expect(events.last.value, Offset.zero);
    expect(find.byKey(const ValueKey('left-stick-semicircle')), findsNothing);
    await pointer.up();
    await tester.pump();
  });

  testWidgets(
    'center modes show exactly one semicircle and gate the extra dot',
    (tester) async {
      for (final mode in OnscreenGamepadStickCenterMode.values) {
        for (final enabled in [false, true]) {
          await tester.pumpWidget(const SizedBox.shrink());
          final control = stick.copyWith(
            stickCenterMode: mode,
            positionFeedback: enabled,
          );
          final extraEnabled =
              mode == OnscreenGamepadStickCenterMode.fixed && enabled;
          expect(control.positionFeedbackEnabled, extraEnabled);
          final selectedProfile = profile.copyWith(controls: [control]);
          final placed = const OnscreenGamepadLayoutEngine()
              .layout(
                renderSize: const Size(800, 600),
                profile: selectedProfile,
              )
              .controls
              .single;
          final events = <OnscreenGamepadEvent>[];
          await mount(tester, events, customProfile: selectedProfile);
          final downPoint = placed.center + const Offset(20.5, 0);
          final pointer = await tester.startGesture(downPoint);
          await pointer.moveBy(const Offset(20.5, 0));
          await tester.pump();
          final original = find.byKey(const ValueKey('left-stick-semicircle'));
          final extra = find.byKey(
            const ValueKey('left-stick-position-feedback'),
          );
          final dot = find.byKey(const ValueKey('left-stick-touch-dot'));
          expect(original, extraEnabled ? findsNothing : findsOneWidget);
          expect(extra, extraEnabled ? findsOneWidget : findsNothing);
          expect(dot, extraEnabled ? findsOneWidget : findsNothing);
          final half = tester.widget<CustomPaint>(
            extraEnabled ? extra : original,
          );
          expect(
            (half.painter! as OnscreenGamepadSemicirclePainter).color.a,
            closeTo(.60, .001),
          );
          for (final (foreground, expected) in [(.2, .32), (.94, 1.0)]) {
            await mount(
              tester,
              events,
              customProfile: selectedProfile.copyWith(
                foregroundOpacity: foreground,
              ),
            );
            final updated = tester.widget<CustomPaint>(
              extraEnabled ? extra : original,
            );
            expect(
              (updated.painter! as OnscreenGamepadSemicirclePainter).color.a,
              closeTo(expected, .002),
            );
          }
          if (extraEnabled) {
            final center = placed.positionFeedbackCenter(const Size(800, 600));
            expect((tester.getCenter(extra) - center).distance, lessThan(.001));
            expect(
              (tester.getCenter(dot) - center - const Offset(41, 0)).distance,
              lessThan(.001),
            );
            await pointer.moveBy(const Offset(100, 0));
            await tester.pump();
            expect((tester.getCenter(extra) - center).distance, lessThan(.001));
          }
          await pointer.cancel();
          await tester.pump();
          expect(original, findsNothing);
          expect(extra, findsNothing);
          expect(dot, findsNothing);
          expect(events[events.length - 2].value, Offset.zero);
          expect(events.last.isUp, isTrue);
        }
      }
    },
  );
  testWidgets(
    'fixed right stick switches between original and extra feedback',
    (tester) async {
      for (final enabled in [null, true]) {
        await tester.pumpWidget(const SizedBox.shrink());
        final events = <OnscreenGamepadEvent>[];
        await mount(
          tester,
          events,
          customProfile: profile.copyWith(
            controls: [
              rightStick.copyWith(
                positionFeedback: enabled,
                stickCenterMode: OnscreenGamepadStickCenterMode.fixed,
              ),
            ],
          ),
        );
        final origin = tester.getCenter(find.byKey(ValueKey(rightStick.id)));
        final pointer = await tester.startGesture(origin);
        await pointer.moveBy(const Offset(20.5, 0));
        await tester.pump();
        expect(
          (events.last.value! - const Offset(.5, 0)).distance,
          lessThan(.001),
        );
        expect(
          find.byKey(const ValueKey('right-stick-semicircle')),
          enabled == true ? findsNothing : findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('right-stick-position-feedback')),
          enabled == true ? findsOneWidget : findsNothing,
        );
        expect(find.text('RS'), findsNothing);
        await pointer.up();
        await tester.pump();
      }
    },
  );

  testWidgets(
    'wide area locks origin, hides base, keeps a small filled half disc and clamps force',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      const origin = Offset(340, 460);
      final pointer = await tester.startGesture(origin);
      await tester.pump();
      expect(events.single.isDown, isTrue);
      expect(find.text('LS'), findsNothing);
      await pointer.moveTo(origin + const Offset(.5, -.5));
      await tester.pump();
      expect(events.where((e) => e.value != null), isEmpty);
      await pointer.moveTo(origin + const Offset(20.5, 0));
      await tester.pump();
      expect(events.last.value, const Offset(.5, 0));
      final half = find.byKey(const ValueKey('left-stick-semicircle'));
      final rect = tester.getRect(half);
      expect(rect.center, origin);
      final placed = const OnscreenGamepadLayoutEngine()
          .layout(renderSize: const Size(800, 600), profile: profile)
          .controls
          .firstWhere((c) => c.control.id == stick.id);
      expect(rect.width, closeTo(placed.visualSize * .68, .001));
      await pointer.moveTo(origin + const Offset(250, -250));
      await tester.pump();
      expect(tester.getRect(half), rect);
      expect(events.last.value!.distance, closeTo(1, .001));
      await pointer.moveTo(origin);
      await tester.pump();
      expect(events.last.value, Offset.zero);
      await pointer.cancel();
      await tester.pump();
      expect(events.last.isUp, isTrue);
      expect(find.text('LS'), findsOneWidget);
      expect(half, findsNothing);
    },
  );

  testWidgets(
    'buttons beat expanded stick regardless of order and support a second pointer',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final buttonCenter = tester.getCenter(find.byKey(ValueKey(button.id)));
      final tap = await tester.startGesture(buttonCenter, pointer: 2);
      expect(events.single.control.id, button.id);
      await tap.up();
      events.clear();
      final drag = await tester.startGesture(
        const Offset(340, 460),
        pointer: 3,
      );
      await drag.moveBy(const Offset(20.5, 0));
      await tester.pump();
      final second = await tester.startGesture(buttonCenter, pointer: 4);
      await tester.pump();
      expect(events.last.control.id, button.id);
      await second.up();
      await drag.moveBy(const Offset(8, 0));
      expect(events.last.control.id, stick.id);
      expect(events.last.value!.dx, greaterThan(.5));
      final buttonDowns = events
          .where((e) => e.control.id == button.id && e.isDown)
          .length;
      await drag.moveTo(buttonCenter);
      expect(
        events.where((e) => e.control.id == button.id && e.isDown).length,
        buttonDowns,
      );
      await drag.up();
      expect(events[events.length - 2].value, Offset.zero);
    },
  );

  testWidgets(
    'expanded-area tap does not click L3 and outside area passes through',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      await tester.tapAt(const Offset(340, 460));
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        events.where(
          (e) => e.input.kind == OnscreenGamepadInputKind.gamepadButton,
        ),
        isEmpty,
      );
      events.clear();
      await tester.tapAt(const Offset(700, 300));
      expect(events, isEmpty);
    },
  );

  testWidgets('resizing releases a latched toggle after its pointer is up', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final toggled = button.copyWith(
      behavior: OnscreenGamepadControlBehavior.toggle,
    );
    final toggledProfile = profile.copyWith(controls: [toggled]);
    await mount(tester, events, customProfile: toggledProfile);
    await tester.tap(find.byKey(ValueKey(toggled.id)));
    await tester.pump();
    expect(events.single.isDown, isTrue);
    await mount(
      tester,
      events,
      size: const Size(700, 550),
      customProfile: toggledProfile,
    );
    await tester.pump();
    expect(events, hasLength(2));
    expect(events.last.isUp, isTrue);
    await tester.tap(find.byKey(ValueKey(toggled.id)));
    expect(events.last.isDown, isTrue);
  });

  testWidgets('backgrounding releases a latched toggle without a pointer', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    final toggled = button.copyWith(
      behavior: OnscreenGamepadControlBehavior.toggle,
    );
    await mount(
      tester,
      events,
      customProfile: profile.copyWith(controls: [toggled]),
    );
    await tester.tap(find.byKey(ValueKey(toggled.id)));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(events, hasLength(2));
    expect(events.first.isDown, isTrue);
    expect(events.last.isUp, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.byKey(ValueKey(toggled.id)));
    expect(events.last.isDown, isTrue);
  });

  testWidgets(
    'removing an active control releases it and ignores its old pointer',
    (tester) async {
      final events = <OnscreenGamepadEvent>[];
      await mount(tester, events);
      final pointer = await tester.startGesture(const Offset(340, 460));
      await pointer.moveBy(const Offset(20, 0));
      await mount(
        tester,
        events,
        customProfile: profile.copyWith(controls: [button]),
      );
      expect(events[events.length - 2].value, Offset.zero);
      expect(events.last.isUp, isTrue);
      events.clear();
      await pointer.moveBy(const Offset(10, 0));
      await pointer.up();
      expect(tester.takeException(), isNull);
      expect(events, isEmpty);
    },
  );

  testWidgets('unmounting the overlay releases a held button', (tester) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final pointer = await tester.startGesture(
      tester.getCenter(find.byKey(ValueKey(button.id))),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(events, hasLength(2));
    expect(events.first.isDown, isTrue);
    expect(events.last.isUp, isTrue);
    events.clear();
    await pointer.up();
    expect(tester.takeException(), isNull);
    expect(events, isEmpty);
  });

  testWidgets('unmounting ends pending stick button pulses exactly once', (
    tester,
  ) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    await tester.tapAt(tester.getCenter(find.text('LS')));
    await tester.pumpWidget(const SizedBox.shrink());
    final pulses = events
        .where(
          (event) => event.input.kind == OnscreenGamepadInputKind.gamepadButton,
        )
        .toList();
    expect(pulses, hasLength(2));
    expect(pulses.first.isDown, isTrue);
    expect(pulses.last.isUp, isTrue);
    events.clear();
    await tester.pump(const Duration(milliseconds: 40));
    expect(events, isEmpty);
  });

  testWidgets('resize and loss of foreground release movement', (tester) async {
    final events = <OnscreenGamepadEvent>[];
    await mount(tester, events);
    final drag = await tester.startGesture(const Offset(340, 460));
    await drag.moveBy(const Offset(40, 0));
    await tester.pump();
    await mount(tester, events, size: const Size(700, 550));
    await tester.pump();
    expect(events[events.length - 2].value, Offset.zero);
    expect(events.last.isUp, isTrue);
    await drag.up();
    final next = await tester.startGesture(const Offset(320, 430));
    await next.moveBy(const Offset(40, 0));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(events[events.length - 2].value, Offset.zero);
    expect(events.last.isUp, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await next.up();
  });
}
