import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onscreen_gamepad/onscreen_gamepad.dart';

void main() {
  test('all selectable icons have a category and searchable names', () {
    final icons = OnscreenGamepadButtonIcon.values.where(
      (icon) => icon != OnscreenGamepadButtonIcon.text,
    );
    expect(icons.length, 80);
    for (final icon in icons) {
      expect(icon.category, isNotNull, reason: icon.name);
      expect(icon.matches(icon.label), isTrue);
      expect(icon.matches(icon.name), isTrue);
    }
    expect(OnscreenGamepadButtonIcon.dodge.matches('翻滚'), isTrue);
    expect(OnscreenGamepadButtonIcon.heal.matches(' HEAL '), isTrue);
    expect(OnscreenGamepadButtonIcon.heal.matches('换弹'), isFalse);
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
        image.dispose();
      });
      picture.dispose();
      expect(tester.takeException(), isNull, reason: icon.name);
    }
  });
}
