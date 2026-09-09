# Screen Button Layout Rules

本文记录当前屏幕按键方案的布局规则、默认参数和 Xbox 默认按键表。目标是让同一套 profile 在手机竖屏、手机横屏、平板和桌面窗口中连续变形，不再按 phone/tablet 或横竖屏做离散断点。

## 设计目标

- 整个屏幕都是布局画布，按键不限制在视频区域内。
- 只有五个 anchor 区域：顶部左手区、顶部右手区、底部左手区、底部中间区、底部右手区。
- 区域随屏幕宽高线性变化，避免窗口轻微缩放时分区跳变。
- 用户移动按钮时保存相对 anchor 的 offset；换设备或旋转后保持“在同一手区里的相对姿态”。
- 按钮默认大小不区分 phone/tablet，只由屏幕最短边连续计算；用户可以在小/中/大三档之外继续用自由缩放微调。
- 触摸命中只落在实际按钮 hit rect 上，按钮之外的 overlay 区域应透传给下方视频或其它手势层。

## 输入坐标

布局算法使用逻辑尺寸 `w`、`h`，单位是 Flutter logical pixel 或 Web demo 中的 dp。渲染缩放只影响最终绘制尺寸，不改变公式本身。

每个按钮保存：

```text
anchor: topLeft | topRight | bottomLeft | bottomCenter | bottomRight
offset.x: 以 anchor 中心为 0，anchor 半宽为 1 的横向偏移
offset.y: 以 anchor 中心为 0，anchor 半高为 1 的纵向偏移
sizeTier: small | medium | large
sizeScale: 用户自由缩放倍率，默认 1.0
color: 可选；未设置时使用 profile.defaultColor
input: 输入语义，例如 gamepadButton(a) 或 gamepadStick(leftX, leftY, leftStickButton)
behavior: 控件行为，例如 normal、toggle、fpsFire、wasdStick
```

Profile 视觉字段：

```text
defaultColor: 底盘默认颜色，当前为 #090E16
backgroundOpacity: 底盘不透明度，0.0..1.0，默认 0.36
foregroundOpacity: 文字、图标和摇杆中心点不透明度，0.0..1.0，默认 0.60
```

按键底盘和摇杆中心点不绘制白色边框。透明度设为 `0` 只隐藏对应视觉层，hit rect 和输入语义保持不变。

按钮中心点：

```text
center.x = anchor.left + anchor.width / 2 + offset.x * anchor.width / 2
center.y = anchor.top + anchor.height / 2 + offset.y * anchor.height / 2
```

最终中心点会按按钮 hit size clamp 到屏幕范围内，避免拖出屏幕后无法再点到。

## 五分区公式

当前默认参数：

```text
bottomBias = 0.04
bottomSlope = 1.20
maxBottomHeight = 6 / 7
topRatio = 0.12
centerRatio = 0.20
gapStartWidth = 393
gapSlope = 0.15
gapMaxWidth = 180
```

中间过程：

```text
wideShare = w / (w + h)
bottomHeight = min(maxBottomHeight, bottomBias + bottomSlope * wideShare)
topHeight = bottomHeight * topRatio
bottomY = 1 - bottomHeight

centerWidthDp = w * centerRatio
gapLimitDp = max(0, (w - centerWidthDp) / 2)
gapWidthDp = min(
  gapMaxWidth,
  gapLimitDp,
  max(0, (w - gapStartWidth) * gapSlope)
)

sideWidthDp = (w - centerWidthDp - gapWidthDp * 2) / 2
```

五个区域的归一化矩形：

```text
topLeft      = (0, 0, 0.5, topHeight)
topRight     = (0.5, 0, 0.5, topHeight)
bottomLeft   = (0, bottomY, sideWidthDp / w, bottomHeight)
bottomCenter = ((sideWidthDp + gapWidthDp) / w, bottomY, centerWidthDp / w, bottomHeight)
bottomRight  = ((sideWidthDp + gapWidthDp + centerWidthDp + gapWidthDp) / w, bottomY, sideWidthDp / w, bottomHeight)
```

这个公式的行为：

- 竖屏窄手机：`gapWidthDp = 0`，底部左/中/右三个区紧贴，避免中间功能键被挤没。
- 普通手机横屏：底部区域占屏幕较大高度，顶部区域高度约为底部区域的 12%。
- 宽屏平板/桌面：底部左区和中间区之间、底部中间区和右区之间的 gap 随绝对宽度增加，最大到 `180dp`。
- 极宽低屏：`bottomHeight` 被 `6/7` 截断，顶部区域下边界与底部区域上边界接近或重合，垂直方向不额外留空。

## 按钮大小公式

默认三档：

| tier | ratio | min | max | 用途 |
| --- | ---: | ---: | ---: | --- |
| small | 0.11 | 36 | 66 | D-pad、View/Menu/Xbox |
| medium | 0.14 | 40 | 86 | ABXY、LB/LT/RB/RT |
| large | 0.23 | 72 | 154 | 左右摇杆 |

命中尺寸：

```text
shortSide = min(w, h)
wideScale = 0.88 + 0.18 * wideShare
base = clamp(shortSide * tier.ratio * wideScale, tier.min, tier.max)
hitSize = round(base * clamp(sizeScale, 0.8, 1.5))
visualSize = round(hitSize * 0.82)
```

`hitSize` 用于触摸，`visualSize` 用于绘制。这样视觉上不会过于臃肿，同时保留触摸容错。

## Xbox 默认布局

| id | label | anchor | offset | tier | scale |
| --- | --- | --- | --- | --- | ---: |
| left-stick | LS | bottomLeft | `(-0.20, 0.42)` | large | 1.00 |
| right-stick | RS | bottomRight | `(-0.35, 0.46)` | large | 0.90 |
| dpad-up | DU | bottomLeft | `(0.20, -0.56)` | small | 0.90 |
| dpad-left | DL | bottomLeft | `(-0.15, -0.24)` | small | 0.90 |
| dpad-right | DR | bottomLeft | `(0.55, -0.24)` | small | 0.90 |
| dpad-down | DD | bottomLeft | `(0.20, 0.09)` | small | 0.90 |
| x | X | bottomRight | `(0.00, -0.42)` | medium | 1.00 |
| y | Y | bottomRight | `(0.36, -0.68)` | medium | 1.00 |
| a | A | bottomRight | `(0.36, -0.16)` | medium | 1.00 |
| b | B | bottomRight | `(0.72, -0.42)` | medium | 1.00 |
| lb | LB | bottomLeft | `(-0.38, -0.98)` | medium | 1.00 |
| lt | LT | bottomLeft | `(0.08, -0.98)` | medium | 1.00 |
| rb | RB | bottomRight | `(-0.08, -0.98)` | medium | 1.00 |
| rt | RT | bottomRight | `(0.38, -0.98)` | medium | 1.00 |
| view | View | bottomCenter | `(-0.40, -0.40)` | small | 0.85 |
| menu | Menu | bottomCenter | `(0.40, -0.40)` | small | 0.85 |
| xbox | Xbox | bottomCenter | `(0.00, 0.18)` | small | 0.90 |

## 后续扩展

- 二阶段再做云同步：profile 结构应保持精简，避免存储像素坐标。
- 三阶段再做 host 绑定：同一用户可为不同 host 使用不同 profile。
- 暂不支持连发，但 `control.id` 和按键事件接口需要保留扩展空间。
- 堆叠逼近算法暂不进入当前方案；当前版本只保证命中层按按钮 hit rect 精准响应，空白区域透传。
- 插件层提供 `OnscreenGamepadProfileStore` 和 `OnscreenGamepadProfileController` 作为 profile CRUD 基础；实际持久化、云同步和 host 绑定仍由 CloudPlayPlus 主仓决定。
- 输入事件优先走统一 `OnscreenGamepadEvent`：按钮、摇杆、键盘、鼠标和 custom 事件都在这一层收敛，再由主仓转换成串流输入协议。

## 触摸语义

- 普通按钮：pointer down 触发按键 down，pointer up/cancel 触发按键 up。
- Toggle 按钮：每次 pointer down 在 down/up 两个状态间切换，pointer up 只结束本次触摸，不自动释放远端按键。
- FPS 开火按钮：按住时先输出按钮 down，随后手指移动会按 delta 输出 `mouseMove` 事件，松开时输出按钮 up。
- 摇杆按钮：pointer down 也触发 `LS/RS down`；如果用户继续拖动，则按 pointer 相对摇杆 hit rect 中心的位置输出 `(-1..1, -1..1)` 的归一化向量；pointer up/cancel 时先回零，再触发 `LS/RS up`。
- 摇杆不额外扩大 overlay 命中层，只有自己的 hit rect 捕获触摸；hit rect 外仍然透传给视频。

CloudPlayPlus 接入时建议只依赖 `control.input`，不要依赖 label。`id` 用于 profile 编辑和 active state，`label` 只用于显示。
