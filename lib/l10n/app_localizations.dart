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

  /// HotSpot menu title
  ///
  /// In en, this message translates to:
  /// **'HotSpot'**
  String get hotspot;

  /// HotSpot users page title
  ///
  /// In en, this message translates to:
  /// **'HotSpot Users'**
  String get hotspotUsers;

  /// Active HotSpot users
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get hotspotActiveUsers;

  /// HotSpot servers page title
  ///
  /// In en, this message translates to:
  /// **'HotSpot Servers'**
  String get hotspotServers;

  /// HotSpot profiles page title
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get hotspotProfiles;

  /// Add user button
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// Disconnect action
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Bytes received label
  ///
  /// In en, this message translates to:
  /// **'Bytes In'**
  String get bytesIn;

  /// Bytes sent label
  ///
  /// In en, this message translates to:
  /// **'Bytes Out'**
  String get bytesOut;

  /// Packets received label
  ///
  /// In en, this message translates to:
  /// **'Packets In'**
  String get packetsIn;

  /// Packets sent label
  ///
  /// In en, this message translates to:
  /// **'Packets Out'**
  String get packetsOut;

  /// MAC address label
  ///
  /// In en, this message translates to:
  /// **'MAC Address'**
  String get macAddress;

  /// Login method label
  ///
  /// In en, this message translates to:
  /// **'Login By'**
  String get loginBy;

  /// Session time label
  ///
  /// In en, this message translates to:
  /// **'Session Time'**
  String get sessionTime;

  /// Idle time label
  ///
  /// In en, this message translates to:
  /// **'Idle Time'**
  String get idleTime;

  /// Address pool label
  ///
  /// In en, this message translates to:
  /// **'Address Pool'**
  String get addressPool;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Server label
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// Session timeout label
  ///
  /// In en, this message translates to:
  /// **'Session Timeout'**
  String get sessionTimeout;

  /// Idle timeout label
  ///
  /// In en, this message translates to:
  /// **'Idle Timeout'**
  String get idleTimeout;

  /// Shared users label
  ///
  /// In en, this message translates to:
  /// **'Shared Users'**
  String get sharedUsers;

  /// Rate limit label
  ///
  /// In en, this message translates to:
  /// **'Rate Limit'**
  String get rateLimit;

  /// Status accounting label
  ///
  /// In en, this message translates to:
  /// **'Status Accounting'**
  String get statusAccounting;

  /// Transparent proxy label
  ///
  /// In en, this message translates to:
  /// **'Transparent Proxy'**
  String get transparentProxy;

  /// Certificates menu title
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificates;

  /// Local CA tab title
  ///
  /// In en, this message translates to:
  /// **'Local CA'**
  String get localCA;

  /// Let's Encrypt tab title
  ///
  /// In en, this message translates to:
  /// **'Let\'s Encrypt'**
  String get letsEncrypt;

  /// Let's Encrypt certificate is active
  ///
  /// In en, this message translates to:
  /// **'Certificate Active'**
  String get letsEncryptCertificateActive;

  /// No Let's Encrypt certificate found
  ///
  /// In en, this message translates to:
  /// **'No Certificate'**
  String get letsEncryptNoCertificate;

  /// Certificate issued success message
  ///
  /// In en, this message translates to:
  /// **'Certificate issued successfully!'**
  String get letsEncryptCertificateIssued;

  /// Success description after certificate is issued
  ///
  /// In en, this message translates to:
  /// **'Your Let\'s Encrypt certificate has been issued and configured. You can now use HTTPS with your router.'**
  String get letsEncryptSuccessDescription;

  /// Button to view certificate details
  ///
  /// In en, this message translates to:
  /// **'View Certificate'**
  String get viewCertificate;

  /// Auto-fix success message
  ///
  /// In en, this message translates to:
  /// **'Issue fixed successfully'**
  String get letsEncryptAutoFixSuccess;

  /// Auto-fixing in progress
  ///
  /// In en, this message translates to:
  /// **'Fixing issue...'**
  String get letsEncryptAutoFixing;

  /// Requesting certificate in progress
  ///
  /// In en, this message translates to:
  /// **'Requesting Certificate...'**
  String get letsEncryptRequesting;

  /// Info shown during certificate request
  ///
  /// In en, this message translates to:
  /// **'This may take 1-2 minutes. The router needs to verify domain ownership via port 80.'**
  String get letsEncryptRequestingInfo;

  /// Certificate name label
  ///
  /// In en, this message translates to:
  /// **'Certificate Name'**
  String get letsEncryptCertName;

  /// Certificate expiry date label
  ///
  /// In en, this message translates to:
  /// **'Expires At'**
  String get letsEncryptExpiresAt;

  /// Days until certificate expiry
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get letsEncryptDaysRemaining;

  /// Warning for expiring certificate
  ///
  /// In en, this message translates to:
  /// **'Certificate is expiring soon. Consider renewing.'**
  String get letsEncryptExpiringSoon;

  /// Revoke/delete certificate button
  ///
  /// In en, this message translates to:
  /// **'Delete Certificate'**
  String get letsEncryptRevoke;

  /// Renew certificate button
  ///
  /// In en, this message translates to:
  /// **'Renew Certificate'**
  String get letsEncryptRenew;

  /// Get certificate button
  ///
  /// In en, this message translates to:
  /// **'Get Free SSL Certificate'**
  String get letsEncryptGetCertificate;

  /// Info section title
  ///
  /// In en, this message translates to:
  /// **'About Let\'s Encrypt'**
  String get letsEncryptInfo;

  /// Info about Let's Encrypt
  ///
  /// In en, this message translates to:
  /// **'Let\'s Encrypt provides free SSL certificates that are trusted by all browsers. Certificates are valid for 90 days and can be renewed automatically.'**
  String get letsEncryptInfoText;

  /// Pre-checks title
  ///
  /// In en, this message translates to:
  /// **'Pre-flight Checks'**
  String get letsEncryptPreChecks;

  /// Pre-checks description
  ///
  /// In en, this message translates to:
  /// **'Before requesting a certificate, we need to verify your router meets all requirements.'**
  String get letsEncryptPreChecksDesc;

  /// DNS name label
  ///
  /// In en, this message translates to:
  /// **'Your DNS Name'**
  String get letsEncryptDnsName;

  /// Request certificate button
  ///
  /// In en, this message translates to:
  /// **'Request Certificate'**
  String get letsEncryptRequestNow;

  /// Fix all issues button
  ///
  /// In en, this message translates to:
  /// **'Fix All Issues'**
  String get letsEncryptAutoFixAll;

  /// Re-check requirements button
  ///
  /// In en, this message translates to:
  /// **'Re-check'**
  String get letsEncryptRecheck;

  /// Fix single issue button
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get letsEncryptFix;

  /// Cloud DDNS check
  ///
  /// In en, this message translates to:
  /// **'Cloud DDNS Enabled'**
  String get letsEncryptCheckCloud;

  /// DNS name check
  ///
  /// In en, this message translates to:
  /// **'DNS Name Available'**
  String get letsEncryptCheckDns;

  /// Port 80 check
  ///
  /// In en, this message translates to:
  /// **'Port 80 Accessible'**
  String get letsEncryptCheckPort80;

  /// Firewall check
  ///
  /// In en, this message translates to:
  /// **'Firewall Allows Port 80'**
  String get letsEncryptCheckFirewall;

  /// NAT check
  ///
  /// In en, this message translates to:
  /// **'No NAT Redirect on Port 80'**
  String get letsEncryptCheckNat;

  /// WWW service check
  ///
  /// In en, this message translates to:
  /// **'WWW Service Not on Port 80'**
  String get letsEncryptCheckWww;

  /// Loading status message
  ///
  /// In en, this message translates to:
  /// **'Loading certificate status...'**
  String get letsEncryptLoadingStatus;

  /// Running pre-checks message
  ///
  /// In en, this message translates to:
  /// **'Running pre-flight checks...'**
  String get letsEncryptRunningPreChecks;

  /// Cloud not enabled error
  ///
  /// In en, this message translates to:
  /// **'Cloud DDNS is not enabled. Enable it to get a DNS name.'**
  String get letsEncryptErrorCloudNotEnabled;

  /// DNS not available error
  ///
  /// In en, this message translates to:
  /// **'DNS name not available yet. Wait for MikroTik Cloud to assign one.'**
  String get letsEncryptErrorDnsNotAvailable;

  /// Port 80 blocked error
  ///
  /// In en, this message translates to:
  /// **'Port 80 is blocked. It must be accessible from the internet.'**
  String get letsEncryptErrorPort80Blocked;

  /// Error when www service is not on port 80
  ///
  /// In en, this message translates to:
  /// **'WWW service must be enabled on port 80 for Let\'s Encrypt to work.'**
  String get letsEncryptErrorWwwNotOnPort80;

  /// Error when www service check fails
  ///
  /// In en, this message translates to:
  /// **'Could not check WWW service status.'**
  String get letsEncryptErrorWwwCheckFailed;

  /// Error when router cannot connect to ACME server
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to Let\'s Encrypt servers. This may be due to internet restrictions or sanctions in your region. Try using a VPN on your router.'**
  String get letsEncryptErrorAcmeConnectionFailed;

  /// Error when DNS resolution fails
  ///
  /// In en, this message translates to:
  /// **'Cannot resolve Let\'s Encrypt server address. Check your router\'s DNS settings.'**
  String get letsEncryptErrorAcmeDnsResolutionFailed;

  /// Generic SSL update failure
  ///
  /// In en, this message translates to:
  /// **'Failed to obtain SSL certificate. The router could not complete the Let\'s Encrypt verification process.'**
  String get letsEncryptErrorAcmeSslUpdateFailed;

  /// Rate limit error
  ///
  /// In en, this message translates to:
  /// **'Too many certificate requests. Let\'s Encrypt has rate limits. Please wait a few hours and try again.'**
  String get letsEncryptErrorAcmeRateLimited;

  /// Authorization/verification failure
  ///
  /// In en, this message translates to:
  /// **'Domain verification failed. Make sure port 80 is accessible from the internet and your domain points to this router.'**
  String get letsEncryptErrorAcmeAuthorizationFailed;

  /// Challenge validation error
  ///
  /// In en, this message translates to:
  /// **'Challenge validation failed. Let\'s Encrypt could not verify your domain ownership. Ensure port 80 is forwarded correctly.'**
  String get letsEncryptErrorAcmeChallengeValidationFailed;

  /// Timeout error
  ///
  /// In en, this message translates to:
  /// **'Connection to Let\'s Encrypt timed out. Check your internet connection and try again.'**
  String get letsEncryptErrorAcmeTimeout;

  /// Generic ACME error with details
  ///
  /// In en, this message translates to:
  /// **'Let\'s Encrypt error: {error}'**
  String letsEncryptErrorAcmeGeneric(String error);

  /// NAT rule error
  ///
  /// In en, this message translates to:
  /// **'A NAT rule is redirecting port 80. Disable it temporarily.'**
  String get letsEncryptErrorNatRule;

  /// Load failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to load certificate status'**
  String get letsEncryptErrorLoadFailed;

  /// Pre-checks failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to run pre-flight checks'**
  String get letsEncryptErrorPreChecksFailed;

  /// Auto-fix failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to fix the issue automatically'**
  String get letsEncryptErrorAutoFixFailed;

  /// Request failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to request certificate. Check port 80 accessibility.'**
  String get letsEncryptErrorRequestFailed;

  /// Revoke failed error
  ///
  /// In en, this message translates to:
  /// **'Failed to delete certificate'**
  String get letsEncryptErrorRevokeFailed;

  /// Revoke dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Certificate?'**
  String get letsEncryptRevokeTitle;

  /// Revoke dialog description
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Let\'s Encrypt certificate?'**
  String get letsEncryptRevokeDesc;

  /// Revoke warning message
  ///
  /// In en, this message translates to:
  /// **'Services using this certificate will stop working until a new certificate is issued.'**
  String get letsEncryptRevokeWarning;
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
