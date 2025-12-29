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
  /// **'Network Assistant'**
  String get appName;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Active status label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

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

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

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

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Interfaces section title
  ///
  /// In en, this message translates to:
  /// **'Interfaces'**
  String get interfacesSection;

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

  /// Biometric section title
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuthentication;

  /// Enable biometric authentication label
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Authentication'**
  String get enableBiometricAuth;

  /// Description for biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face recognition to sign in'**
  String get biometricAuthDescription;

  /// Biometric coming soon message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication coming soon'**
  String get biometricComingSoon;

  /// General 'coming soon' message
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Description for profile list item
  ///
  /// In en, this message translates to:
  /// **'View and edit account information'**
  String get profileDescription;

  /// Profile coming soon message
  ///
  /// In en, this message translates to:
  /// **'Profile page coming soon'**
  String get profileComingSoon;

  /// Change password label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Change password coming soon message
  ///
  /// In en, this message translates to:
  /// **'Change password coming soon'**
  String get changePasswordComingSoon;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About this app title
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutApp;

  /// Description for About dialog
  ///
  /// In en, this message translates to:
  /// **'Network Assistant\nPowerful tool for managing MikroTik and SNMP'**
  String get aboutAppDescription;

  /// Change theme action
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// SnackBar message when profile is saved
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// Password changed success message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to change password'**
  String get mustBeLoggedIn;

  /// Validation message for empty name
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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

  /// Domain section title
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get letsEncryptDomainSection;

  /// Technical prerequisites section title
  ///
  /// In en, this message translates to:
  /// **'Technical Prerequisites'**
  String get letsEncryptTechnicalPrereqs;

  /// All prerequisites met indicator
  ///
  /// In en, this message translates to:
  /// **'All ready'**
  String get letsEncryptAllPrereqsMet;

  /// Number of prerequisite issues
  ///
  /// In en, this message translates to:
  /// **'{count} issue(s)'**
  String letsEncryptPrereqsIssues(int count);

  /// Show details button
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get letsEncryptShowDetails;

  /// Hide details button
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get letsEncryptHideDetails;

  /// Radio option for Cloud DDNS
  ///
  /// In en, this message translates to:
  /// **'Use Cloud DDNS (Recommended)'**
  String get letsEncryptUseCloudDdns;

  /// Radio option for custom domain
  ///
  /// In en, this message translates to:
  /// **'Use Custom Domain'**
  String get letsEncryptUseCustomDomain;

  /// Cloud DDNS description
  ///
  /// In en, this message translates to:
  /// **'Free MikroTik domain - automatically configured'**
  String get letsEncryptCloudDdnsDesc;

  /// Custom domain description
  ///
  /// In en, this message translates to:
  /// **'A domain you have registered yourself'**
  String get letsEncryptCustomDomainDesc;

  /// Enable Cloud DDNS button
  ///
  /// In en, this message translates to:
  /// **'Enable Cloud DDNS'**
  String get letsEncryptEnableCloudDdns;

  /// Cloud DDNS enabling message
  ///
  /// In en, this message translates to:
  /// **'Enabling...'**
  String get letsEncryptCloudDdnsEnabling;

  /// Waiting for Cloud DDNS to assign name
  ///
  /// In en, this message translates to:
  /// **'Waiting for DNS name assignment...'**
  String get letsEncryptCloudDdnsWaiting;

  /// Cloud not supported title
  ///
  /// In en, this message translates to:
  /// **'Cloud DDNS Not Available'**
  String get letsEncryptCloudNotSupportedTitle;

  /// Cloud not supported message
  ///
  /// In en, this message translates to:
  /// **'Your router is an x86/CHR (virtual) type and Cloud DDNS service is not supported on these routers.'**
  String get letsEncryptCloudNotSupportedMessage;

  /// Reassurance message
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! You can use a free domain.'**
  String get letsEncryptDontWorry;

  /// Custom domain required title
  ///
  /// In en, this message translates to:
  /// **'Custom Domain (Required)'**
  String get letsEncryptCustomDomainRequired;

  /// Domain must point to IP message
  ///
  /// In en, this message translates to:
  /// **'This domain must point to your router\'s public IP:'**
  String get letsEncryptDomainMustPointTo;

  /// Your IP label
  ///
  /// In en, this message translates to:
  /// **'Your IP'**
  String get letsEncryptYourIp;

  /// No free domain question
  ///
  /// In en, this message translates to:
  /// **'Don\'t have a free domain?'**
  String get letsEncryptNoFreeDomain;

  /// Free domain providers intro
  ///
  /// In en, this message translates to:
  /// **'Get one free from these services:'**
  String get letsEncryptFreeDomainProviders;

  /// DuckDNS description
  ///
  /// In en, this message translates to:
  /// **'DuckDNS.org (Simple & Fast)'**
  String get letsEncryptDuckDnsSimple;

  /// Video guide button
  ///
  /// In en, this message translates to:
  /// **'Video Guide'**
  String get letsEncryptVideoGuide;

  /// Domain input placeholder
  ///
  /// In en, this message translates to:
  /// **'example.duckdns.org'**
  String get letsEncryptDomainPlaceholder;

  /// Main action button
  ///
  /// In en, this message translates to:
  /// **'Get Free SSL Certificate'**
  String get letsEncryptGetFreeSslCertificate;

  /// Disabled button message when no domain
  ///
  /// In en, this message translates to:
  /// **'Enter domain to continue'**
  String get letsEncryptEnterDomainToContinue;

  /// Disabled button message when issues exist
  ///
  /// In en, this message translates to:
  /// **'Fix issues first'**
  String get letsEncryptFixIssuesFirst;

  /// Auto fix button
  ///
  /// In en, this message translates to:
  /// **'Auto Fix'**
  String get letsEncryptAutoFix;

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

  /// Title when MikroTik Cloud is not supported
  ///
  /// In en, this message translates to:
  /// **'Cloud DDNS Not Supported'**
  String get letsEncryptCloudNotSupported;

  /// Description when Cloud is not supported
  ///
  /// In en, this message translates to:
  /// **'MikroTik Cloud services are not available on x86/CHR (virtual) routers. You must use a custom domain (e.g., from DuckDNS) that points to your router\'s public IP.'**
  String get letsEncryptCloudNotSupportedDesc;

  /// DNS name text field label
  ///
  /// In en, this message translates to:
  /// **'DNS Name / Domain'**
  String get letsEncryptDnsNameLabel;

  /// Helper text when Cloud DNS is available
  ///
  /// In en, this message translates to:
  /// **'Auto-filled from Cloud DDNS (you can change it)'**
  String get letsEncryptDnsNameHelperCloud;

  /// Helper text when no Cloud DNS
  ///
  /// In en, this message translates to:
  /// **'Enter your domain name pointing to this router'**
  String get letsEncryptDnsNameHelperCustom;

  /// Helper text when Cloud not supported
  ///
  /// In en, this message translates to:
  /// **'Required: Enter a domain that points to your router\'s IP'**
  String get letsEncryptDnsNameHelperRequired;

  /// Warning when domain is required but not entered
  ///
  /// In en, this message translates to:
  /// **'You must enter a domain name to continue'**
  String get letsEncryptDomainRequired;

  /// Button text when domain not entered
  ///
  /// In en, this message translates to:
  /// **'Enter Domain Name First'**
  String get letsEncryptEnterDomainFirst;

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

  /// Network Tools page title
  ///
  /// In en, this message translates to:
  /// **'Network Tools'**
  String get networkTools;

  /// Diagnostic tools section title
  ///
  /// In en, this message translates to:
  /// **'Network Diagnostic Tools'**
  String get diagnosticTools;

  /// Tools description
  ///
  /// In en, this message translates to:
  /// **'Test connectivity and resolve network issues'**
  String get testConnectivity;

  /// Tools info dialog title
  ///
  /// In en, this message translates to:
  /// **'Real-time Network Tools'**
  String get toolsInfoTitle;

  /// Tools info dialog description
  ///
  /// In en, this message translates to:
  /// **'All diagnostic tools display results in real-time as they are received from the router.'**
  String get toolsInfoDescription;

  /// Ping info text
  ///
  /// In en, this message translates to:
  /// **'Ping: Real-time packet transmission display'**
  String get pingInfoText;

  /// Traceroute info text
  ///
  /// In en, this message translates to:
  /// **'Traceroute: Step-by-step network path display'**
  String get tracerouteInfoText;

  /// DNS Lookup info text
  ///
  /// In en, this message translates to:
  /// **'DNS Lookup: Fast IP address resolution'**
  String get dnsLookupInfoText;

  /// Stop button text
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopPing;

  /// Stop traceroute button text
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTraceroute;

  /// Ping tool name
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get ping;

  /// Ping test dialog title
  ///
  /// In en, this message translates to:
  /// **'Ping Test'**
  String get pingTest;

  /// Ping tool description
  ///
  /// In en, this message translates to:
  /// **'Test connectivity to a host'**
  String get pingConnectivity;

  /// Traceroute tool name
  ///
  /// In en, this message translates to:
  /// **'Traceroute'**
  String get traceroute;

  /// Traceroute test dialog title
  ///
  /// In en, this message translates to:
  /// **'Traceroute Test'**
  String get tracerouteTest;

  /// Traceroute tool description
  ///
  /// In en, this message translates to:
  /// **'Trace network path to a host'**
  String get tracePath;

  /// DNS lookup tool name
  ///
  /// In en, this message translates to:
  /// **'DNS Lookup'**
  String get dnsLookup;

  /// DNS lookup dialog title
  ///
  /// In en, this message translates to:
  /// **'DNS Lookup'**
  String get dnsLookupTitle;

  /// DNS lookup tool description
  ///
  /// In en, this message translates to:
  /// **'Resolve domain names to IP addresses'**
  String get resolveDomains;

  /// Clear results action
  ///
  /// In en, this message translates to:
  /// **'Clear Results'**
  String get clearResults;

  /// Clear results description
  ///
  /// In en, this message translates to:
  /// **'Clear all diagnostic results'**
  String get clearAllResults;

  /// Target host input label
  ///
  /// In en, this message translates to:
  /// **'Target IP Address'**
  String get targetHost;

  /// Ping packet count label
  ///
  /// In en, this message translates to:
  /// **'Packet Count'**
  String get packetCount;

  /// Timeout input label
  ///
  /// In en, this message translates to:
  /// **'Timeout (ms)'**
  String get timeoutMs;

  /// Traceroute max hops label
  ///
  /// In en, this message translates to:
  /// **'Max Hops'**
  String get maxHops;

  /// Domain name input label
  ///
  /// In en, this message translates to:
  /// **'Domain Name'**
  String get domainName;

  /// Start ping button
  ///
  /// In en, this message translates to:
  /// **'Start Ping'**
  String get startPing;

  /// Start traceroute button
  ///
  /// In en, this message translates to:
  /// **'Start Traceroute'**
  String get startTraceroute;

  /// DNS lookup button
  ///
  /// In en, this message translates to:
  /// **'Lookup DNS'**
  String get lookupDns;

  /// DNS lookup in progress message
  ///
  /// In en, this message translates to:
  /// **'Looking up...'**
  String get lookingUp;

  /// Validation message when domain name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter a domain name'**
  String get pleaseEnterDomainName;

  /// DNS record type dropdown label
  ///
  /// In en, this message translates to:
  /// **'Record Type'**
  String get recordType;

  /// Custom DNS server input label
  ///
  /// In en, this message translates to:
  /// **'DNS Server'**
  String get dnsServer;

  /// Helper text for DNS server field
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use router\'s DNS'**
  String get dnsServerHelper;

  /// Help text explaining DNS server field
  ///
  /// In en, this message translates to:
  /// **'Specify a custom DNS server to query (e.g., 8.8.8.8 for Google DNS, 1.1.1.1 for Cloudflare). Leave empty to use the router\'s configured DNS servers.'**
  String get dnsServerHelpText;

  /// Help text explaining DNS lookup feature
  ///
  /// In en, this message translates to:
  /// **'DNS Lookup resolves domain names to IP addresses. Select a record type to query specific DNS records like A (IPv4), AAAA (IPv6), MX (mail servers), or TXT records.'**
  String get dnsLookupHelpText;

  /// Help text explaining timeout field
  ///
  /// In en, this message translates to:
  /// **'Maximum time to wait for a response from the DNS server. Increase if you\'re experiencing timeout errors.'**
  String get timeoutHelpText;

  /// DNS records section title
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// Title for DNS record types help dialog
  ///
  /// In en, this message translates to:
  /// **'DNS Record Types'**
  String get recordTypeHelp;

  /// Description of A record type
  ///
  /// In en, this message translates to:
  /// **'Returns the IPv4 address of a domain. Most common record type for website lookups.'**
  String get recordTypeADesc;

  /// Description of AAAA record type
  ///
  /// In en, this message translates to:
  /// **'Returns the IPv6 address of a domain. Used for modern IPv6 networks.'**
  String get recordTypeAAAADesc;

  /// Ping results section title
  ///
  /// In en, this message translates to:
  /// **'Ping Results'**
  String get pingResults;

  /// Traceroute results section title
  ///
  /// In en, this message translates to:
  /// **'Traceroute Results'**
  String get tracerouteResults;

  /// DNS lookup results section title
  ///
  /// In en, this message translates to:
  /// **'DNS Lookup Results'**
  String get dnsResults;

  /// Packets sent label
  ///
  /// In en, this message translates to:
  /// **'Packets sent'**
  String get packetsSent;

  /// Packets received label
  ///
  /// In en, this message translates to:
  /// **'Packets received'**
  String get packetsReceived;

  /// Packet loss label
  ///
  /// In en, this message translates to:
  /// **'Packet Loss'**
  String get packetLoss;

  /// Round trip time label
  ///
  /// In en, this message translates to:
  /// **'RTT'**
  String get rtt;

  /// IPv4 addresses label
  ///
  /// In en, this message translates to:
  /// **'IPv4 Addresses'**
  String get ipv4Addresses;

  /// IPv6 addresses label
  ///
  /// In en, this message translates to:
  /// **'IPv6 Addresses'**
  String get ipv6Addresses;

  /// Response time label
  ///
  /// In en, this message translates to:
  /// **'Response Time'**
  String get responseTime;

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Queues page title
  ///
  /// In en, this message translates to:
  /// **'Queues'**
  String get queues;

  /// Simple queues section title
  ///
  /// In en, this message translates to:
  /// **'Simple Queues'**
  String get simpleQueues;

  /// Queue management description
  ///
  /// In en, this message translates to:
  /// **'Manage bandwidth queues and traffic shaping'**
  String get queueManagement;

  /// Add queue button text
  ///
  /// In en, this message translates to:
  /// **'Add Queue'**
  String get addQueue;

  /// Queue name field label
  ///
  /// In en, this message translates to:
  /// **'Queue Name'**
  String get queueName;

  /// Target field label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// Max limit field label
  ///
  /// In en, this message translates to:
  /// **'Max Limit'**
  String get maxLimit;

  /// Burst limit field label
  ///
  /// In en, this message translates to:
  /// **'Burst Limit'**
  String get burstLimit;

  /// Burst threshold field label
  ///
  /// In en, this message translates to:
  /// **'Burst Threshold'**
  String get burstThreshold;

  /// Burst time field label
  ///
  /// In en, this message translates to:
  /// **'Burst Time'**
  String get burstTime;

  /// Priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Parent field label
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// Advanced settings section title
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// Limit at field label
  ///
  /// In en, this message translates to:
  /// **'Limit At'**
  String get limitAt;

  /// Queue type field label
  ///
  /// In en, this message translates to:
  /// **'Queue Type'**
  String get queueType;

  /// Total queue limit field label
  ///
  /// In en, this message translates to:
  /// **'Total Queue Limit'**
  String get totalQueueLimit;

  /// Total max limit field label
  ///
  /// In en, this message translates to:
  /// **'Total Max Limit'**
  String get totalMaxLimit;

  /// Total burst limit field label
  ///
  /// In en, this message translates to:
  /// **'Total Burst Limit'**
  String get totalBurstLimit;

  /// Total burst threshold field label
  ///
  /// In en, this message translates to:
  /// **'Total Burst Threshold'**
  String get totalBurstThreshold;

  /// Total burst time field label
  ///
  /// In en, this message translates to:
  /// **'Total Burst Time'**
  String get totalBurstTime;

  /// Total limit at field label
  ///
  /// In en, this message translates to:
  /// **'Total Limit At'**
  String get totalLimitAt;

  /// Bucket size field label
  ///
  /// In en, this message translates to:
  /// **'Bucket Size'**
  String get bucketSize;

  /// Save queue button text
  ///
  /// In en, this message translates to:
  /// **'Save Queue'**
  String get saveQueue;

  /// Delete queue button text
  ///
  /// In en, this message translates to:
  /// **'Delete Queue'**
  String get deleteQueue;

  /// Delete queue confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this queue?'**
  String get deleteQueueConfirm;

  /// Toggle queue button text
  ///
  /// In en, this message translates to:
  /// **'Toggle Queue'**
  String get toggleQueue;

  /// Queue enabled status message
  ///
  /// In en, this message translates to:
  /// **'Queue enabled'**
  String get queueEnabled;

  /// Queue disabled status message
  ///
  /// In en, this message translates to:
  /// **'Queue disabled'**
  String get queueDisabled;

  /// Loading queues message
  ///
  /// In en, this message translates to:
  /// **'Loading queues...'**
  String get loadingQueues;

  /// No queues found message
  ///
  /// In en, this message translates to:
  /// **'No queues found'**
  String get noQueues;

  /// Queue added success message
  ///
  /// In en, this message translates to:
  /// **'Queue added successfully'**
  String get queueAdded;

  /// Queue updated success message
  ///
  /// In en, this message translates to:
  /// **'Queue updated successfully'**
  String get queueUpdated;

  /// Queue deleted success message
  ///
  /// In en, this message translates to:
  /// **'Queue deleted successfully'**
  String get queueDeleted;

  /// Queue toggled success message
  ///
  /// In en, this message translates to:
  /// **'Queue status changed'**
  String get queueToggled;

  /// Error loading queues message
  ///
  /// In en, this message translates to:
  /// **'Error loading queues'**
  String get errorLoadingQueues;

  /// Error adding queue message
  ///
  /// In en, this message translates to:
  /// **'Error adding queue'**
  String get errorAddingQueue;

  /// Error updating queue message
  ///
  /// In en, this message translates to:
  /// **'Error updating queue'**
  String get errorUpdatingQueue;

  /// Error deleting queue message
  ///
  /// In en, this message translates to:
  /// **'Error deleting queue'**
  String get errorDeletingQueue;

  /// Error toggling queue message
  ///
  /// In en, this message translates to:
  /// **'Error changing queue status'**
  String get errorTogglingQueue;

  /// Speed limit page title
  ///
  /// In en, this message translates to:
  /// **'Simple Q'**
  String get speedLimitTitle;

  /// Speed limit description
  ///
  /// In en, this message translates to:
  /// **'Control download and upload speed for specific devices or networks'**
  String get speedLimitDescription;

  /// Add speed limit button
  ///
  /// In en, this message translates to:
  /// **'Add Simple Q'**
  String get addSpeedLimit;

  /// Edit speed limit title
  ///
  /// In en, this message translates to:
  /// **'Edit Simple Q'**
  String get editSpeedLimit;

  /// Delete speed limit title
  ///
  /// In en, this message translates to:
  /// **'Delete Simple Q'**
  String get deleteSpeedLimit;

  /// Delete speed limit confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get deleteSpeedLimitConfirm;

  /// No speed limits message
  ///
  /// In en, this message translates to:
  /// **'No simple queues configured'**
  String get noSpeedLimits;

  /// Speed limits count
  ///
  /// In en, this message translates to:
  /// **'simple queue(s)'**
  String get speedLimitsCount;

  /// Single device label
  ///
  /// In en, this message translates to:
  /// **'Single Device'**
  String get singleDevice;

  /// Network devices label
  ///
  /// In en, this message translates to:
  /// **'Network Devices'**
  String get networkDevices;

  /// Speed units label
  ///
  /// In en, this message translates to:
  /// **'Speed Units'**
  String get speedUnits;

  /// Ready templates title
  ///
  /// In en, this message translates to:
  /// **'Ready Templates'**
  String get readyTemplates;

  /// Templates description
  ///
  /// In en, this message translates to:
  /// **'Quick setup with predefined settings'**
  String get templatesDescription;

  /// Quick guide title
  ///
  /// In en, this message translates to:
  /// **'Quick Guide'**
  String get quickGuide;

  /// Name label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// Name example placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g., Office Manager, Guest Network'**
  String get nameExample;

  /// Name required error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Target label
  ///
  /// In en, this message translates to:
  /// **'Device or Network'**
  String get targetLabel;

  /// Target example placeholder
  ///
  /// In en, this message translates to:
  /// **'192.168.1.100 or 192.168.1.0/24'**
  String get targetExample;

  /// Target required error
  ///
  /// In en, this message translates to:
  /// **'IP address is required'**
  String get targetRequired;

  /// Invalid IP format error
  ///
  /// In en, this message translates to:
  /// **'Invalid IP address format'**
  String get invalidIPFormat;

  /// Speed limit label
  ///
  /// In en, this message translates to:
  /// **'Speed Limit'**
  String get speedLimit;

  /// Download label
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Upload label
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Priority label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityLabel;

  /// Comment optional label
  ///
  /// In en, this message translates to:
  /// **'Comment (Optional)'**
  String get commentOptional;

  /// Comment hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., VIP user, Guest network'**
  String get commentHint;

  /// Saving status
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Regular user template name
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get templateRegularUser;

  /// Regular user template description
  ///
  /// In en, this message translates to:
  /// **'For regular users'**
  String get templateRegularUserDesc;

  /// Guest network template name
  ///
  /// In en, this message translates to:
  /// **'Guest Network'**
  String get templateGuestNetwork;

  /// Guest network template description
  ///
  /// In en, this message translates to:
  /// **'Limited for guests'**
  String get templateGuestNetworkDesc;

  /// VIP user template name
  ///
  /// In en, this message translates to:
  /// **'VIP User'**
  String get templateVIPUser;

  /// VIP user template description
  ///
  /// In en, this message translates to:
  /// **'For VIP users'**
  String get templateVIPUserDesc;

  /// Server template name
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get templateServer;

  /// Server template description
  ///
  /// In en, this message translates to:
  /// **'For servers'**
  String get templateServerDesc;

  /// Camera template name
  ///
  /// In en, this message translates to:
  /// **'Security Camera'**
  String get templateCamera;

  /// Camera template description
  ///
  /// In en, this message translates to:
  /// **'For cameras'**
  String get templateCameraDesc;

  /// High priority label
  ///
  /// In en, this message translates to:
  /// **'High Priority'**
  String get priorityHigh;

  /// High priority description
  ///
  /// In en, this message translates to:
  /// **'VoIP, video conferencing, servers'**
  String get priorityHighDesc;

  /// Medium priority label
  ///
  /// In en, this message translates to:
  /// **'Medium Priority'**
  String get priorityMedium;

  /// Medium priority description
  ///
  /// In en, this message translates to:
  /// **'Web browsing, email, regular users'**
  String get priorityMediumDesc;

  /// Low priority label
  ///
  /// In en, this message translates to:
  /// **'Low Priority'**
  String get priorityLow;

  /// Low priority description
  ///
  /// In en, this message translates to:
  /// **'Downloads, torrents, backups'**
  String get priorityLowDesc;

  /// High priority short label
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHighShort;

  /// Medium priority short label
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMediumShort;

  /// Low priority short label
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLowShort;

  /// Wireless management page title
  ///
  /// In en, this message translates to:
  /// **'Wireless Management'**
  String get wirelessManagement;

  /// Wireless interfaces tab
  ///
  /// In en, this message translates to:
  /// **'Interfaces'**
  String get interfaces;

  /// Connected clients tab
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// Security profiles tab
  ///
  /// In en, this message translates to:
  /// **'Security Profiles'**
  String get securityProfiles;

  /// Message when no wireless interfaces are available
  ///
  /// In en, this message translates to:
  /// **'No wireless interfaces found'**
  String get noWirelessInterfaces;

  /// Message when no clients are connected
  ///
  /// In en, this message translates to:
  /// **'No connected clients found'**
  String get noConnectedClients;

  /// Message when no security profiles are available
  ///
  /// In en, this message translates to:
  /// **'No security profiles found'**
  String get noSecurityProfiles;

  /// Description text for wireless management section
  ///
  /// In en, this message translates to:
  /// **'Manage wireless interfaces, clients, and security profiles'**
  String get wirelessManagementDescription;

  /// Help text explaining wireless management features
  ///
  /// In en, this message translates to:
  /// **'This section allows you to manage wireless interfaces, monitor connected clients, configure security profiles, and perform wireless network scans.'**
  String get wirelessManagementHelpText;

  /// Help button or tooltip
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Title for the subscription page
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// Error message on subscription page
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get subscriptionError;

  /// Status when user is subscribed
  ///
  /// In en, this message translates to:
  /// **'You are subscribed'**
  String get subscriptionSubscribed;

  /// Indicates the subscription expiry date
  ///
  /// In en, this message translates to:
  /// **'Subscribed until {date}'**
  String subscriptionSubscribedUntil(String date);

  /// Status when user is in trial period
  ///
  /// In en, this message translates to:
  /// **'Trial period active'**
  String get subscriptionTrialActive;

  /// Indicates remaining trial days
  ///
  /// In en, this message translates to:
  /// **'{days} days of free trial remaining'**
  String subscriptionTrialEndsIn(int days);

  /// Status when user has no subscription
  ///
  /// In en, this message translates to:
  /// **'Not Subscribed'**
  String get subscriptionNotSubscribed;

  /// Subtitle for non-subscribed users
  ///
  /// In en, this message translates to:
  /// **'You can use the app for 7 days for free.'**
  String get subscriptionNotSubscribedSubtitle;

  /// Title for the subscription status card
  ///
  /// In en, this message translates to:
  /// **'Subscription Status'**
  String get subscriptionStatusTitle;

  /// Title for the subscription plan card
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get subscriptionPlanTitle;

  /// Name of the monthly subscription plan
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get subscriptionMonthlyPlan;

  /// Text shown while loading the price
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get subscriptionPriceLoading;

  /// A feature of the subscription
  ///
  /// In en, this message translates to:
  /// **'Access to all premium features'**
  String get subscriptionFeature1;

  /// A feature of the subscription
  ///
  /// In en, this message translates to:
  /// **'Unlimited device management'**
  String get subscriptionFeature2;

  /// A feature of the subscription
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get subscriptionFeature3;

  /// Button text while processing
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get subscriptionCtaButtonLoading;

  /// Button text when already subscribed
  ///
  /// In en, this message translates to:
  /// **'Subscribed'**
  String get subscriptionCtaButtonSubscribed;

  /// Button text to purchase subscription
  ///
  /// In en, this message translates to:
  /// **'Purchase Subscription'**
  String get subscriptionCtaButtonPurchase;

  /// Button text to start a free trial
  ///
  /// In en, this message translates to:
  /// **'Start 7-day Free Trial'**
  String get subscriptionCtaButtonTrial;

  /// Title for a locked feature
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeatureTitle;

  /// Subtitle for a locked feature
  ///
  /// In en, this message translates to:
  /// **'Tap to unlock all features'**
  String get premiumFeatureSubtitle;

  /// Welcome message on home page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Network Assistant'**
  String get welcomeToNetworkAssistant;

  /// Instruction text on home page
  ///
  /// In en, this message translates to:
  /// **'Select a module to get started'**
  String get selectModuleToStart;

  /// MikroTik module name
  ///
  /// In en, this message translates to:
  /// **'MikroTik Assist'**
  String get mikrotikAssist;

  /// MikroTik module description
  ///
  /// In en, this message translates to:
  /// **'Manage your MikroTik routers'**
  String get mikrotikAssistDescription;

  /// SNMP module name
  ///
  /// In en, this message translates to:
  /// **'SNMP Assist'**
  String get snmpAssist;

  /// SNMP module description
  ///
  /// In en, this message translates to:
  /// **'Monitor network devices via SNMP'**
  String get snmpAssistDescription;

  /// Asterisk PBX module name
  ///
  /// In en, this message translates to:
  /// **'Asterisk PBX'**
  String get asteriskPbx;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App login page title
  ///
  /// In en, this message translates to:
  /// **'App Login'**
  String get appLogin;

  /// Register button or page title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Already have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Don't have account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Biometric login button
  ///
  /// In en, this message translates to:
  /// **'Login with Biometric'**
  String get loginWithBiometric;

  /// Biometric authentication status
  ///
  /// In en, this message translates to:
  /// **'Biometric Enabled'**
  String get biometricEnabled;

  /// Enable biometric button
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric'**
  String get enableBiometric;

  /// Disable biometric button
  ///
  /// In en, this message translates to:
  /// **'Disable Biometric'**
  String get disableBiometric;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 3 characters'**
  String get passwordTooShort;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccess;

  /// Registration failed message
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// User already exists error
  ///
  /// In en, this message translates to:
  /// **'Username already exists'**
  String get userAlreadyExists;

  /// Invalid credentials error
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// Hint for default admin credentials
  ///
  /// In en, this message translates to:
  /// **'Default: admin (no password)'**
  String get defaultAdminHint;

  /// Network management section
  ///
  /// In en, this message translates to:
  /// **'Network Management'**
  String get networkManagement;

  /// Security and access section
  ///
  /// In en, this message translates to:
  /// **'Security & Access'**
  String get securityAccess;

  /// Monitoring tools section
  ///
  /// In en, this message translates to:
  /// **'Monitoring & Tools'**
  String get monitoringTools;

  /// System Logs title
  ///
  /// In en, this message translates to:
  /// **'System Logs'**
  String get systemLogs;

  /// Logs tab title
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// Live log tab title
  ///
  /// In en, this message translates to:
  /// **'Live Log'**
  String get liveLog;

  /// Info text for logs tab
  ///
  /// In en, this message translates to:
  /// **'Shows all router system logs. Use filter to narrow by topic.'**
  String get logsTabInfo;

  /// Info text for live log tab
  ///
  /// In en, this message translates to:
  /// **'Shows live log updates as they happen on the router.'**
  String get liveLogTabInfo;

  /// Close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Search action
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search placeholder for logs
  ///
  /// In en, this message translates to:
  /// **'Search logs...'**
  String get searchLogs;

  /// Clear logs action
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// Clear logs confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all logs?'**
  String get clearLogsConfirmation;

  /// Clear action label
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Snackbar after clearing logs
  ///
  /// In en, this message translates to:
  /// **'Logs cleared successfully'**
  String get logsCleared;

  /// No logs found message
  ///
  /// In en, this message translates to:
  /// **'No logs found'**
  String get noLogsFound;

  /// No live logs message
  ///
  /// In en, this message translates to:
  /// **'No live logs available'**
  String get noLiveLogs;

  /// Backup page title
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// Create backup button
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Description shown in create backup card
  ///
  /// In en, this message translates to:
  /// **'Create a backup of current RouterOS settings.'**
  String get backupDescription;

  /// Backup name field
  ///
  /// In en, this message translates to:
  /// **'Backup Name'**
  String get backupName;

  /// Create action
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Validation for backup name
  ///
  /// In en, this message translates to:
  /// **'Backup name is required'**
  String get backupNameRequired;

  /// No spaces validation
  ///
  /// In en, this message translates to:
  /// **'Backup name cannot contain spaces'**
  String get backupNameNoSpaces;

  /// No backups message
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get noBackupsFound;

  /// Restore action
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Confirm restore dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// Warning shown before restore
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore this backup? This will overwrite current settings.'**
  String get restoreBackupWarning;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Warning shown before deleting backup
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup?'**
  String get deleteBackupWarning;

  /// Advanced features section
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get advancedFeatures;

  /// Advanced options title
  ///
  /// In en, this message translates to:
  /// **'Advanced Options'**
  String get advancedOptions;

  /// Advanced options subtitle
  ///
  /// In en, this message translates to:
  /// **'For advanced users'**
  String get forAdvancedUsers;

  /// Validation for target input
  ///
  /// In en, this message translates to:
  /// **'Please enter target'**
  String get pleaseEnterTarget;

  /// Hint for target host
  ///
  /// In en, this message translates to:
  /// **'Target host or IP'**
  String get targetHostHint;

  /// Start action
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Stop action
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Ping quick tip text
  ///
  /// In en, this message translates to:
  /// **'Quick tip: use proper hostnames or IPs'**
  String get pingQuickTip;

  /// Packet size label
  ///
  /// In en, this message translates to:
  /// **'Packet Size'**
  String get packetSize;

  /// Help for packet size
  ///
  /// In en, this message translates to:
  /// **'Size of each ICMP packet in bytes'**
  String get packetSizeHelp;

  /// Bytes unit
  ///
  /// In en, this message translates to:
  /// **'bytes'**
  String get bytes;

  /// Time To Live label
  ///
  /// In en, this message translates to:
  /// **'TTL'**
  String get ttl;

  /// Help for TTL
  ///
  /// In en, this message translates to:
  /// **'Time to live for packets'**
  String get ttlHelp;

  /// Interval label
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Help for interval
  ///
  /// In en, this message translates to:
  /// **'Interval between requests in seconds'**
  String get intervalHelp;

  /// Seconds unit
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// Count label
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// Help for count
  ///
  /// In en, this message translates to:
  /// **'Number of packets to send'**
  String get countHelp;

  /// Source address label
  ///
  /// In en, this message translates to:
  /// **'Source Address'**
  String get sourceAddress;

  /// Help for source address
  ///
  /// In en, this message translates to:
  /// **'Source address to use'**
  String get sourceAddressHelp;

  /// Auto or Default hint
  ///
  /// In en, this message translates to:
  /// **'Auto / Default'**
  String get autoDefault;

  /// Help for interface
  ///
  /// In en, this message translates to:
  /// **'Network interface to use'**
  String get interfaceHelp;

  /// Don't Fragment label
  ///
  /// In en, this message translates to:
  /// **'Don\'t Fragment'**
  String get doNotFragment;

  /// Help for Don't Fragment
  ///
  /// In en, this message translates to:
  /// **'Set Don\'t Fragment flag for packets'**
  String get doNotFragmentHelp;

  /// Subtitle for MTU testing
  ///
  /// In en, this message translates to:
  /// **'For MTU testing'**
  String get forMtuTesting;

  /// Live statistics title
  ///
  /// In en, this message translates to:
  /// **'Live Statistics'**
  String get liveStatistics;

  /// Sent stat
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// Received stat
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// Loss stat
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// Success rate label
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// RTT label
  ///
  /// In en, this message translates to:
  /// **'Round Trip Time'**
  String get roundTripTime;

  /// Minimum label
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// Average label
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get avg;

  /// Maximum label
  ///
  /// In en, this message translates to:
  /// **'max'**
  String get max;

  /// Packet history title
  ///
  /// In en, this message translates to:
  /// **'Packet History'**
  String get packetHistory;

  /// Packets count
  ///
  /// In en, this message translates to:
  /// **'{count} packets'**
  String packetsCount(int count);

  /// Waiting text
  ///
  /// In en, this message translates to:
  /// **'Waiting for packets'**
  String get waitingForPackets;

  /// Timeout label
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// Unknown label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Max hops label
  ///
  /// In en, this message translates to:
  /// **'Max Hops'**
  String get maxHopsLabel;

  /// Help for max hops
  ///
  /// In en, this message translates to:
  /// **'Maximum number of hops to probe'**
  String get maxHopsHelp;

  /// Hops label
  ///
  /// In en, this message translates to:
  /// **'Hops'**
  String get hops;

  /// Timeout ms label
  ///
  /// In en, this message translates to:
  /// **'Timeout (ms)'**
  String get timeoutMsLabel;

  /// Help for timeout ms
  ///
  /// In en, this message translates to:
  /// **'Max time in milliseconds to wait for a probe response'**
  String get timeoutMsHelp;

  /// Milliseconds unit
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get ms;

  /// Count probes label
  ///
  /// In en, this message translates to:
  /// **'Count Probes'**
  String get countProbes;

  /// Help for count probes
  ///
  /// In en, this message translates to:
  /// **'Number of probes per hop'**
  String get countProbesHelp;

  /// Traceroute quick tip
  ///
  /// In en, this message translates to:
  /// **'Quick tip: traceroute shows path taken to target'**
  String get tracerouteQuickTip;

  /// Traceroute progress
  ///
  /// In en, this message translates to:
  /// **'Traceroute in progress for {target}'**
  String tracerouteInProgress(String target);

  /// Waiting for hops
  ///
  /// In en, this message translates to:
  /// **'Waiting for hops'**
  String get waitingForHops;

  /// Route path
  ///
  /// In en, this message translates to:
  /// **'Route Path'**
  String get routePath;

  /// Hop count
  ///
  /// In en, this message translates to:
  /// **'{count} hops'**
  String hopCount(int count);

  /// Total time label
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// Target reached label
  ///
  /// In en, this message translates to:
  /// **'Target Reached'**
  String get targetReached;

  /// Target not reached label
  ///
  /// In en, this message translates to:
  /// **'Target Not Reached'**
  String get targetNotReached;
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
