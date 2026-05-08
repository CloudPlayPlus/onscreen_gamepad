
import 'onscreen_gamepad_platform_interface.dart';

class OnscreenGamepad {
  Future<String?> getPlatformVersion() {
    return OnscreenGamepadPlatform.instance.getPlatformVersion();
  }
}
