import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'onscreen_gamepad_platform_interface.dart';

/// An implementation of [OnscreenGamepadPlatform] that uses method channels.
class MethodChannelOnscreenGamepad extends OnscreenGamepadPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('onscreen_gamepad');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
