import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  test('all selectable icons have a category and searchable names', () {
    final icons = OnscreenGamepadButtonIcon.values.where(
      (icon) => icon != OnscreenGamepadButtonIcon.text,
    );
    expect(icons.length, 81);
    for (final icon in icons) {
      expect(icon.category, isNotNull, reason: icon.name);
      expect(icon.matches(icon.label), isTrue);
      expect(icon.matches(icon.name), isTrue);
    }
    expect(OnscreenGamepadButtonIcon.dodge.matches('翻滚'), isTrue);
    expect(OnscreenGamepadButtonIcon.heal.matches(' HEAL '), isTrue);
    expect(OnscreenGamepadButtonIcon.heal.matches('换弹'), isFalse);
    expect(
      OnscreenGamepadButtonIcon.staff.category,
      OnscreenGamepadIconCategory.abilities,
    );
    expect(OnscreenGamepadButtonIcon.staff.matches('魔杖'), isTrue);
    expect(OnscreenGamepadButtonIcon.staff.matches('magic staff'), isTrue);
  });

  testWidgets('every icon paints at button size without an empty result', (
    tester,
  ) async {
    for (final icon in OnscreenGamepadButtonIcon.values.where(
      (icon) => icon != OnscreenGamepadButtonIcon.text,
    )) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: OnscreenGamepadButtonSymbol(
              icon: icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
      final painter = tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byType(OnscreenGamepadButtonSymbol),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter!;
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size(24, 24));
      final picture = recorder.endRecording();
      await tester.runAsync(() async {
        final image = await picture.toImage(24, 24);
        final pixels = (await image.toByteData())!.buffer.asUint8List();
        expect(pixels.any((value) => value != 0), isTrue, reason: icon.name);
        if (icon == OnscreenGamepadButtonIcon.repair) {
          // 沿手柄对角轴比较透明度；容忍边缘抗锯齿差异，不冻结整张图。
          var difference = 0;
          for (var y = 0; y < 24; y++) {
            for (var x = 0; x < 24; x++) {
              final alpha = pixels[(y * 24 + x) * 4 + 3];
              final mirrored = pixels[((23 - x) * 24 + 23 - y) * 4 + 3];
              difference += (alpha - mirrored).abs();
            }
          }
          expect(difference / (24 * 24 * 255), lessThan(0.02));
        }
        image.dispose();
      });
      picture.dispose();
      expect(tester.takeException(), isNull, reason: icon.name);
    }
  });
}
