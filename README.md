# onscreen_gamepad

CloudPlayPlus 屏幕手柄插件。插件负责屏幕按钮的布局、绘制、命中测试和触摸语义；CloudPlayPlus 主仓负责 profile 管理、开关入口、云同步、host 绑定，以及把插件事件转成现有串流输入协议。

## 当前能力

- 五区线性布局：`topLeft`、`topRight`、`bottomLeft`、`bottomCenter`、`bottomRight`
- Xbox 默认 profile：摇杆、D-pad、ABXY、LB/LT/RB/RT、View/Menu/Xbox
- 只命中真实按钮区域，overlay 空白区域不拦截下方视频触摸
- 摇杆支持 down/up 和 `(-1..1, -1..1)` 归一化拖动向量
- profile 支持 compact JSON 往返，便于主仓持久化
- example app 可预览手机、折叠屏、平板和桌面窗口效果

布局公式和默认参数见 [docs/screen_button_layout.md](docs/screen_button_layout.md)。

## CloudPlayPlus 接入边界

插件提供 UI 和输入语义，不直接依赖 CloudPlayPlus 的串流、WebRTC、输入协议或本地存储。

主仓建议按这个边界接入：

| 责任 | 所属 |
| --- | --- |
| profile CRUD、启用开关、drawer 入口 | CloudPlayPlus |
| profile 本地持久化 / 后续云同步 / host 绑定 | CloudPlayPlus |
| 五区布局、按钮大小、默认 Xbox profile | onscreen_gamepad |
| 触摸命中、按钮 down/up、摇杆向量 | onscreen_gamepad |
| 把 `OnscreenGamepadInput` 转成远端输入包 | CloudPlayPlus |

## 安装

主仓用 path dependency：

```yaml
dependencies:
  onscreen_gamepad:
    path: ../onscreen_gamepad
```

然后：

```dart
import 'package:onscreen_gamepad/onscreen_gamepad.dart';
```

## 最小接入

把 overlay 放在串流视频层上方即可。`OnscreenGamepadOverlay` 自身是透明 hit test 结构，只有每个按钮的 hit rect 会接收 pointer，空白处会继续落到下层视频。

```dart
Stack(
  children: [
    const RemoteVideoView(),
    if (screenGamepadEnabled)
      Positioned.fill(
        child: OnscreenGamepadOverlay(
          profile: activeProfile,
          activeControlIds: pressedIds,
          onControlDown: (control) {
            pressedIds.add(control.id);
            sendButton(control.input, pressed: true);
          },
          onControlUp: (control) {
            pressedIds.remove(control.id);
            sendButton(control.input, pressed: false);
          },
          onStickChanged: (control, value) {
            sendStick(control.input, value);
          },
        ),
      ),
  ],
)
```

`pressedIds` 推荐由主仓维护，这样网络延迟、页面重建或外部状态变更时，按钮高亮状态仍然是上层的真实状态。

## 核心 API

### `OnscreenGamepadOverlay`

```dart
OnscreenGamepadOverlay({
  required OnscreenGamepadProfile profile,
  OnscreenGamepadLayoutEngine layoutEngine = const OnscreenGamepadLayoutEngine(),
  Size? logicalSize,
  bool showZones = false,
  Set<String> activeControlIds = const {},
  OnscreenGamepadControlEvent? onControlDown,
  OnscreenGamepadControlEvent? onControlUp,
  OnscreenGamepadStickEvent? onStickChanged,
})
```

- `profile`：当前启用的按钮配置。
- `layoutEngine`：布局引擎；默认使用当前调好的五区线性参数。
- `logicalSize`：可选逻辑尺寸。通常不传，直接用当前 widget 尺寸；demo 用它模拟不同设备。
- `showZones`：调试用，显示五个 anchor 区域。
- `activeControlIds`：外部受控高亮状态。
- `onControlDown`：所有控件 pointer down 都会触发，包括摇杆。
- `onControlUp`：pointer up/cancel 触发。摇杆会先发送回零，再触发 up。
- `onStickChanged`：仅摇杆触发，`Offset.dx/dy` 范围是 `-1..1`，屏幕向右/向下为正。

### `OnscreenGamepadProfile`

```dart
const profile = OnscreenGamepadProfile(
  id: 'xbox-default',
  name: 'Xbox Default',
  defaultColor: Color(0xFFE7F0FF),
  opacity: 0.72,
  controls: [...],
);
```

字段说明：

- `id`：profile 稳定 id。
- `name`：用户可见名称。
- `defaultColor`：默认按钮颜色；control 未设置颜色时使用它。
- `opacity`：按钮整体透明度。
- `controls`：按钮列表。

### `OnscreenGamepadControl`

```dart
const OnscreenGamepadControl(
  id: 'a',
  label: 'A',
  anchor: OnscreenGamepadAnchor.bottomRight,
  offset: Offset(0.36, -0.16),
  kind: OnscreenGamepadControlKind.circle,
  role: OnscreenGamepadControlRole.primary,
  sizeTier: OnscreenGamepadSizeTier.medium,
  input: OnscreenGamepadInput.gamepadButton('a'),
  sizeScale: 1,
)
```

CloudPlayPlus 接入时建议：

- 用 `id` 管理编辑、删除、排序和 active state。
- 用 `label` 绘制按钮文字，不把它当输入语义。
- 用 `input` 转远端输入协议。
- 保存 `anchor + offset`，不要保存像素坐标。

### `OnscreenGamepadInput`

`input` 是插件和主仓之间的输入合同。

```dart
const OnscreenGamepadInput.gamepadButton('a');
const OnscreenGamepadInput.gamepadStick(
  code: 'leftStick',
  xAxis: 'leftX',
  yAxis: 'leftY',
);
const OnscreenGamepadInput.keyboardKey('Space');
const OnscreenGamepadInput.custom('macro.openMenu');
```

主仓可以这样转换：

```dart
void sendButton(OnscreenGamepadInput input, {required bool pressed}) {
  switch (input.kind) {
    case OnscreenGamepadInputKind.gamepadButton:
      gamepadSender.sendButton(input.code, pressed: pressed);
    case OnscreenGamepadInputKind.keyboardKey:
      keyboardSender.sendKey(input.code, pressed: pressed);
    case OnscreenGamepadInputKind.custom:
      customInputBus.emit(input.code, pressed: pressed);
    case OnscreenGamepadInputKind.gamepadStick:
      break;
  }
}

void sendStick(OnscreenGamepadInput input, Offset value) {
  if (input.kind != OnscreenGamepadInputKind.gamepadStick) {
    return;
  }
  gamepadSender.sendAxis(input.xAxis!, value.dx);
  gamepadSender.sendAxis(input.yAxis!, value.dy);
}
```

## 存储格式

插件模型提供 JSON 往返：

```dart
final encoded = activeProfile.toJson();
final decoded = OnscreenGamepadProfile.fromJson(encoded);
```

JSON 使用短 key，适合主仓存在本地 storage 后续再同步：

```json
{
  "id": "xbox-default",
  "n": "Xbox Default",
  "dc": 4293382399,
  "op": 0.72,
  "b": [
    {
      "id": "a",
      "l": "A",
      "a": "bottomRight",
      "o": { "x": 0.36, "y": -0.16 },
      "k": "circle",
      "r": "primary",
      "s": "medium",
      "in": { "k": "gamepadButton", "c": "a" }
    }
  ]
}
```

推荐主仓外层再包一层版本号，例如：

```json
{
  "version": 1,
  "activeProfileId": "xbox-default",
  "profiles": []
}
```

## 默认 Profile

插件导出 `kOnscreenGamepadXboxProfile`。主仓首次启用时可以直接复制它作为用户默认 profile：

```dart
final profile = kOnscreenGamepadXboxProfile.copyWith(
  id: 'default-local',
  name: 'Default',
);
```

后续编辑时建议 clone control 列表，而不是直接修改 const 默认对象。

## Demo

```sh
cd example
flutter run -d chrome
```

也可以构建静态 web 版本：

```sh
cd example
flutter build web --release
python3 -m http.server 8124 --directory build/web
```

## 性能建议

- 串流页不要开启 `showZones`。
- 主仓只在 profile、屏幕尺寸或启用状态变化时触发布局变化。
- 摇杆拖动时只处理 `onStickChanged`，不要让整个串流页重建。
- 如果低端设备有压力，主仓可以对摇杆事件按帧或按变化阈值限频。
