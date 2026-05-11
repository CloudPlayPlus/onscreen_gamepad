import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  test('profile store json keeps active profile and profiles', () {
    final store = OnscreenGamepadProfileStore(
      activeProfileId: 'custom',
      profiles: [
        kOnscreenGamepadXboxProfile,
        kOnscreenGamepadXboxProfile.copyWith(
          id: 'custom',
          name: 'Custom',
          opacity: 0.5,
        ),
      ],
    );

    final restored = OnscreenGamepadProfileStore.fromJson(store.toJson());

    expect(restored.version, kOnscreenGamepadProfileStoreVersion);
    expect(restored.activeProfileId, 'custom');
    expect(restored.activeProfile?.name, 'Custom');
    expect(restored.profiles.length, 2);
  });

  test('profile store falls back when active profile is removed', () {
    final store = OnscreenGamepadProfileStore(
      activeProfileId: 'custom',
      profiles: [
        kOnscreenGamepadXboxProfile,
        kOnscreenGamepadXboxProfile.copyWith(id: 'custom', name: 'Custom'),
      ],
    );

    final updated = store.removeProfile('custom');

    expect(updated.activeProfileId, kOnscreenGamepadXboxProfile.id);
    expect(updated.activeProfile?.name, kOnscreenGamepadXboxProfile.name);
  });

  test('profile controller can add update and remove controls', () {
    final controller = OnscreenGamepadProfileController(
      OnscreenGamepadProfileStore(
        activeProfileId: 'empty',
        profiles: [
          const OnscreenGamepadProfile(
            id: 'empty',
            name: 'Empty',
            controls: [],
          ),
        ],
      ),
    );
    const control = OnscreenGamepadControl(
      id: 'jump',
      label: 'Jump',
      anchor: OnscreenGamepadAnchor.bottomRight,
      offset: Offset.zero,
      kind: OnscreenGamepadControlKind.circle,
      role: OnscreenGamepadControlRole.primary,
      sizeTier: OnscreenGamepadSizeTier.medium,
      input: OnscreenGamepadInput.keyboardKey('Space', numericCode: 32),
      behavior: OnscreenGamepadControlBehavior.toggle,
    );

    controller.addControl(control);
    expect(controller.activeProfile?.controls.single.id, 'jump');

    controller.updateControl(control.copyWith(label: 'J'));
    expect(controller.activeProfile?.controls.single.label, 'J');

    controller.removeControl('jump');
    expect(controller.activeProfile?.controls, isEmpty);
  });

  test('extended input and behavior fields survive json roundtrip', () {
    const control = OnscreenGamepadControl(
      id: 'fire',
      label: 'Fire',
      anchor: OnscreenGamepadAnchor.bottomRight,
      offset: Offset(0.2, 0.3),
      kind: OnscreenGamepadControlKind.circle,
      role: OnscreenGamepadControlRole.primary,
      sizeTier: OnscreenGamepadSizeTier.medium,
      input: OnscreenGamepadInput.mouseButton(1),
      behavior: OnscreenGamepadControlBehavior.fpsFire,
      behaviorConfig: {'sensitivity': 1.4, 'threshold': 0.6},
    );

    final restored = OnscreenGamepadControl.fromJson(control.toJson());

    expect(restored.input.kind, OnscreenGamepadInputKind.mouseButton);
    expect(restored.input.numericCode, 1);
    expect(restored.behavior, OnscreenGamepadControlBehavior.fpsFire);
    expect(restored.behaviorConfig['sensitivity'], 1.4);
    expect(restored.behaviorConfig['threshold'], 0.6);
  });
}
