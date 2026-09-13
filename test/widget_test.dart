import 'package:flutter_test/flutter_test.dart';
import 'package:smart_water_usage_app/main.dart';

void main() {
  testWidgets('SmartWaterApp launches with Guest Mode by default', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartWaterApp());

    // Verify Guest Mode branding and tracker UI elements appear
    expect(find.text('SMART WATER'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
  });
}
