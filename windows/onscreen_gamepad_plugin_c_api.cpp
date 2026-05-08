#include "include/onscreen_gamepad/onscreen_gamepad_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "onscreen_gamepad_plugin.h"

void OnscreenGamepadPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  onscreen_gamepad::OnscreenGamepadPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
