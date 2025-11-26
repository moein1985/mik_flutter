import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'MikroTik Manager'**
  String get appName;

  /// Login button or page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout action
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Host field label
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// Port field label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Remember me checkbox label
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginError;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// Invalid credentials error message
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Interfaces section title
  ///
  /// In en, this message translates to:
  /// **'Interfaces'**
  String get interfaces;

  /// IP Addresses section title
  ///
  /// In en, this message translates to:
  /// **'IP Addresses'**
  String get ipAddresses;

  /// DHCP Server section title
  ///
  /// In en, this message translates to:
  /// **'DHCP Server'**
  String get dhcpServer;

  /// Firewall section title
  ///
  /// In en, this message translates to:
  /// **'Firewall'**
  String get firewall;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// System Resources section title
  ///
  /// In en, this message translates to:
  /// **'System Resources'**
  String get systemResources;

  /// Uptime label
  ///
  /// In en, this message translates to:
  /// **'Uptime'**
  String get uptime;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// CPU label
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get cpu;

  /// Memory label
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  /// Disk label
  ///
  /// In en, this message translates to:
  /// **'Disk'**
  String get disk;

  /// CPU Load label
  ///
  /// In en, this message translates to:
  /// **'CPU Load'**
  String get cpuLoad;

  /// Free Memory label
  ///
  /// In en, this message translates to:
  /// **'Free Memory'**
  String get freeMemory;

  /// Total Memory label
  ///
  /// In en, this message translates to:
  /// **'Total Memory'**
  String get totalMemory;

  /// Free Disk label
  ///
  /// In en, this message translates to:
  /// **'Free Disk'**
  String get freeDisk;

  /// Total Disk label
  ///
  /// In en, this message translates to:
  /// **'Total Disk'**
  String get totalDisk;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Persian language option
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// Change language action
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// Connecting status message
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Loading status message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Type field label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Status field label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Running status
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Network field label
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// Interface field label
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// Comment field label
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information message
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Confirm action
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Please wait message
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
