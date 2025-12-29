import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/l10n/app_localizations.dart';
import 'package:hsmik/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings page shows language dialog', (WidgetTester tester) async {
    // Ensure a clean shared preferences for test isolation
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsPage(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Settings').first, findsOneWidget);

    final languageTile = find.widgetWithIcon(ListTile, Icons.language);
    expect(languageTile, findsOneWidget);

    await tester.tap(languageTile);
    await tester.pumpAndSettle();

    expect(find.text('English'), findsWidgets);
    expect(find.text('Persian'), findsWidgets);

    // Test selecting the second option (Persian)
    await tester.tap(find.byType(SimpleDialogOption).last);
    await tester.pumpAndSettle();

    // After selection we expect the settings subtitle to update to Persian
    expect(find.text('Persian'), findsWidgets);
  });
}
