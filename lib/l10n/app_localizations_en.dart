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
  String get letsEncryptSuccessDescription =>
      'Your Let\'s Encrypt certificate has been issued and configured. You can now use HTTPS with your router.';

  @override
  String get viewCertificate => 'View Certificate';

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
  String get letsEncryptErrorWwwNotOnPort80 =>
      'WWW service must be enabled on port 80 for Let\'s Encrypt to work.';

  @override
  String get letsEncryptErrorWwwCheckFailed =>
      'Could not check WWW service status.';

  @override
  String get letsEncryptErrorAcmeConnectionFailed =>
      'Cannot connect to Let\'s Encrypt servers. This may be due to internet restrictions or sanctions in your region. Try using a VPN on your router.';

  @override
  String get letsEncryptErrorAcmeDnsResolutionFailed =>
      'Cannot resolve Let\'s Encrypt server address. Check your router\'s DNS settings.';

  @override
  String get letsEncryptErrorAcmeSslUpdateFailed =>
      'Failed to obtain SSL certificate. The router could not complete the Let\'s Encrypt verification process.';

  @override
  String get letsEncryptErrorAcmeRateLimited =>
      'Too many certificate requests. Let\'s Encrypt has rate limits. Please wait a few hours and try again.';

  @override
  String get letsEncryptErrorAcmeAuthorizationFailed =>
      'Domain verification failed. Make sure port 80 is accessible from the internet and your domain points to this router.';

  @override
  String get letsEncryptErrorAcmeChallengeValidationFailed =>
      'Challenge validation failed. Let\'s Encrypt could not verify your domain ownership. Ensure port 80 is forwarded correctly.';

  @override
  String get letsEncryptErrorAcmeTimeout =>
      'Connection to Let\'s Encrypt timed out. Check your internet connection and try again.';

  @override
  String letsEncryptErrorAcmeGeneric(String error) {
    return 'Let\'s Encrypt error: $error';
  }

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

  @override
  String get networkTools => 'Network Tools';

  @override
  String get diagnosticTools => 'Network Diagnostic Tools';

  @override
  String get testConnectivity => 'Test connectivity and resolve network issues';

  @override
  String get toolsInfoTitle => 'Real-time Network Tools';

  @override
  String get toolsInfoDescription =>
      'All diagnostic tools display results in real-time as they are received from the router.';

  @override
  String get pingInfoText => 'Ping: Real-time packet transmission display';

  @override
  String get tracerouteInfoText =>
      'Traceroute: Step-by-step network path display';

  @override
  String get dnsLookupInfoText => 'DNS Lookup: Fast IP address resolution';

  @override
  String get stopPing => 'Stop';

  @override
  String get ping => 'Ping';

  @override
  String get pingTest => 'Ping Test';

  @override
  String get pingConnectivity => 'Test connectivity to a host';

  @override
  String get traceroute => 'Traceroute';

  @override
  String get tracerouteTest => 'Traceroute Test';

  @override
  String get tracePath => 'Trace network path to a host';

  @override
  String get dnsLookup => 'DNS Lookup';

  @override
  String get dnsLookupTitle => 'DNS Lookup';

  @override
  String get resolveDomains => 'Resolve domain names to IP addresses';

  @override
  String get clearResults => 'Clear Results';

  @override
  String get clearAllResults => 'Clear all diagnostic results';

  @override
  String get targetHost => 'Target Host/IP';

  @override
  String get packetCount => 'Packet Count';

  @override
  String get timeoutMs => 'Timeout (ms)';

  @override
  String get maxHops => 'Max Hops';

  @override
  String get domainName => 'Domain Name';

  @override
  String get startPing => 'Start Ping';

  @override
  String get startTraceroute => 'Start Traceroute';

  @override
  String get lookupDns => 'Lookup DNS';

  @override
  String get pingResults => 'Ping Results';

  @override
  String get tracerouteResults => 'Traceroute Results';

  @override
  String get dnsResults => 'DNS Lookup Results';

  @override
  String get packetsSent => 'Packets sent';

  @override
  String get packetsReceived => 'Packets received';

  @override
  String get packetLoss => 'Packet Loss';

  @override
  String get rtt => 'RTT';

  @override
  String get ipv4Addresses => 'IPv4 Addresses';

  @override
  String get ipv6Addresses => 'IPv6 Addresses';

  @override
  String get responseTime => 'Response Time';

  @override
  String get noResults => 'No results found';

  @override
  String get queues => 'Queues';

  @override
  String get simpleQueues => 'Simple Queues';

  @override
  String get queueManagement => 'Manage bandwidth queues and traffic shaping';

  @override
  String get addQueue => 'Add Queue';

  @override
  String get queueName => 'Queue Name';

  @override
  String get target => 'Target';

  @override
  String get maxLimit => 'Max Limit';

  @override
  String get burstLimit => 'Burst Limit';

  @override
  String get burstThreshold => 'Burst Threshold';

  @override
  String get burstTime => 'Burst Time';

  @override
  String get priority => 'Priority';

  @override
  String get parent => 'Parent';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get limitAt => 'Limit At';

  @override
  String get queueType => 'Queue Type';

  @override
  String get totalQueueLimit => 'Total Queue Limit';

  @override
  String get totalMaxLimit => 'Total Max Limit';

  @override
  String get totalBurstLimit => 'Total Burst Limit';

  @override
  String get totalBurstThreshold => 'Total Burst Threshold';

  @override
  String get totalBurstTime => 'Total Burst Time';

  @override
  String get totalLimitAt => 'Total Limit At';

  @override
  String get bucketSize => 'Bucket Size';

  @override
  String get saveQueue => 'Save Queue';

  @override
  String get deleteQueue => 'Delete Queue';

  @override
  String get deleteQueueConfirm =>
      'Are you sure you want to delete this queue?';

  @override
  String get toggleQueue => 'Toggle Queue';

  @override
  String get queueEnabled => 'Queue enabled';

  @override
  String get queueDisabled => 'Queue disabled';

  @override
  String get loadingQueues => 'Loading queues...';

  @override
  String get noQueues => 'No queues found';

  @override
  String get queueAdded => 'Queue added successfully';

  @override
  String get queueUpdated => 'Queue updated successfully';

  @override
  String get queueDeleted => 'Queue deleted successfully';

  @override
  String get queueToggled => 'Queue status changed';

  @override
  String get errorLoadingQueues => 'Error loading queues';

  @override
  String get errorAddingQueue => 'Error adding queue';

  @override
  String get errorUpdatingQueue => 'Error updating queue';

  @override
  String get errorDeletingQueue => 'Error deleting queue';

  @override
  String get errorTogglingQueue => 'Error changing queue status';

  @override
  String get wirelessManagement => 'Wireless Management';

  @override
  String get clients => 'Clients';

  @override
  String get securityProfiles => 'Security Profiles';

  @override
  String get noWirelessInterfaces => 'No wireless interfaces found';

  @override
  String get noConnectedClients => 'No connected clients found';

  @override
  String get noSecurityProfiles => 'No security profiles found';

  @override
  String get connected => 'Connected';

  @override
  String get systemLogs => 'System Logs';

  @override
  String get logs => 'Logs';

  @override
  String get follow => 'Follow';

  @override
  String get search => 'Search';

  @override
  String get searchLogs => 'Search logs...';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get clearLogsConfirmation =>
      'Are you sure you want to clear all logs?';

  @override
  String get clear => 'Clear';

  @override
  String get filterLogs => 'Filter Logs';

  @override
  String get topics => 'Topics';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get commonTopics => 'Common Topics:';

  @override
  String get noLogsFound => 'No logs found';

  @override
  String get noLiveLogs => 'No live logs available';

  @override
  String get logsCleared => 'Logs cleared successfully';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get backupName => 'Backup Name';

  @override
  String get backupNameRequired => 'Backup name is required';

  @override
  String get backupNameNoSpaces => 'Backup name cannot contain spaces';

  @override
  String get backupDescription =>
      'Create a backup of the current RouterOS configuration.';

  @override
  String get create => 'Create';

  @override
  String get noBackupsFound => 'No backups found';

  @override
  String get restore => 'Restore';

  @override
  String get confirmRestore => 'Confirm Restore';

  @override
  String get restoreBackupWarning =>
      'Are you sure you want to restore from this backup? This will overwrite current configuration.';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteBackupWarning =>
      'Are you sure you want to delete this backup?';

  @override
  String get networkManagement => 'Network Management';

  @override
  String get securityAccess => 'Security & Access';

  @override
  String get monitoringTools => 'Monitoring & Tools';

  @override
  String get advancedFeatures => 'Advanced Features';
}
