import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_water_usage_app/main.dart';

void main() {
  testWidgets('SmartWaterApp launches with Guest Mode by default', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SmartWaterApp());

    // Verify Guest Mode branding and tracker UI elements appear
    expect(find.text('SMART WATER'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Usage Statistics'), findsNothing);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Profile'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Daily Consumption Target'), findsOneWidget);
    expect(find.text('Alert Preferences'), findsOneWidget);
    expect(find.text('Daily target alert'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('goal-alert-setting')));
    await tester.pump();
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Notifications & Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsNWidgets(2));

    await tester.tap(find.text('Notifications & Alerts'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Daily usage summary'), findsOneWidget);
    expect(find.text('You’re within your daily target'), findsNothing);
  });
}
