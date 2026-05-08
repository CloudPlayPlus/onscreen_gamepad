import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'onscreen_gamepad_method_channel.dart';

abstract class OnscreenGamepadPlatform extends PlatformInterface {
  /// Constructs a OnscreenGamepadPlatform.
  OnscreenGamepadPlatform() : super(token: _token);

  static final Object _token = Object();

  static OnscreenGamepadPlatform _instance = MethodChannelOnscreenGamepad();

  /// The default instance of [OnscreenGamepadPlatform] to use.
  ///
  /// Defaults to [MethodChannelOnscreenGamepad].
  static OnscreenGamepadPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [OnscreenGamepadPlatform] when
  /// they register themselves.
  static set instance(OnscreenGamepadPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
