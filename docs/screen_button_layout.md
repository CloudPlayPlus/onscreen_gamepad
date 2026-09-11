# Screen Button Layout Rules

本文记录当前屏幕按键方案的布局规则、默认参数和 Xbox 默认按键表。目标是让同一套 profile 在手机竖屏、手机横屏、平板和桌面窗口中连续变形，不再按 phone/tablet 或横竖屏做离散断点。

## 设计目标

- 整个屏幕都是布局画布，按键不限制在视频区域内。
- 只有五个 anchor 区域：顶部左手区、顶部右手区、底部左手区、底部中间区、底部右手区。
- 区域随屏幕宽高线性变化，避免窗口轻微缩放时分区跳变。
- 用户移动按钮时保存相对 anchor 的 offset；换设备或旋转后保持“在同一手区里的相对姿态”。
- 按钮默认大小不区分 phone/tablet，只由屏幕最短边连续计算；用户可以在小/中/大三档之外继续用自由缩放微调。
- 普通按钮与关闭半屏触发的移动摇杆只在原 hit rect 起手；开启半屏触发的移动摇杆、视角模式的右摇杆还接收所在完整半屏空白处。所有有效起手范围之外的触摸透传给下方视频或其它手势层，命中优先级见“摇杆触摸与半月反馈”。

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
defaultColor: 底盘默认颜色，当前为 #000000
backgroundOpacity: 底盘不透明度，0.0..1.0，默认 0.12
foregroundOpacity: 文字、图标和摇杆中心点不透明度，0.0..1.0，默认 0.48
```

文字、图标和摇杆中心点统一为白色，以比底盘更高的不透明度保持清晰，不随底色亮度自动切换为深色。按键底盘和摇杆中心点不绘制白色边框或边缘阴影。透明度设为 `0` 只隐藏对应视觉层，hit rect 和输入语义保持不变。

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
hitSize = round(base * clamp(sizeScale, 0.25, 1.5))
visualSize = round(hitSize * 0.82)
```

`hitSize` 用于触摸，`visualSize` 用于绘制。这样视觉上不会过于臃肿，同时保留触摸容错。

视角模式的 R3 使用普通 `medium` 圆形按钮的基准尺寸和样式，继续应用用户倍率；切回摇杆恢复摇杆基准尺寸。缩放下限 25%，小按钮文字按可用尺寸缩小。

普通键盘/鼠标/手柄按钮及视角 R3 支持 `buttonPressMode`（JSON `pm`）：`normal` 普通、`toggle` 点击锁定、`longPressToggle` 长按锁定、`slideHold` 滑动连按。前两种分别是按住/松开和再点释放；长按锁定在松手时比较事件时间戳，达到 500 ms 保持按住，否则正常点按，已锁定后再点释放，不使用定时器。滑动连按从该键起手，经过其他普通按钮原框时一起按住，抬指统一释放，其他指针或锁定仍持有的键不提前释放。锁定和滑动持有保持高亮，取消、后台、卸载和配置改变释放输入。

## 摇杆触摸与半月反馈

普通按键与视角 R3 支持文字或内置 `buttonIcon` 图案（JSON `ic`）：除 `text` 外有 80 个矢量图标，分为移动姿态、近战武器、枪械射击、技能法术、物品交互、载具操作、系统沟通、键鼠手柄八类。宿主可用 `icon.category`、`icon.label` 和 `icon.matches(query)` 提供分类及中英文名称/别名搜索；布局仍只保存稳定枚举名，不保存分类或搜索状态。人物和动作朝左，不绘制脚掌/脚尖；奔跑/行走跟随实际按键持有状态。图案使用相同前景透明度，占按钮视觉直径的 62%；标签和输入绑定保持独立，选择图案不修改输入语义。网页设计源和 Canvas 生成方式见 [README](../README.md#最小接入)，不引入运行时 SVG 或位图依赖。

原半月与额外半月峰值不透明度为 `min(1, foregroundOpacity + 0.12)`，默认 60%，随文字与图标不透明度增加 12 个百分点并限制在 100% 以内，前端亮、根部渐隐。

- 移动摇杆（左摇杆或 WASD）的“半屏触发”默认开启，将起手区域扩大到所在完整半屏，同时保留原有命中框；关闭后仅原命中框可起手，成功起手后仍可拖出范围。所有原按钮命中框优先于扩大区域。
- 半屏触发与中心模式独立，按控件保存为 `rt`（缺省 `true`，显式 `false` 保留）。普通右摇杆不扩大范围；右摇杆视角模式强制半屏触发。手势中切换开关或模式会释放旧输入，需再次按下。
- 右摇杆 `stickMode`（`sm`）可选默认 `joystick` 或 `camera`。后者只在半屏空白处按相邻触点差输出鼠标相对移动，按下不跳变、不输出摇杆向量；`mouseSensitivity`（`ms`）默认 10，范围 1–50。原摇杆本体始终作为 R3 按钮显示，按住/松开发 R3 down/up，拖动本体不转视角。R3 和区域视角可由两指同时操作；切后台、隐藏、卸载和配置变更释放 R3 并取消旧手势。
- 左摇杆 `autoRun`（`ar`）默认开启。上推方向在垂直向上 ±30° 时，半月上方出现奔跑图标与箭头；图标中心距半月中心为半径加 100 dp。松手时满力度且提示触点距图标中心不超过 30 dp 才锁定；原中心额外半月模式使用相对半月显示的小点判定，其他情况使用实际触点，取消事件不锁定。
- 自动奔跑保持向前满力度 `(0, -1)`，不额外发冲刺键，提示回到原摇杆底盘。再次触碰有效起手范围、关闭开关、切换模式、隐藏、卸载、旋转或切后台解除并归零。
- 同侧多个移动摇杆的原命中框优先于其他摇杆的扩大区域；原框互相重叠或空白扩大区域重叠仍沿用堆叠顺序，起手后的指针归属不变。
- 半屏触发只命中所在半屏与原命中框的并集。原框跨中线时，另一侧仅原框本身可命中，外接矩形额外包含的空白条带仍透传。
- `stickCenterMode`（JSON `cm`）支持 `touchDown` 和 `fixed`：前者默认，以本次落点为零；后者以原布局摇杆中心为零，落下即输出实际相对偏移。1 dp 死区外线性增加，移动 40 dp 达到满力度。继续拖远不会改变中心，输出向量长度不超过 1。切换模式取消在途手势；复制、改绑、重载保留选择。
- 按下隐藏原底盘和中心圆；按下位置为中心模式仅显示原半月，不提供额外提示选项；原摇杆中心模式开启额外提示时仅显示额外半月和触点，关闭时显示原半月。原半月行为：离开死区后在所选模式的中心显示填充半月，直径为原底盘视觉尺寸的 68%。尖端朝向输入方向并最亮，向直线根部渐隐。半月仅旋转，不平移或膨胀，不提供关闭开关。
- `OnscreenGamepadControl.positionFeedback` 为原摇杆中心模式的额外位置提示可选布尔值；`positionFeedbackEnabled` 返回有效值，未设置时默认左摇杆和 WASD 开启、右摇杆关闭。开关继续存为控件 JSON 的 `af`，复制和改绑保留显式选择。
- `positionFeedbackLocation` 为可选归一化屏幕坐标，存为 `fp`，由编辑器拖动更新。未设置时从原摇杆中心向屏幕中间平移 0.9 倍底盘尺寸、向上 1.4 倍，边界保留半月半径加 8 dp。`OnscreenGamepadPlacedControl.positionFeedbackCenter` 为绘制和编辑器共用的定位规则。串流中提示不拦截触摸。
- 额外提示为“半月＋小点”：半月中心固定在屏幕上的配置位置，只随方向旋转；小点中心 = 提示中心 + 实际触点 - 本次摇杆中心，显示原始相对位移。额外半月与原半月同尺寸同方向，小点直径 6 dp、带深色边框。半月中心不随落点或力度移动，满力度后小点仍跟随拖动。提示仅在原摇杆中心模式生效且与原半月互斥，不改变输入；死区内与松手时均隐藏反馈，不显示圆弧、箭头或数字。
- pointer 独占一次手势，多指可同时移动与按键；抬手、取消、应用失去前台或尺寸变化均归零。
- 原摇杆命中框内的轻点保留 L3/R3 语义；扩大区域内的轻点按所选中心模式处理摇杆输入，不触发 L3。

## Xbox 默认控件

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
- 堆叠逼近算法暂不进入当前方案；当前版本按原 hit rect 和可选的摇杆扩大区域命中，范围外透传。
- 插件层提供 `OnscreenGamepadProfileStore` 和 `OnscreenGamepadProfileController` 作为 profile CRUD 基础；实际持久化、云同步和 host 绑定仍由 CloudPlayPlus 主仓决定。
- 输入事件优先走统一 `OnscreenGamepadEvent`：按钮、摇杆、键盘、鼠标和 custom 事件都在这一层收敛，再由主仓转换成串流输入协议。

## 触摸语义

- 普通按钮：pointer down 触发按键 down，pointer up/cancel 触发按键 up。
- Toggle 按钮：每次 pointer down 在 down/up 两个状态间切换，pointer up 只结束本次触摸，不自动释放远端按键。
- FPS 开火按钮：按住时先输出按钮 down，随后手指移动会按 delta 输出 `mouseMove` 事件，松开时输出按钮 up。
- 摇杆按钮：pointer down 触发控件 down，并按 `stickCenterMode` 建立本次中心。默认 `touchDown` 在落点归零，`fixed` 立即按原布局中心计算偏移；拖动输出长度不超过 1 的向量，pointer up/cancel 时回零并触发控件 up。原命中框内的轻点另发 L3/R3 短按脉冲。
- 移动摇杆的区域触发默认开启，可关闭以仅在原 hit rect 起手；成功起手后可拖出范围。普通按钮和其他摇杆原命中框优先于扩大区域，未命中任何有效起手范围的触摸透传给视频。

CloudPlayPlus 接入时建议只依赖 `control.input`，不要依赖 label。`id` 用于 profile 编辑和 active state，`label` 只用于显示。
