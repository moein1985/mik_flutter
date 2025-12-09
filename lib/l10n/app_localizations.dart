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

  /// Wireless interfaces tab
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

  /// Status indicator for enabled items
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Status indicator for disabled items
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
  /// **'Target Host/IP'**
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

  /// Wireless management page title
  ///
  /// In en, this message translates to:
  /// **'Wireless Management'**
  String get wirelessManagement;

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

  /// Status indicator for connected clients
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// System logs page title
  ///
  /// In en, this message translates to:
  /// **'System Logs'**
  String get systemLogs;

  /// Logs tab
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// Follow logs tab
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Search button/action
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Search logs hint text
  ///
  /// In en, this message translates to:
  /// **'Search logs...'**
  String get searchLogs;

  /// Clear logs action
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// Clear logs confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all logs?'**
  String get clearLogsConfirmation;

  /// Clear action
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Filter logs title
  ///
  /// In en, this message translates to:
  /// **'Filter Logs'**
  String get filterLogs;

  /// Topics filter label
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get topics;

  /// Apply filter button
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// Clear filter button
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// Common topics label
  ///
  /// In en, this message translates to:
  /// **'Common Topics:'**
  String get commonTopics;

  /// Message when no logs are found
  ///
  /// In en, this message translates to:
  /// **'No logs found'**
  String get noLogsFound;

  /// Message when no live logs are available
  ///
  /// In en, this message translates to:
  /// **'No live logs available'**
  String get noLiveLogs;

  /// Success message when logs are cleared
  ///
  /// In en, this message translates to:
  /// **'Logs cleared successfully'**
  String get logsCleared;

  /// Backup & Restore section title
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// Create backup button/action
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Backup name field label
  ///
  /// In en, this message translates to:
  /// **'Backup Name'**
  String get backupName;

  /// Validation message for required backup name
  ///
  /// In en, this message translates to:
  /// **'Backup name is required'**
  String get backupNameRequired;

  /// Validation message for backup name containing spaces
  ///
  /// In en, this message translates to:
  /// **'Backup name cannot contain spaces'**
  String get backupNameNoSpaces;

  /// Description text for backup creation
  ///
  /// In en, this message translates to:
  /// **'Create a backup of the current RouterOS configuration.'**
  String get backupDescription;

  /// Generic create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Message when no backups are found
  ///
  /// In en, this message translates to:
  /// **'No backups found'**
  String get noBackupsFound;

  /// Restore action/button text
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Confirm restore dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get confirmRestore;

  /// Warning message for backup restore operation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore from this backup? This will overwrite current configuration.'**
  String get restoreBackupWarning;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Warning message for backup delete operation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this backup?'**
  String get deleteBackupWarning;

  /// Network Management section title
  ///
  /// In en, this message translates to:
  /// **'Network Management'**
  String get networkManagement;

  /// Security & Access section title
  ///
  /// In en, this message translates to:
  /// **'Security & Access'**
  String get securityAccess;

  /// Monitoring & Tools section title
  ///
  /// In en, this message translates to:
  /// **'Monitoring & Tools'**
  String get monitoringTools;

  /// Advanced Features section title
  ///
  /// In en, this message translates to:
  /// **'Advanced Features'**
  String get advancedFeatures;
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
