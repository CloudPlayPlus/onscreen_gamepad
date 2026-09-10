# onscreen_gamepad

CloudPlayPlus 屏幕手柄插件。插件负责屏幕按钮的布局、绘制、命中测试和触摸语义；CloudPlayPlus 主仓负责 profile 管理、开关入口、云同步、host 绑定，以及把插件事件转成现有串流输入协议。

## 当前能力

- 五区线性布局：`topLeft`、`topRight`、`bottomLeft`、`bottomCenter`、`bottomRight`
- Xbox 默认 profile：摇杆、D-pad、ABXY、LB/LT/RB/RT、View/Menu/Xbox
- 移动摇杆默认开启大范围起手，可关闭区域触发以仅在原命中框起手；其他屏幕按钮和其他摇杆原命中框优先，有效范围外不拦截下方视频触摸
- 摇杆可选择以落点或原布局摇杆位置为中心；落点模式仅显示原半月，原布局中心模式可切换为固定位置的“半月＋触点”提示（左摇杆和 WASD 默认开启、右摇杆关闭），两种半月互斥显示。支持 down/up 和长度不超过 1 的归一化拖动向量
- 统一事件模型：gamepad、keyboard、mouse、custom 输入都走 `OnscreenGamepadEvent`
- profile 支持 compact JSON 往返，便于主仓持久化
- storage-agnostic profile store/controller：主仓可直接接入本地存储、云同步和 host 绑定
- example app 可预览手机、折叠屏、平板和桌面窗口效果

布局公式和默认参数见 [docs/screen_button_layout.md](docs/screen_button_layout.md)。

## CloudPlayPlus 接入边界

插件提供 UI 和输入语义，不直接依赖 CloudPlayPlus 的串流、WebRTC、输入协议或本地存储。

主仓建议按这个边界接入：

| 责任 | 所属 |
| --- | --- |
| 启用开关、drawer 入口、最终保存时机 | CloudPlayPlus |
| profile 本地持久化 / 后续云同步 / host 绑定 | CloudPlayPlus |
| profile store/controller、导入导出模型 | onscreen_gamepad |
| 五区布局、按钮大小、默认 Xbox profile | onscreen_gamepad |
| 触摸命中、按钮 down/up、摇杆向量、统一事件模型 | onscreen_gamepad |
| 把 `OnscreenGamepadInput` / `OnscreenGamepadEvent` 转成远端输入包 | CloudPlayPlus |

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

把 overlay 放在串流视频层上方即可。普通按钮优先命中；移动摇杆默认还接收所在完整半屏的空白区域，设置 `regionTrigger: false` 后仅在原命中框起手。右摇杆可切为 `stickMode: OnscreenGamepadStickMode.camera`，强制半屏鼠标视角转动，本体仅作 R3；`mouseSensitivity` 调整倍率。移动摇杆的 `autoRun` 默认开启，向上推至奔跑提示附近松手锁定，再次触碰解除。所有有效起手范围之外继续落到下层视频。

鼠标倍率默认 10，范围 1–50。视角 R3 使用普通中号圆形按钮基准，所有控件大小倍率下限 25%。普通按键及视角 R3 可用 `buttonPressMode` 选择 `normal`、`toggle`、`longPressToggle` 或 `slideHold`：普通按压、点击锁定、满半秒松手锁定、滑过按钮后一起按住并随抬指释放。长按仅比较事件时间戳；锁定再点释放，失焦/卸载释放全部持有输入。

`buttonIcon`（JSON `ic`）默认 `text`，也可选择 `runWalk`、`jump`、`crouch`、`prone`、`attack`、`parry`、`grapple`、`dart`、`interact`、`medicine`、`menu`、`backpack`、`shoot`、`reload`、`aim`。人物和动作朝左，射击为左上子弹，换弹为缩小子弹配左下/右上弯箭头；防御是盾牌，钩子是左上抓钩，飞镖为四刃，交互为人脸加对话气泡。内置轻量矢量图案继承前景透明度和尺寸，保持原文字名称与绑定。`runWalk` 在实际按住、锁定或滑动持有时显示奔跑，释放时显示行走。

```dart
Stack(
  children: [
    const RemoteVideoView(),
    if (screenGamepadEnabled)
      Positioned.fill(
        child: OnscreenGamepadOverlay(
          profile: activeProfile,
          activeControlIds: pressedIds,
          onEvent: (event) {
            if (event.isDown) {
              pressedIds.add(event.control.id);
            } else if (event.isUp) {
              pressedIds.remove(event.control.id);
            }
            sendInputEvent(event);
          },
        ),
      ),
  ],
)
```

`pressedIds` 推荐由主仓维护，这样网络延迟、页面重建或外部状态变更时，按钮高亮状态仍然是上层的真实状态。

`onControlDown`、`onControlUp` 和 `onStickChanged` 是兼容旧接入的便捷回调。新接入建议优先使用 `onEvent`，这样后续键盘、鼠标、FPS 开火按钮和自定义输入可以走同一条转换链路。

## 核心 API

### `OnscreenGamepadOverlay`

```dart
OnscreenGamepadOverlay({
  required OnscreenGamepadProfile profile,
  OnscreenGamepadLayoutEngine layoutEngine = const OnscreenGamepadLayoutEngine(),
  Size? logicalSize,
  bool showZones = false,
  Set<String> activeControlIds = const {},
  OnscreenGamepadEventCallback? onEvent,
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
- `onEvent`：统一输入事件回调，推荐主仓优先接入。
- `onControlDown` / `onControlUp`：控件实际按下/释放时触发，包括视角 R3；锁定模式在解锁时才 up，滑动连按在最后一个持有者释放时 up，空白处转视角不触发这两个回调。普通摇杆释放时先回零再 up。
- `onStickChanged`：仅摇杆触发，`Offset.dx/dy` 范围是 `-1..1`，屏幕向右/向下为正。

### `OnscreenGamepadProfile`

```dart
const profile = OnscreenGamepadProfile(
  id: 'xbox-default',
  name: 'Xbox Default',
  defaultColor: Color(0xFF000000),
  backgroundOpacity: 0.12,
  foregroundOpacity: 0.48,
  controls: [...],
);
```

字段说明：

- `id`：profile 稳定 id。
- `name`：用户可见名称。
- `defaultColor`：默认按钮颜色；control 未设置颜色时使用它。
- `backgroundOpacity`：按钮底盘不透明度，范围 `0.0..1.0`。
- `foregroundOpacity`：文字、图标和摇杆中心点不透明度，范围 `0.0..1.0`。
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
  behavior: OnscreenGamepadControlBehavior.normal,
  sizeScale: 1,
)
```

CloudPlayPlus 接入时建议：

- 用 `id` 管理编辑、删除、排序和 active state。
- 用 `label` 绘制按钮文字，不把它当输入语义。
- 用 `input` 转远端输入协议。
- 用 `behavior` 描述按钮行为，例如 normal、toggle、fpsFire、wasdStick。
- 保存 `anchor + offset`，不要保存像素坐标。

### `OnscreenGamepadInput`

`input` 是插件和主仓之间的输入合同。

```dart
const OnscreenGamepadInput.gamepadButton('a');
const OnscreenGamepadInput.gamepadButton('a', numericCode: 0x1004);
const OnscreenGamepadInput.gamepadStick(
  code: 'leftStick',
  xAxis: 'leftX',
  yAxis: 'leftY',
  buttonCode: 'leftStickButton',
);
const OnscreenGamepadInput.keyboardKey('Space', numericCode: 32);
const OnscreenGamepadInput.mouseButton(1);
const OnscreenGamepadInput.mouseMove();
const OnscreenGamepadInput.mouseMode('leftClick');
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
    case OnscreenGamepadInputKind.mouseButton:
      mouseSender.sendButton(input.numericCode ?? 1, pressed: pressed);
    case OnscreenGamepadInputKind.mouseMove:
    case OnscreenGamepadInputKind.mouseMode:
      break;
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

### `OnscreenGamepadEvent`

新接入建议从 `onEvent` 转输入协议：

```dart
void sendInputEvent(OnscreenGamepadEvent event) {
  switch (event.type) {
    case OnscreenGamepadEventType.gamepadButton:
      gamepadSender.sendButton(event.input.code, pressed: event.isDown);
    case OnscreenGamepadEventType.gamepadStick:
      final value = event.value;
      if (value != null) {
        gamepadSender.sendAxis(event.input.xAxis!, value.dx);
        gamepadSender.sendAxis(event.input.yAxis!, value.dy);
      } else if (event.input.buttonCode != null) {
        gamepadSender.sendButton(event.input.buttonCode!, pressed: event.isDown);
      }
    case OnscreenGamepadEventType.keyboardKey:
      keyboardSender.sendKey(event.input.numericCode, pressed: event.isDown);
    case OnscreenGamepadEventType.mouseButton:
      mouseSender.sendButton(event.input.numericCode ?? 1, pressed: event.isDown);
    case OnscreenGamepadEventType.mouseMove:
      final delta = event.delta;
      if (delta != null) {
        mouseSender.move(delta.dx, delta.dy);
      }
    case OnscreenGamepadEventType.mouseMode:
    case OnscreenGamepadEventType.custom:
      customInputBus.emit(event.input.code, event);
  }
}
```

### `OnscreenGamepadProfileStore`

插件提供 storage-agnostic 的 profile 管理模型，不直接读写 `SharedPreferences`：

```dart
final controller = OnscreenGamepadProfileController(
  OnscreenGamepadProfileStore(
    activeProfileId: 'default-local',
    profiles: [
      kOnscreenGamepadXboxProfile.copyWith(
        id: 'default-local',
        name: 'Default',
      ),
    ],
  ),
);

controller.addControl(customControl);
controller.updateControl(customControl.copyWith(label: 'Jump'));
controller.removeControl(customControl.id);

final json = controller.store.toJson();
```

主仓可以把 `controller.store.toJson()` 放进本地 storage；二阶段云同步和三阶段 host 绑定时，在外层再包用户、host 或更新时间信息即可。

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

插件也提供 profile store 外层结构：

```json
{
  "v": 1,
  "a": "xbox-default",
  "p": []
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
