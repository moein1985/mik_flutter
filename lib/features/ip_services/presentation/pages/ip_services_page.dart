import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/logger.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../domain/entities/ip_service.dart';
import '../bloc/ip_service_bloc.dart';
import '../bloc/ip_service_event.dart';
import '../bloc/ip_service_state.dart';

final _log = AppLogger.tag('IpServicesPage');

class IpServicesPage extends StatefulWidget {
  const IpServicesPage({super.key});

  @override
  State<IpServicesPage> createState() => _IpServicesPageState();
}

class _IpServicesPageState extends State<IpServicesPage> {
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
    context.read<IpServiceBloc>().add(const LoadIpServices());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Services',
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<IpServiceBloc>().add(const RefreshIpServices());
            },
          ),
        ],
      ),
      body: BlocConsumer<IpServiceBloc, IpServiceState>(
        listener: (context, state) {
          if (state is IpServiceError) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else if (state is IpServiceOperationSuccess) {
            if (_lastShownMessage != state.message) {
              _lastShownMessage = state.message;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            _lastShownMessage = null;
          }
        },
        builder: (context, state) {
          return switch (state) {
            IpServiceInitial() => const Center(child: CircularProgressIndicator()),
            IpServiceLoading() => const Center(child: CircularProgressIndicator()),
            IpServiceCreatingCertificate() => _buildCreatingCertificateView(state, colorScheme),
            IpServiceLoaded(:final services, :final availableCertificates) => 
              services.isEmpty 
                ? _buildEmptyView(colorScheme)
                : _buildServicesList(services, availableCertificates, colorScheme),
            IpServiceOperationSuccess(:final services, :final availableCertificates) =>
              services.isEmpty
                ? _buildEmptyView(colorScheme)
                : _buildServicesList(services, availableCertificates, colorScheme),
            IpServiceError() => _buildEmptyView(colorScheme),
          };
        },
      ),
    );
  }

  Widget _buildQuickTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.dns, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Manage router access services. Enable/disable or configure ports and certificates for secure connections.',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.dns, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('IP Services'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildServiceInfoItem(Icons.api, 'API', 'REST API access (default: 8728)', Colors.blue),
              _buildServiceInfoItem(Icons.lock, 'API-SSL', 'Secure REST API access (default: 8729)', Colors.green),
              _buildServiceInfoItem(Icons.web, 'WWW', 'Web interface (default: 80)', Colors.blue),
              _buildServiceInfoItem(Icons.https, 'WWW-SSL', 'Secure web interface (default: 443)', Colors.green),
              _buildServiceInfoItem(Icons.desktop_windows, 'Winbox', 'Winbox management (default: 8291)', Colors.purple),
              _buildServiceInfoItem(Icons.terminal, 'SSH', 'Secure shell access (default: 22)', Colors.teal),
              _buildServiceInfoItem(Icons.computer, 'Telnet', 'Telnet access - insecure (default: 23)', Colors.grey),
              _buildServiceInfoItem(Icons.folder_open, 'FTP', 'File transfer (default: 21)', Colors.amber),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfoItem(IconData icon, String name, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatingCertificateView(IpServiceCreatingCertificate state, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(color: Colors.teal),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security, size: 48, color: Colors.teal),
          ),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait...',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickTipCard(),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dns_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load router services',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.read<IpServiceBloc>().add(const LoadIpServices());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(List<IpService> services, List<Certificate> certificates, ColorScheme colorScheme) {
    // Filter to show only important services
    final importantServices = services.where((s) => 
      ['api', 'api-ssl', 'www', 'www-ssl', 'winbox', 'ssh', 'telnet', 'ftp']
          .contains(s.name)).toList();
    
    // Sort: enabled first, then by name
    importantServices.sort((a, b) {
      if (a.isEnabled != b.isEnabled) {
        return a.isEnabled ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });

    // Count enabled/disabled
    final enabledCount = importantServices.where((s) => s.isEnabled).length;
    final disabledCount = importantServices.length - enabledCount;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<IpServiceBloc>().add(const RefreshIpServices());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQuickTipCard(),
            
            const SizedBox(height: 16),
            
            // Count summary
            _buildCountSummary(importantServices.length, enabledCount, disabledCount, colorScheme),
            
            const SizedBox(height: 16),
            
            // Service cards
            ...importantServices.map((service) => 
              _buildServiceCard(context, service, colorScheme, certificates)),
            
            // Bottom spacing
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCountSummary(int total, int enabled, int disabled, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$total service${total > 1 ? 's' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (enabled > 0)
            _buildMiniTag('$enabled Active', Colors.green),
          if (disabled > 0) ...[
            const SizedBox(width: 8),
            _buildMiniTag('$disabled Disabled', Colors.grey),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, IpService service, ColorScheme colorScheme, List<Certificate> certificates) {
    final isApiSsl = service.name == 'api-ssl';
    final isWwwSsl = service.name == 'www-ssl';
    final needsCertificate = isApiSsl || isWwwSsl;
    final hasCertificateIssue = needsCertificate && service.isCertificateMissing;
    final serviceColor = _getServiceColor(service);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: service.isEnabled 
              ? colorScheme.outline.withAlpha(51)
              : colorScheme.outline.withAlpha(26),
        ),
      ),
      child: Opacity(
        opacity: service.isEnabled ? 1.0 : 0.7,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: service.isEnabled 
                    ? serviceColor.withAlpha(26) 
                    : Colors.grey.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getServiceIcon(service.name),
                color: service.isEnabled ? serviceColor : Colors.grey,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Text(
                  service.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (hasCertificateIssue)
                  Tooltip(
                    message: 'Certificate not configured',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(26),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  // Status dot
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: service.isEnabled ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Port: ${service.port}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (service.address.isNotEmpty) ...[
                    Text(
                      ' • ${service.address}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing: Switch(
              value: service.isEnabled,
              onChanged: (value) {
                if (value && hasCertificateIssue) {
                  _showCertificateWarningDialog(context, service);
                } else {
                  context.read<IpServiceBloc>().add(
                    ToggleServiceEnabled(serviceId: service.id, enabled: value),
                  );
                }
              },
            ),
            children: [
              const Divider(),
              const SizedBox(height: 8),
              
              // Settings Section
              _buildSectionTitle('Settings', Icons.tune, colorScheme),
              const SizedBox(height: 8),
              
              // Port setting
              _buildSettingRow(
                context,
                'Port',
                service.port.toString(),
                Icons.numbers,
                () => _showEditPortDialog(context, service),
                colorScheme,
              ),
              
              // Address restriction
              _buildSettingRow(
                context,
                'Address',
                service.address.isEmpty ? 'All addresses' : service.address,
                Icons.public,
                () => _showEditAddressDialog(context, service),
                colorScheme,
              ),
              
              // VRF
              if (service.vrf != null && service.vrf!.isNotEmpty)
                _buildInfoRow('VRF', service.vrf!, colorScheme),
              
              // Max sessions
              if (service.maxSessions != null)
                _buildInfoRow('Max Sessions', service.maxSessions.toString(), colorScheme),
              
              // TLS version (for SSL services)
              if (service.tlsVersion != null && service.tlsVersion!.isNotEmpty)
                _buildInfoRow('TLS Version', service.tlsVersion!, colorScheme),
              
              // Certificate (for SSL services)
              if (needsCertificate) ...[
                const SizedBox(height: 16),
                _buildCertificateSection(context, service, certificates, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case 'api':
        return Icons.api;
      case 'api-ssl':
        return Icons.lock;
      case 'www':
        return Icons.web;
      case 'www-ssl':
        return Icons.https;
      case 'winbox':
        return Icons.desktop_windows;
      case 'ssh':
        return Icons.terminal;
      case 'telnet':
        return Icons.computer;
      case 'ftp':
        return Icons.folder_open;
      default:
        return Icons.settings_ethernet;
    }
  }

  Color _getServiceColor(IpService service) {
    switch (service.name) {
      case 'api':
        return Colors.blue;
      case 'api-ssl':
        return service.isCertificateMissing ? Colors.orange : Colors.green;
      case 'www':
        return Colors.blue;
      case 'www-ssl':
        return service.isCertificateMissing ? Colors.orange : Colors.green;
      case 'winbox':
        return Colors.purple;
      case 'ssh':
        return Colors.teal;
      case 'telnet':
        return Colors.grey;
      case 'ftp':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSettingRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
    ColorScheme colorScheme, {
    Color? valueColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(77),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 16, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCertificateSection(
    BuildContext context,
    IpService service,
    List<Certificate> certificates,
    ColorScheme colorScheme,
  ) {
    final currentCert = service.certificate;
    final hasCertificate = currentCert != null && currentCert.isNotEmpty && currentCert != 'none';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasCertificate 
            ? Colors.green.withAlpha(13)
            : Colors.orange.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasCertificate ? Colors.green.withAlpha(77) : Colors.orange.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (hasCertificate ? Colors.green : Colors.orange).withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasCertificate ? Icons.verified : Icons.warning_amber,
                  color: hasCertificate ? Colors.green : Colors.orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Certificate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasCertificate ? Colors.green : Colors.orange,
                ),
              ),
              const Spacer(),
              if (hasCertificate)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentCert,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Certificate dropdown
          if (certificates.isNotEmpty) ...[
            Text(
              'Select Certificate:',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline.withAlpha(77)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: hasCertificate && certificates.any((c) => c.name == currentCert)
                      ? currentCert
                      : null,
                  isExpanded: true,
                  hint: const Text('Choose a certificate...'),
                  items: [
                    ...certificates.map((cert) => DropdownMenuItem(
                      value: cert.name,
                      child: Row(
                        children: [
                          Icon(
                            cert.name == currentCert 
                                ? Icons.check_circle 
                                : Icons.security,
                            size: 16,
                            color: cert.name == currentCert 
                                ? Colors.green 
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cert.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (value) {
                    if (value != null && value != currentCert) {
                      _log.i('User selected certificate: $value for service: ${service.name}');
                      context.read<IpServiceBloc>().add(
                        UpdateServiceCertificate(
                          serviceId: service.name,
                          certificateName: value,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // No certificates message
          if (certificates.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No certificates available. Create one below or in Certificates page.',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCreateCertificateForApiSslDialog(context, service),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create New'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.certificates),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Manage'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _log.i('Refreshing certificates list');
                  context.read<IpServiceBloc>().add(const LoadAvailableCertificates());
                },
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh certificates',
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditPortDialog(BuildContext context, IpService service) {
    final controller = TextEditingController(text: service.port.toString());
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.numbers, color: colorScheme.primary),
          title: Text('Edit ${service.name.toUpperCase()} Port'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText: 'Enter port number (1-65535)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final port = int.tryParse(controller.text);
                if (port != null && port > 0 && port <= 65535) {
                  context.read<IpServiceBloc>().add(
                    UpdateServicePort(serviceId: service.id, port: port),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAddressDialog(BuildContext context, IpService service) {
    final controller = TextEditingController(text: service.address);
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.public, color: colorScheme.primary),
          title: Text('Edit ${service.name.toUpperCase()} Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'e.g., 192.168.1.0/24',
                  helperText: 'Leave empty for all addresses',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.public),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                context.read<IpServiceBloc>().add(
                  UpdateServiceAddress(
                    serviceId: service.id,
                    address: controller.text,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCertificateWarningDialog(BuildContext context, IpService service) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
          ),
          title: const Text('Certificate Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The ${service.name.toUpperCase()} service requires a certificate to work.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Without a certificate, clients will not be able to connect securely.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What would you like to do?',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                // Enable anyway without certificate
                context.read<IpServiceBloc>().add(
                  ToggleServiceEnabled(serviceId: service.id, enabled: true),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Enable Anyway'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Show dialog to create certificate automatically
                _showCreateCertificateForApiSslDialog(context, service);
              },
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto Create'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateCertificateForApiSslDialog(BuildContext context, IpService service) {
    final nameController = TextEditingController(text: 'api-ssl-cert');
    final commonNameController = TextEditingController(text: 'router');
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security, color: Colors.teal, size: 32),
          ),
          title: const Text('Create Certificate for API-SSL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A self-signed certificate will be created and automatically assigned to the api-ssl service.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Certificate Name',
                  hintText: 'e.g., api-ssl-cert',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commonNameController,
                decoration: const InputDecoration(
                  labelText: 'Common Name (CN)',
                  hintText: 'e.g., router.local',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.dns_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.amber, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This process may take up to 60 seconds.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                if (nameController.text.isNotEmpty && commonNameController.text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  context.read<IpServiceBloc>().add(
                    CreateAndAssignCertificateForApiSsl(
                      serviceId: service.id,
                      certificateName: nameController.text,
                      commonName: commonNameController.text,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Create & Assign'),
            ),
          ],
        );
      },
    );
  }
}
