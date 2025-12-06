// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MikroTik Manager';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get loginButton => 'Login';

  @override
  String get loginError => 'Login failed';

  @override
  String get connectionError => 'Connection error';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get interfaces => 'Interfaces';

  @override
  String get ipAddresses => 'IP Addresses';

  @override
  String get dhcpServer => 'DHCP Server';

  @override
  String get firewall => 'Firewall';

  @override
  String get settings => 'Settings';

  @override
  String get systemResources => 'System Resources';

  @override
  String get uptime => 'Uptime';

  @override
  String get version => 'Version';

  @override
  String get cpu => 'CPU';

  @override
  String get memory => 'Memory';

  @override
  String get disk => 'Disk';

  @override
  String get cpuLoad => 'CPU Load';

  @override
  String get freeMemory => 'Free Memory';

  @override
  String get totalMemory => 'Total Memory';

  @override
  String get freeDisk => 'Free Disk';

  @override
  String get totalDisk => 'Total Disk';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get persian => 'Persian';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get connecting => 'Connecting...';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get name => 'Name';

  @override
  String get type => 'Type';

  @override
  String get status => 'Status';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get running => 'Running';

  @override
  String get address => 'Address';

  @override
  String get network => 'Network';

  @override
  String get interface => 'Interface';

  @override
  String get comment => 'Comment';

  @override
  String get noData => 'No data available';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Information';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get pleaseWait => 'Please wait...';

  @override
  String get hotspot => 'HotSpot';

  @override
  String get hotspotUsers => 'HotSpot Users';

  @override
  String get hotspotActiveUsers => 'Active Users';

  @override
  String get hotspotServers => 'HotSpot Servers';

  @override
  String get hotspotProfiles => 'User Profiles';

  @override
  String get addUser => 'Add User';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get bytesIn => 'Bytes In';

  @override
  String get bytesOut => 'Bytes Out';

  @override
  String get packetsIn => 'Packets In';

  @override
  String get packetsOut => 'Packets Out';

  @override
  String get macAddress => 'MAC Address';

  @override
  String get loginBy => 'Login By';

  @override
  String get sessionTime => 'Session Time';

  @override
  String get idleTime => 'Idle Time';

  @override
  String get addressPool => 'Address Pool';

  @override
  String get profile => 'Profile';

  @override
  String get server => 'Server';

  @override
  String get sessionTimeout => 'Session Timeout';

  @override
  String get idleTimeout => 'Idle Timeout';

  @override
  String get sharedUsers => 'Shared Users';

  @override
  String get rateLimit => 'Rate Limit';

  @override
  String get statusAccounting => 'Status Accounting';

  @override
  String get transparentProxy => 'Transparent Proxy';

  @override
  String get certificates => 'Certificates';

  @override
  String get localCA => 'Local CA';

  @override
  String get letsEncrypt => 'Let\'s Encrypt';

  @override
  String get letsEncryptCertificateActive => 'Certificate Active';

  @override
  String get letsEncryptNoCertificate => 'No Certificate';

  @override
  String get letsEncryptCertificateIssued => 'Certificate issued successfully!';

  @override
  String get letsEncryptAutoFixSuccess => 'Issue fixed successfully';

  @override
  String get letsEncryptAutoFixing => 'Fixing issue...';

  @override
  String get letsEncryptRequesting => 'Requesting Certificate...';

  @override
  String get letsEncryptRequestingInfo =>
      'This may take 1-2 minutes. The router needs to verify domain ownership via port 80.';

  @override
  String get letsEncryptCertName => 'Certificate Name';

  @override
  String get letsEncryptExpiresAt => 'Expires At';

  @override
  String get letsEncryptDaysRemaining => 'Days Remaining';

  @override
  String get letsEncryptExpiringSoon =>
      'Certificate is expiring soon. Consider renewing.';

  @override
  String get letsEncryptRevoke => 'Delete Certificate';

  @override
  String get letsEncryptRenew => 'Renew Certificate';

  @override
  String get letsEncryptGetCertificate => 'Get Free SSL Certificate';

  @override
  String get letsEncryptInfo => 'About Let\'s Encrypt';

  @override
  String get letsEncryptInfoText =>
      'Let\'s Encrypt provides free SSL certificates that are trusted by all browsers. Certificates are valid for 90 days and can be renewed automatically.';

  @override
  String get letsEncryptPreChecks => 'Pre-flight Checks';

  @override
  String get letsEncryptPreChecksDesc =>
      'Before requesting a certificate, we need to verify your router meets all requirements.';

  @override
  String get letsEncryptDnsName => 'Your DNS Name';

  @override
  String get letsEncryptRequestNow => 'Request Certificate';

  @override
  String get letsEncryptAutoFixAll => 'Fix All Issues';

  @override
  String get letsEncryptRecheck => 'Re-check';

  @override
  String get letsEncryptFix => 'Fix';

  @override
  String get letsEncryptCheckCloud => 'Cloud DDNS Enabled';

  @override
  String get letsEncryptCheckDns => 'DNS Name Available';

  @override
  String get letsEncryptCheckPort80 => 'Port 80 Accessible';

  @override
  String get letsEncryptCheckFirewall => 'Firewall Allows Port 80';

  @override
  String get letsEncryptCheckNat => 'No NAT Redirect on Port 80';

  @override
  String get letsEncryptCheckWww => 'WWW Service Not on Port 80';

  @override
  String get letsEncryptLoadingStatus => 'Loading certificate status...';

  @override
  String get letsEncryptRunningPreChecks => 'Running pre-flight checks...';

  @override
  String get letsEncryptErrorCloudNotEnabled =>
      'Cloud DDNS is not enabled. Enable it to get a DNS name.';

  @override
  String get letsEncryptErrorDnsNotAvailable =>
      'DNS name not available yet. Wait for MikroTik Cloud to assign one.';

  @override
  String get letsEncryptErrorPort80Blocked =>
      'Port 80 is blocked. It must be accessible from the internet.';

  @override
  String get letsEncryptErrorWwwService =>
      'WWW service is using port 80. Change its port or disable it.';

  @override
  String get letsEncryptErrorNatRule =>
      'A NAT rule is redirecting port 80. Disable it temporarily.';

  @override
  String get letsEncryptErrorLoadFailed => 'Failed to load certificate status';

  @override
  String get letsEncryptErrorPreChecksFailed =>
      'Failed to run pre-flight checks';

  @override
  String get letsEncryptErrorAutoFixFailed =>
      'Failed to fix the issue automatically';

  @override
  String get letsEncryptErrorRequestFailed =>
      'Failed to request certificate. Check port 80 accessibility.';

  @override
  String get letsEncryptErrorRevokeFailed => 'Failed to delete certificate';

  @override
  String get letsEncryptRevokeTitle => 'Delete Certificate?';

  @override
  String get letsEncryptRevokeDesc =>
      'Are you sure you want to delete this Let\'s Encrypt certificate?';

  @override
  String get letsEncryptRevokeWarning =>
      'Services using this certificate will stop working until a new certificate is issued.';
}
