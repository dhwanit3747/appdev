import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:linux_explorer/main.dart';
import 'package:linux_explorer/providers/theme_provider.dart';

void main() {
  testWidgets('Theme toggles correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Initial state
    expect(find.text('LIGHT'), findsOneWidget);

    // Tap theme toggle button
    await tester.tap(find.byIcon(Icons.brightness_6));
    await tester.pump();

    // After toggle
    expect(find.text('DARK'), findsOneWidget);
  });
}
