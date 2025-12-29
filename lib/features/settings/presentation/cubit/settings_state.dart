part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String localeCode; // 'en' or 'fa'
  final String themeMode; // 'light' | 'dark' | 'system'
  final bool biometricEnabled;

  const SettingsState({
    this.localeCode = 'en',
    this.themeMode = 'system',
    this.biometricEnabled = false,
  });

  SettingsState copyWith({String? localeCode, String? themeMode, bool? biometricEnabled}) {
    return SettingsState(
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  @override
  List<Object?> get props => [localeCode, themeMode, biometricEnabled];
}
