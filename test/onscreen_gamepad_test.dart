import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';
import 'package:onscreen_gamepad/onscreen_gamepad_platform_interface.dart';
import 'package:onscreen_gamepad/onscreen_gamepad_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockOnscreenGamepadPlatform
    with MockPlatformInterfaceMixin
    implements OnscreenGamepadPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final OnscreenGamepadPlatform initialPlatform = OnscreenGamepadPlatform.instance;

  test('$MethodChannelOnscreenGamepad is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelOnscreenGamepad>());
  });

  test('getPlatformVersion', () async {
    OnscreenGamepad onscreenGamepadPlugin = OnscreenGamepad();
    MockOnscreenGamepadPlatform fakePlatform = MockOnscreenGamepadPlatform();
    OnscreenGamepadPlatform.instance = fakePlatform;

    expect(await onscreenGamepadPlugin.getPlatformVersion(), '42');
  });
}
