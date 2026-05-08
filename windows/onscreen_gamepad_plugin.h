#ifndef FLUTTER_PLUGIN_ONSCREEN_GAMEPAD_PLUGIN_H_
#define FLUTTER_PLUGIN_ONSCREEN_GAMEPAD_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace onscreen_gamepad {

class OnscreenGamepadPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  OnscreenGamepadPlugin();

  virtual ~OnscreenGamepadPlugin();

  // Disallow copy and assign.
  OnscreenGamepadPlugin(const OnscreenGamepadPlugin&) = delete;
  OnscreenGamepadPlugin& operator=(const OnscreenGamepadPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace onscreen_gamepad

#endif  // FLUTTER_PLUGIN_ONSCREEN_GAMEPAD_PLUGIN_H_
