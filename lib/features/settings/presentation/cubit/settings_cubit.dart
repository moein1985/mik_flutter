import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _kLocaleKey = 'locale';
  static const _kThemeKey = 'themeMode';
  static const _kBiometric = 'biometricEnabled';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString(_kLocaleKey) ?? 'en';
    final theme = prefs.getString(_kThemeKey) ?? 'system';
    final biometric = prefs.getBool(_kBiometric) ?? false;

    emit(state.copyWith(localeCode: locale, themeMode: theme, biometricEnabled: biometric));
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, code);
    emit(state.copyWith(localeCode: code));
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometric, enabled);
    emit(state.copyWith(biometricEnabled: enabled));
  }
}
