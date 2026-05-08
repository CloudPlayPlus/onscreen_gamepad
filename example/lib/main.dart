import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6EA8FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const GamepadDemoPage(),
    );
  }
}

class GamepadDemoPage extends StatefulWidget {
  const GamepadDemoPage({super.key});

  @override
  State<GamepadDemoPage> createState() => _GamepadDemoPageState();
}

class _GamepadDemoPageState extends State<GamepadDemoPage> {
  _DemoDevice _device = _DemoDevice.phone;
  bool _landscape = true;
  bool _showZones = true;
  double _opacity = 0.72;
  Color _defaultColor = const Color(0xFFE7F0FF);
  final Set<String> _activeControlIds = {};
  String _lastEvent = 'Ready';

  Size get _logicalSize {
    final spec = _device.spec;
    return _landscape ? spec.landscapeSize : spec.portraitSize;
  }

  @override
  Widget build(BuildContext context) {
    final profile = kOnscreenGamepadXboxProfile.copyWith(
      defaultColor: _defaultColor,
      opacity: _opacity,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _PreviewStage(
                logicalSize: _logicalSize,
                profile: profile,
                showZones: _showZones,
                activeControlIds: _activeControlIds,
                onControlDown: _handleControlDown,
                onControlUp: _handleControlUp,
                onStickChanged: _handleStickChanged,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: _DemoToolbar(
              device: _device,
              landscape: _landscape,
              showZones: _showZones,
              opacity: _opacity,
              defaultColor: _defaultColor,
              logicalSize: _logicalSize,
              lastEvent: _lastEvent,
              onDeviceChanged: (device) => setState(() => _device = device),
              onLandscapeChanged: (value) => setState(() => _landscape = value),
              onShowZonesChanged: (value) => setState(() => _showZones = value),
              onOpacityChanged: (value) => setState(() => _opacity = value),
              onDefaultColorChanged: (color) =>
                  setState(() => _defaultColor = color),
            ),
          ),
        ],
      ),
    );
  }

  void _handleControlDown(OnscreenGamepadControl control) {
    setState(() {
      _activeControlIds.add(control.id);
      _lastEvent = '${control.label} down';
    });
  }

  void _handleControlUp(OnscreenGamepadControl control) {
    setState(() {
      _activeControlIds.remove(control.id);
      _lastEvent = '${control.label} up';
    });
  }

  void _handleStickChanged(OnscreenGamepadControl control, Offset value) {
    setState(() {
      _lastEvent =
          '${control.label} x=${value.dx.toStringAsFixed(2)} y=${value.dy.toStringAsFixed(2)}';
    });
  }
}

class _PreviewStage extends StatelessWidget {
  const _PreviewStage({
    required this.logicalSize,
    required this.profile,
    required this.showZones,
    required this.activeControlIds,
    required this.onControlDown,
    required this.onControlUp,
    required this.onStickChanged,
  });

  final Size logicalSize;
  final OnscreenGamepadProfile profile;
  final bool showZones;
  final Set<String> activeControlIds;
  final OnscreenGamepadControlEvent onControlDown;
  final OnscreenGamepadControlEvent onControlUp;
  final OnscreenGamepadStickEvent onStickChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = Size(
          math.max(1.0, constraints.maxWidth),
          math.max(1.0, constraints.maxHeight),
        );
        final fitted = _fitInside(logicalSize, available);

        return Center(
          child: SizedBox.fromSize(
            size: fitted,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _alpha(Colors.white, 0.16)),
                boxShadow: [
                  BoxShadow(
                    color: _alpha(Colors.black, 0.42),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _StreamBackdrop(),
                    OnscreenGamepadOverlay(
                      profile: profile,
                      logicalSize: logicalSize,
                      showZones: showZones,
                      activeControlIds: activeControlIds,
                      onControlDown: onControlDown,
                      onControlUp: onControlUp,
                      onStickChanged: onStickChanged,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DemoToolbar extends StatelessWidget {
  const _DemoToolbar({
    required this.device,
    required this.landscape,
    required this.showZones,
    required this.opacity,
    required this.defaultColor,
    required this.logicalSize,
    required this.lastEvent,
    required this.onDeviceChanged,
    required this.onLandscapeChanged,
    required this.onShowZonesChanged,
    required this.onOpacityChanged,
    required this.onDefaultColorChanged,
  });

  final _DemoDevice device;
  final bool landscape;
  final bool showZones;
  final double opacity;
  final Color defaultColor;
  final Size logicalSize;
  final String lastEvent;
  final ValueChanged<_DemoDevice> onDeviceChanged;
  final ValueChanged<bool> onLandscapeChanged;
  final ValueChanged<bool> onShowZonesChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<Color> onDefaultColorChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _ToolbarGroup(
          child: SegmentedButton<_DemoDevice>(
            segments: [
              for (final item in _DemoDevice.values)
                ButtonSegment(
                  value: item,
                  label: Text(item.spec.label),
                  icon: Icon(item.spec.icon),
                ),
            ],
            selected: {device},
            onSelectionChanged: (selected) => onDeviceChanged(selected.single),
            showSelectedIcon: false,
          ),
        ),
        _ToolbarGroup(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.screen_rotation_alt),
                label: Text('Wide'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.stay_current_portrait),
                label: Text('Tall'),
              ),
            ],
            selected: {landscape},
            onSelectionChanged: (selected) =>
                onLandscapeChanged(selected.single),
            showSelectedIcon: false,
          ),
        ),
        _ToolbarGroup(
          child: IconButton(
            tooltip: 'Toggle zones',
            onPressed: () => onShowZonesChanged(!showZones),
            icon: Icon(showZones ? Icons.grid_on : Icons.grid_off),
          ),
        ),
        _ToolbarGroup(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.opacity, size: 20),
              SizedBox(
                width: 120,
                child: Slider(
                  value: opacity,
                  min: 0.35,
                  max: 0.92,
                  onChanged: onOpacityChanged,
                ),
              ),
            ],
          ),
        ),
        _ToolbarGroup(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in _swatches)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ColorButton(
                    color: color,
                    selected: color.toARGB32() == defaultColor.toARGB32(),
                    onTap: () => onDefaultColorChanged(color),
                  ),
                ),
            ],
          ),
        ),
        _ToolbarGroup(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              '${logicalSize.width.round()} x ${logicalSize.height.round()}  |  $lastEvent',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarGroup extends StatelessWidget {
  const _ToolbarGroup({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _alpha(const Color(0xFF151B24), 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _alpha(Colors.white, 0.12)),
      ),
      child: child,
    );
  }
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}',
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Colors.white : _alpha(Colors.white, 0.24),
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamBackdrop extends StatelessWidget {
  const _StreamBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StreamBackdropPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _StreamBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1F2630), Color(0xFF0B0F15)],
        stops: [0, 0.72],
      ).createShader(bounds);
    canvas.drawRect(bounds, base);

    final videoGlowBounds = Rect.fromCircle(
      center: Offset(size.width * 0.50, size.height * 0.48),
      radius: size.longestSide * 0.58,
    );
    final videoGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _alpha(const Color(0xFF314058), 0.92),
          _alpha(const Color(0xFF141A23), 0.88),
        ],
      ).createShader(videoGlowBounds);
    canvas.drawRect(bounds, videoGlow);

    final cornerGlowBounds = Rect.fromCircle(
      center: Offset(size.width * 0.30, size.height * 0.15),
      radius: size.shortestSide * 0.34,
    );
    final cornerGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          _alpha(const Color(0xFF51698B), 0.24),
          _alpha(const Color(0xFF51698B), 0),
        ],
      ).createShader(cornerGlowBounds);
    canvas.drawCircle(
      Offset(size.width * 0.30, size.height * 0.15),
      size.shortestSide * 0.34,
      cornerGlow,
    );

    final gridPaint = Paint()
      ..color = _alpha(Colors.white, 0.032)
      ..strokeWidth = 1;
    const gridSize = 34.0;
    for (var x = 0.0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final edgePaint = Paint()
      ..color = _alpha(Colors.white, 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(bounds.deflate(0.5), edgePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _DemoDevice { phone, foldable, tablet, desktop }

extension on _DemoDevice {
  _DeviceSpec get spec {
    return switch (this) {
      _DemoDevice.phone => const _DeviceSpec(
        label: 'Phone',
        portraitSize: Size(393, 852),
        icon: Icons.smartphone,
      ),
      _DemoDevice.foldable => const _DeviceSpec(
        label: 'Fold',
        portraitSize: Size(600, 960),
        icon: Icons.stay_current_landscape,
      ),
      _DemoDevice.tablet => const _DeviceSpec(
        label: 'Tablet',
        portraitSize: Size(834, 1194),
        icon: Icons.tablet_mac,
      ),
      _DemoDevice.desktop => const _DeviceSpec(
        label: 'Desk',
        portraitSize: Size(800, 1280),
        icon: Icons.personal_video,
      ),
    };
  }
}

class _DeviceSpec {
  const _DeviceSpec({
    required this.label,
    required this.portraitSize,
    required this.icon,
  });

  final String label;
  final Size portraitSize;
  final IconData icon;

  Size get landscapeSize => Size(portraitSize.height, portraitSize.width);
}

const _swatches = [
  Color(0xFFE7F0FF),
  Color(0xFF88E0B5),
  Color(0xFFFFD166),
  Color(0xFFFF7A90),
  Color(0xFFA98BFF),
];

Size _fitInside(Size source, Size bounds) {
  final ratio = source.width / source.height;
  var width = bounds.width;
  var height = width / ratio;
  if (height > bounds.height) {
    height = bounds.height;
    width = height * ratio;
  }
  return Size(width, height);
}

Color _alpha(Color color, double opacity) {
  return color.withAlpha((opacity.clamp(0, 1) * 255).round());
}
