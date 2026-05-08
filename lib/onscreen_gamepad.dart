import 'onscreen_gamepad_platform_interface.dart';

export 'src/onscreen_gamepad_defaults.dart';
export 'src/onscreen_gamepad_layout.dart';
export 'src/onscreen_gamepad_models.dart';
export 'src/onscreen_gamepad_overlay.dart';

class OnscreenGamepad {
  Future<String?> getPlatformVersion() {
    return OnscreenGamepadPlatform.instance.getPlatformVersion();
  }
}
