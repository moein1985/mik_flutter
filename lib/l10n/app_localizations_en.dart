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
  String get refresh => 'Refresh';

  @override
  String get active => 'Active';

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
  String get letsEncryptDomainSection => 'Domain';

  @override
  String get letsEncryptTechnicalPrereqs => 'Technical Prerequisites';

  @override
  String get letsEncryptAllPrereqsMet => 'All ready';

  @override
  String letsEncryptPrereqsIssues(int count) {
    return '$count issue(s)';
  }

  @override
  String get letsEncryptShowDetails => 'Show details';

  @override
  String get letsEncryptHideDetails => 'Hide details';

  @override
  String get letsEncryptUseCloudDdns => 'Use Cloud DDNS (Recommended)';

  @override
  String get letsEncryptUseCustomDomain => 'Use Custom Domain';

  @override
  String get letsEncryptCloudDdnsDesc =>
      'Free MikroTik domain - automatically configured';

  @override
  String get letsEncryptCustomDomainDesc =>
      'A domain you have registered yourself';

  @override
  String get letsEncryptEnableCloudDdns => 'Enable Cloud DDNS';

  @override
  String get letsEncryptCloudDdnsEnabling => 'Enabling...';

  @override
  String get letsEncryptCloudDdnsWaiting =>
      'Waiting for DNS name assignment...';

  @override
  String get letsEncryptCloudNotSupportedTitle => 'Cloud DDNS Not Available';

  @override
  String get letsEncryptCloudNotSupportedMessage =>
      'Your router is an x86/CHR (virtual) type and Cloud DDNS service is not supported on these routers.';

  @override
  String get letsEncryptDontWorry => 'Don\'t worry! You can use a free domain.';

  @override
  String get letsEncryptCustomDomainRequired => 'Custom Domain (Required)';

  @override
  String get letsEncryptDomainMustPointTo =>
      'This domain must point to your router\'s public IP:';

  @override
  String get letsEncryptYourIp => 'Your IP';

  @override
  String get letsEncryptNoFreeDomain => 'Don\'t have a free domain?';

  @override
  String get letsEncryptFreeDomainProviders =>
      'Get one free from these services:';

  @override
  String get letsEncryptDuckDnsSimple => 'DuckDNS.org (Simple & Fast)';

  @override
  String get letsEncryptVideoGuide => 'Video Guide';

  @override
  String get letsEncryptDomainPlaceholder => 'example.duckdns.org';

  @override
  String get letsEncryptGetFreeSslCertificate => 'Get Free SSL Certificate';

  @override
  String get letsEncryptEnterDomainToContinue => 'Enter domain to continue';

  @override
  String get letsEncryptFixIssuesFirst => 'Fix issues first';

  @override
  String get letsEncryptAutoFix => 'Auto Fix';

  @override
  String get letsEncryptRequestNow => 'Request Certificate';

  @override
  String get letsEncryptAutoFixAll => 'Fix All Issues';

  @override
  String get letsEncryptRecheck => 'Re-check';

  @override
  String get letsEncryptFix => 'Fix';

  @override
  String get letsEncryptCloudNotSupported => 'Cloud DDNS Not Supported';

  @override
  String get letsEncryptCloudNotSupportedDesc =>
      'MikroTik Cloud services are not available on x86/CHR (virtual) routers. You must use a custom domain (e.g., from DuckDNS) that points to your router\'s public IP.';

  @override
  String get letsEncryptDnsNameLabel => 'DNS Name / Domain';

  @override
  String get letsEncryptDnsNameHelperCloud =>
      'Auto-filled from Cloud DDNS (you can change it)';

  @override
  String get letsEncryptDnsNameHelperCustom =>
      'Enter your domain name pointing to this router';

  @override
  String get letsEncryptDnsNameHelperRequired =>
      'Required: Enter a domain that points to your router\'s IP';

  @override
  String get letsEncryptDomainRequired =>
      'You must enter a domain name to continue';

  @override
  String get letsEncryptEnterDomainFirst => 'Enter Domain Name First';

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
  String get stopTraceroute => 'Stop';

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
  String get targetHost => 'Target IP Address';

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
  String get lookingUp => 'Looking up...';

  @override
  String get pleaseEnterDomainName => 'Please enter a domain name';

  @override
  String get recordType => 'Record Type';

  @override
  String get dnsServer => 'DNS Server';

  @override
  String get dnsServerHelper => 'Leave empty to use router\'s DNS';

  @override
  String get dnsServerHelpText =>
      'Specify a custom DNS server to query (e.g., 8.8.8.8 for Google DNS, 1.1.1.1 for Cloudflare). Leave empty to use the router\'s configured DNS servers.';

  @override
  String get dnsLookupHelpText =>
      'DNS Lookup resolves domain names to IP addresses. Select a record type to query specific DNS records like A (IPv4), AAAA (IPv6), MX (mail servers), or TXT records.';

  @override
  String get timeoutHelpText =>
      'Maximum time to wait for a response from the DNS server. Increase if you\'re experiencing timeout errors.';

  @override
  String get records => 'Records';

  @override
  String get recordTypeHelp => 'DNS Record Types';

  @override
  String get recordTypeADesc =>
      'Returns the IPv4 address of a domain. Most common record type for website lookups.';

  @override
  String get recordTypeAAAADesc =>
      'Returns the IPv6 address of a domain. Used for modern IPv6 networks.';

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
  String get speedLimitTitle => 'Speed Limits';

  @override
  String get speedLimitDescription =>
      'Control download and upload speed for specific devices or networks';

  @override
  String get addSpeedLimit => 'Add Speed Limit';

  @override
  String get editSpeedLimit => 'Edit Speed Limit';

  @override
  String get deleteSpeedLimit => 'Delete Speed Limit';

  @override
  String get deleteSpeedLimitConfirm => 'Are you sure you want to delete';

  @override
  String get noSpeedLimits => 'No speed limits configured';

  @override
  String get speedLimitsCount => 'speed limit(s)';

  @override
  String get singleDevice => 'Single Device';

  @override
  String get networkDevices => 'Network Devices';

  @override
  String get speedUnits => 'Speed Units';

  @override
  String get readyTemplates => 'Ready Templates';

  @override
  String get templatesDescription => 'Quick setup with predefined settings';

  @override
  String get quickGuide => 'Quick Guide';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameExample => 'e.g., Office Manager, Guest Network';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get targetLabel => 'Device or Network';

  @override
  String get targetExample => '192.168.1.100 or 192.168.1.0/24';

  @override
  String get targetRequired => 'IP address is required';

  @override
  String get invalidIPFormat => 'Invalid IP address format';

  @override
  String get speedLimit => 'Speed Limit';

  @override
  String get download => 'Download';

  @override
  String get upload => 'Upload';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get commentOptional => 'Comment (Optional)';

  @override
  String get commentHint => 'Optional description';

  @override
  String get saving => 'Saving...';

  @override
  String get templateRegularUser => 'Regular User';

  @override
  String get templateRegularUserDesc => 'For regular users';

  @override
  String get templateGuestNetwork => 'Guest Network';

  @override
  String get templateGuestNetworkDesc => 'Limited for guests';

  @override
  String get templateVIPUser => 'VIP User';

  @override
  String get templateVIPUserDesc => 'For VIP users';

  @override
  String get templateServer => 'Server';

  @override
  String get templateServerDesc => 'For servers';

  @override
  String get templateCamera => 'Security Camera';

  @override
  String get templateCameraDesc => 'For cameras';

  @override
  String get priorityHigh => 'High Priority';

  @override
  String get priorityHighDesc => 'VoIP, video conferencing, servers';

  @override
  String get priorityMedium => 'Medium Priority';

  @override
  String get priorityMediumDesc => 'Web browsing, email, regular users';

  @override
  String get priorityLow => 'Low Priority';

  @override
  String get priorityLowDesc => 'Downloads, torrents, backups';

  @override
  String get priorityHighShort => 'High';

  @override
  String get priorityMediumShort => 'Medium';

  @override
  String get priorityLowShort => 'Low';

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
  String get liveLog => 'Live Log';

  @override
  String get logsTabInfo =>
      'Shows all router system logs. Logs are displayed from oldest (top) to newest (bottom). Use the filter button to narrow down logs by topics. Pull down to refresh.';

  @override
  String get liveLogTabInfo =>
      'Shows real-time log updates as they occur on the router. Starts empty and displays only new logs (max 500). Logs are displayed from oldest (top) to newest (bottom).';

  @override
  String get close => 'Close';

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

  @override
  String get pingQuickTip =>
      'For most tasks, you don\'t need advanced settings! Just enter the address and tap Start.';

  @override
  String get advancedOptions => 'Advanced Options';

  @override
  String get forAdvancedUsers => 'For advanced users';

  @override
  String get packetSize => 'Packet Size';

  @override
  String get packetSizeHelp =>
      'Data packet size in bytes.\n\n• Default: 56 bytes\n• Sufficient for normal testing\n• Use higher values (e.g., 1500) for MTU testing';

  @override
  String get ttl => 'TTL';

  @override
  String get ttlHelp =>
      'Maximum number of routers the packet can pass through.\n\n• Default: 64\n• Usually no need to change\n• Higher values mean lost packets take longer to detect';

  @override
  String get interval => 'Interval';

  @override
  String get intervalHelp =>
      'Time between sending each packet in seconds.\n\n• Default: 1 second\n• Lower = faster test\n• Higher = less network load';

  @override
  String get count => 'Count';

  @override
  String get countHelp =>
      'Total number of packets to send.\n\n• Default: 100\n• For quick test: 4 to 10\n• For stability test: 100+';

  @override
  String get sourceAddress => 'Source Address';

  @override
  String get sourceAddressHelp =>
      'IP address from which packets are sent.\n\n• Auto: Router chooses the best address\n• If you have multiple IPs, you can specify which one to use';

  @override
  String get interfaceHelp =>
      'Which network port to send packets from.\n\n• Auto: Router decides automatically\n• Useful when you have multiple routes to a destination\n• Select to test a specific port';

  @override
  String get doNotFragment => 'Do Not Fragment';

  @override
  String get doNotFragmentHelp =>
      'If enabled, packets won\'t be fragmented.\n\n• Used for testing network MTU\n• If packet is larger than MTU, it will fail\n• Usually not needed';

  @override
  String get forMtuTesting => 'For MTU testing';

  @override
  String get autoDefault => 'Auto (default)';

  @override
  String get liveStatistics => 'Live Statistics';

  @override
  String get sent => 'Sent';

  @override
  String get received => 'Received';

  @override
  String get loss => 'Loss';

  @override
  String successRate(String rate) {
    return '$rate% Success Rate';
  }

  @override
  String get roundTripTime => 'Round Trip Time';

  @override
  String get min => 'Min';

  @override
  String get avg => 'Avg';

  @override
  String get max => 'Max';

  @override
  String get packetHistory => 'Packet History';

  @override
  String packetsCount(int count) {
    return '$count packets';
  }

  @override
  String get waitingForPackets => 'Waiting for packets...';

  @override
  String get start => 'START';

  @override
  String get stop => 'STOP';

  @override
  String get pleaseEnterTarget => 'Please enter a target address';

  @override
  String get targetHostHint => 'e.g., 1.1.1.1 or 8.8.8.8';

  @override
  String get bytes => 'bytes';

  @override
  String get sec => 'sec';

  @override
  String get timeout => 'timeout';

  @override
  String get tracerouteQuickTip =>
      '💡 Traceroute shows the path packets take to reach an IP address. Note: Only IP addresses are supported, not domain names.';

  @override
  String get maxHopsLabel => 'Max Hops';

  @override
  String get maxHopsHelp =>
      'Maximum number of hops to trace.\n\n• Default: 30\n• Lower value = faster but may not reach destination\n• Higher value = can trace longer paths';

  @override
  String get countProbes => 'Probes per Hop';

  @override
  String get countProbesHelp =>
      'Number of probe packets sent per hop.\n\n• Default: 3\n• More probes = more accurate RTT statistics\n• Fewer probes = faster completion';

  @override
  String get timeoutMsLabel => 'Timeout';

  @override
  String get timeoutMsHelp =>
      'Time to wait for each probe response.\n\n• Default: 1000ms\n• Lower timeout = faster but may miss slow responses\n• Higher timeout = more accurate for high-latency paths';

  @override
  String get ms => 'ms';

  @override
  String get routePath => 'Route Path';

  @override
  String hopCount(int count) {
    return '$count hops';
  }

  @override
  String get totalTime => 'Total Time';

  @override
  String get targetReached => 'Target Reached';

  @override
  String get targetNotReached => 'Target Not Reached';

  @override
  String hopNumber(int number) {
    return 'Hop #$number';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get best => 'Best';

  @override
  String get worst => 'Worst';

  @override
  String get waitingForHops => 'Waiting for route discovery...';

  @override
  String tracerouteInProgress(String target) {
    return 'Tracing route to $target...';
  }

  @override
  String get hops => 'hops';

  @override
  String get wirelessManagementDescription =>
      'Manage wireless interfaces, clients, and security profiles';

  @override
  String get wirelessManagementHelpText =>
      'This section allows you to manage wireless interfaces, monitor connected clients, configure security profiles, and perform wireless network scans.';

  @override
  String get help => 'Help';

  @override
  String get ok => 'OK';
}
