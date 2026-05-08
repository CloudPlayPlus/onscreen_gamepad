import 'package:flutter_test/flutter_test.dart';

import 'package:onscreen_gamepad_example/main.dart';

void main() {
  testWidgets('renders the onscreen gamepad demo', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Wide'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.textContaining('Ready'), findsOneWidget);
  });

  testWidgets('stick tap and drag emits stick events', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final stick = find.text('LS');
    final gesture = await tester.startGesture(tester.getCenter(stick));
    await tester.pump();

    expect(find.textContaining('LS down'), findsOneWidget);

    await gesture.moveBy(const Offset(24, -18));
    await tester.pump();

    expect(find.textContaining('LS x='), findsOneWidget);

    await gesture.up();
    await tester.pump();

    expect(find.textContaining('LS up'), findsOneWidget);
  });
}
