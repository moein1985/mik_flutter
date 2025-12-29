import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hsmik/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSettings uses defaults when no prefs set', () async {
    final cubit = SettingsCubit();
    await cubit.loadSettings();
    expect(cubit.state.localeCode, 'en');
    expect(cubit.state.themeMode, 'system');
    expect(cubit.state.biometricEnabled, false);
  });

  test('setLocale persists and updates state', () async {
    final cubit = SettingsCubit();
    await cubit.setLocale('fa');
    expect(cubit.state.localeCode, 'fa');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('locale'), 'fa');
  });

  test('setThemeMode persists and updates state', () async {
    final cubit = SettingsCubit();
    await cubit.setThemeMode('light');
    expect(cubit.state.themeMode, 'light');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'light');
  });

  test('setBiometricEnabled persists and updates state', () async {
    final cubit = SettingsCubit();
    await cubit.setBiometricEnabled(true);
    expect(cubit.state.biometricEnabled, true);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('biometricEnabled'), true);
  });
}
