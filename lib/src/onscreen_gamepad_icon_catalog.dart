// GENERATED CODE — 请勿直接编辑。
// 来源：cloudplayplus/docs/prototypes/screen_buttons_rules/icons-draft.js
// 更新：node tool/sync_onscreen_icons.cjs <onscreen_gamepad 仓库路径>

enum OnscreenGamepadIconCategory {
  movement('移动姿态'),
  combat('近战武器'),
  shooting('枪械射击'),
  abilities('技能法术'),
  interaction('物品交互'),
  vehicle('载具操作'),
  system('系统沟通'),
  input('键鼠手柄');

  const OnscreenGamepadIconCategory(this.label);
  final String label;
}

enum OnscreenGamepadButtonIcon {
  text('文字', null, ''),
  runWalk(
    '行走 / 奔跑',
    OnscreenGamepadIconCategory.movement,
    '移动 走路 跑步 冲刺 walk run sprint',
  ),
  jump('跳跃', OnscreenGamepadIconCategory.movement, '跳远 起跳 jump'),
  crouch('下蹲', OnscreenGamepadIconCategory.movement, '蹲伏 蹲下 crouch'),
  prone('趴下', OnscreenGamepadIconCategory.movement, '卧倒 匍匐 prone'),
  dodge('闪避', OnscreenGamepadIconCategory.movement, '翻滚 躲避 dash roll dodge'),
  grapple('钩子', OnscreenGamepadIconCategory.movement, '钩爪 勾爪 绳索 grapple'),
  climb('攀爬', OnscreenGamepadIconCategory.movement, '爬梯 climbing ladder'),
  swim('游泳', OnscreenGamepadIconCategory.movement, '下水 swimming'),
  glide('滑翔', OnscreenGamepadIconCategory.movement, '跳伞 降落伞 glide parachute'),
  slide('滑铲', OnscreenGamepadIconCategory.movement, '滑行 铲地 slide'),
  attack(
    '攻击',
    OnscreenGamepadIconCategory.combat,
    '近战 普攻 砍 slash sword attack',
  ),
  parry('防御', OnscreenGamepadIconCategory.combat, '格挡 招架 block guard parry'),
  heavyAttack('重击', OnscreenGamepadIconCategory.combat, '蓄力 hammer heavy'),
  kick('踢击', OnscreenGamepadIconCategory.combat, '踢腿 kick'),
  counter('反击', OnscreenGamepadIconCategory.combat, '反制 弹反 counter'),
  lockOn('锁定', OnscreenGamepadIconCategory.combat, '锁敌 target lock'),
  bow('弓箭', OnscreenGamepadIconCategory.combat, '射箭 弓弩 bow arrow'),
  axe('战斧', OnscreenGamepadIconCategory.combat, '斧头 axe'),
  dualBlade('双刃', OnscreenGamepadIconCategory.combat, '双持 匕首 dual blade'),
  dart('飞镖', OnscreenGamepadIconCategory.combat, '手里剑 暗器 dart shuriken'),
  shoot('射击', OnscreenGamepadIconCategory.shooting, '开火 子弹 fire shoot'),
  reload('换弹', OnscreenGamepadIconCategory.shooting, '装填 reload'),
  aim('瞄准', OnscreenGamepadIconCategory.shooting, '开镜 aim ads'),
  grenade('投掷物', OnscreenGamepadIconCategory.shooting, '投弹 榴弹 grenade throw'),
  weaponSwap('切换武器', OnscreenGamepadIconCategory.shooting, '切枪 换枪 weapon swap'),
  pistol('手枪', OnscreenGamepadIconCategory.shooting, '副武器 pistol'),
  rifle('步枪', OnscreenGamepadIconCategory.shooting, '主武器 rifle'),
  scope('瞄准镜', OnscreenGamepadIconCategory.shooting, '狙击 倍镜 zoom scope'),
  burst('连发', OnscreenGamepadIconCategory.shooting, '点射 连射 burst auto'),
  safety('保险', OnscreenGamepadIconCategory.shooting, '安全锁 停火 safety'),
  skill('技能', OnscreenGamepadIconCategory.abilities, '雷电 电击 lightning skill'),
  staff('法杖', OnscreenGamepadIconCategory.abilities, '法师 魔杖 magic staff wand'),
  fire('火焰', OnscreenGamepadIconCategory.abilities, '燃烧 火球 flame fireball'),
  ice('冰霜', OnscreenGamepadIconCategory.abilities, '冻结 冰冻 ice frost'),
  wind('风', OnscreenGamepadIconCategory.abilities, '风刃 wind'),
  water('水', OnscreenGamepadIconCategory.abilities, '水系 water'),
  heal('治疗', OnscreenGamepadIconCategory.abilities, '回血 恢复 heal health'),
  magicShield(
    '护盾',
    OnscreenGamepadIconCategory.abilities,
    '防护 结界 barrier shield',
  ),
  summon('召唤', OnscreenGamepadIconCategory.abilities, '分身 summon'),
  teleport('传送', OnscreenGamepadIconCategory.abilities, '瞬移 闪现 blink teleport'),
  invisibility(
    '隐身',
    OnscreenGamepadIconCategory.abilities,
    '潜行 消失 stealth invisible',
  ),
  interact('交互', OnscreenGamepadIconCategory.interaction, '使用 互动 npc interact'),
  medicine(
    '药品',
    OnscreenGamepadIconCategory.interaction,
    '药水 喝药 potion medicine',
  ),
  backpack(
    '背包',
    OnscreenGamepadIconCategory.interaction,
    '包裹 仓库 bag inventory',
  ),
  pickup('拾取', OnscreenGamepadIconCategory.interaction, '捡取 拿取 搜刮 loot pickup'),
  door('开门', OnscreenGamepadIconCategory.interaction, '进门 出门 door'),
  key('钥匙', OnscreenGamepadIconCategory.interaction, '开锁 key unlock'),
  chest('宝箱', OnscreenGamepadIconCategory.interaction, '开箱 chest box'),
  food('进食', OnscreenGamepadIconCategory.interaction, '食物 吃饭 饱食 food eat'),
  drink('饮水', OnscreenGamepadIconCategory.interaction, '喝水 口渴 drink'),
  build('建造', OnscreenGamepadIconCategory.interaction, '建筑 盖房 build house'),
  repair('修理', OnscreenGamepadIconCategory.interaction, '维修 工具 repair wrench'),
  craft('制作', OnscreenGamepadIconCategory.interaction, '合成 锻造 crafting forge'),
  steering('驾驶', OnscreenGamepadIconCategory.vehicle, '转向 开车 drive steering'),
  accelerate(
    '加速',
    OnscreenGamepadIconCategory.vehicle,
    '油门 氮气 加力 boost accelerate',
  ),
  brake('刹车', OnscreenGamepadIconCategory.vehicle, '手刹 制动 brake'),
  enterVehicle(
    '上下车',
    OnscreenGamepadIconCategory.vehicle,
    '乘坐 下车 enter vehicle',
  ),
  horn('喇叭', OnscreenGamepadIconCategory.vehicle, '鸣笛 horn'),
  ascend('上升', OnscreenGamepadIconCategory.vehicle, '起飞 爬升 ascend up'),
  descend('下降', OnscreenGamepadIconCategory.vehicle, '降落 下潜 descend down'),
  anchor('停泊', OnscreenGamepadIconCategory.vehicle, '抛锚 船舶 anchor'),
  map('地图', OnscreenGamepadIconCategory.system, '大地图 minimap map'),
  menu('菜单', OnscreenGamepadIconCategory.system, '布局 menu layout'),
  pause('暂停', OnscreenGamepadIconCategory.system, '停止 pause'),
  settings('设置', OnscreenGamepadIconCategory.system, '选项 配置 settings options'),
  quest('任务', OnscreenGamepadIconCategory.system, '日志 日志本 quest journal'),
  marker('标记', OnscreenGamepadIconCategory.system, '定位 信号 ping marker'),
  mic('语音', OnscreenGamepadIconCategory.system, '说话 通话 mic voice'),
  chat('聊天', OnscreenGamepadIconCategory.system, '消息 通讯 chat message'),
  camera('拍照', OnscreenGamepadIconCategory.system, '截图 摄影 photo camera'),
  compass('指南针', OnscreenGamepadIconCategory.system, '导航 朝向 compass'),
  mouseLeft('鼠标左键', OnscreenGamepadIconCategory.input, '左击 左键 lmb mouse left'),
  mouseRight(
    '鼠标右键',
    OnscreenGamepadIconCategory.input,
    '右击 右键 rmb mouse right',
  ),
  mouseMiddle(
    '鼠标中键',
    OnscreenGamepadIconCategory.input,
    '中击 中键 mmb mouse middle',
  ),
  scrollUp('滚轮上滚', OnscreenGamepadIconCategory.input, '滚动 wheel scroll up'),
  scrollDown('滚轮下滚', OnscreenGamepadIconCategory.input, '滚动 wheel scroll down'),
  keyboard('键盘', OnscreenGamepadIconCategory.input, '输入 keyboard key'),
  gamepad('手柄', OnscreenGamepadIconCategory.input, '控制器 controller gamepad'),
  dpad('方向键', OnscreenGamepadIconCategory.input, '方向 十字 dpad'),
  stick('摇杆', OnscreenGamepadIconCategory.input, '左摇杆 右摇杆 joystick stick'),
  trigger(
    '扳机',
    OnscreenGamepadIconCategory.input,
    '肩键 lt rt lb rb l1 r1 l2 r2 trigger',
  );

  const OnscreenGamepadButtonIcon(
    this.label,
    this.category,
    this.searchAliases,
  );
  final String label;
  final OnscreenGamepadIconCategory? category;
  final String searchAliases;

  bool matches(String query) {
    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final haystack = '$label $name $searchAliases'.toLowerCase();
    return terms.every(haystack.contains);
  }
}
