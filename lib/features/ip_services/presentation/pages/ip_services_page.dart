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
  @override
  void initState() {
    super.initState();
    context.read<IpServiceBloc>().add(const LoadIpServices());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<IpServiceBloc>().add(const RefreshIpServices());
            },
          ),
        ],
      ),
      body: BlocConsumer<IpServiceBloc, IpServiceState>(
        listener: (context, state) {
          if (state is IpServiceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is IpServiceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is IpServiceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IpServiceCreatingCertificate) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Icon(Icons.security, size: 48, color: Colors.teal),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please wait...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<IpService> services = [];
          List<Certificate> certificates = [];
          if (state is IpServiceLoaded) {
            services = state.services;
            certificates = state.availableCertificates;
          } else if (state is IpServiceOperationSuccess) {
            services = state.services;
            certificates = state.availableCertificates;
          }

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dns_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No services found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<IpServiceBloc>().add(const LoadIpServices());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

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

          return RefreshIndicator(
            onRefresh: () async {
              context.read<IpServiceBloc>().add(const RefreshIpServices());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: importantServices.length,
              itemBuilder: (context, index) {
                final service = importantServices[index];
                return _buildServiceCard(context, service, theme, certificates);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, IpService service, ThemeData theme, List<Certificate> certificates) {
    final isApiSsl = service.name == 'api-ssl';
    final isWwwSsl = service.name == 'www-ssl';
    final needsCertificate = isApiSsl || isWwwSsl;
    final hasCertificateIssue = needsCertificate && service.isCertificateMissing;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: _getServiceIcon(service),
        title: Row(
          children: [
            Text(
              service.name.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (hasCertificateIssue)
              Tooltip(
                message: 'Certificate not configured',
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
          ],
        ),
        subtitle: Text(
          'Port: ${service.port}${service.address.isNotEmpty ? ' • ${service.address}' : ''}',
          style: TextStyle(color: Colors.grey[600]),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Port setting
                _buildSettingRow(
                  context,
                  'Port',
                  service.port.toString(),
                  Icons.numbers,
                  () => _showEditPortDialog(context, service),
                ),
                
                // Address restriction
                _buildSettingRow(
                  context,
                  'Address',
                  service.address.isEmpty ? 'All addresses' : service.address,
                  Icons.public,
                  () => _showEditAddressDialog(context, service),
                ),
                
                // Certificate (for SSL services)
                if (needsCertificate)
                  _buildCertificateSection(context, service, certificates),
                
                // VRF
                if (service.vrf != null && service.vrf!.isNotEmpty)
                  _buildInfoRow('VRF', service.vrf!),
                
                // Max sessions
                if (service.maxSessions != null)
                  _buildInfoRow('Max Sessions', service.maxSessions.toString()),
                
                // TLS version (for SSL services)
                if (service.tlsVersion != null && service.tlsVersion!.isNotEmpty)
                  _buildInfoRow('TLS Version', service.tlsVersion!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getServiceIcon(IpService service) {
    IconData icon;
    Color color;

    switch (service.name) {
      case 'api':
        icon = Icons.api;
        color = Colors.blue;
        break;
      case 'api-ssl':
        icon = Icons.lock;
        color = service.isCertificateMissing ? Colors.orange : Colors.green;
        break;
      case 'www':
        icon = Icons.web;
        color = Colors.blue;
        break;
      case 'www-ssl':
        icon = Icons.https;
        color = service.isCertificateMissing ? Colors.orange : Colors.green;
        break;
      case 'winbox':
        icon = Icons.desktop_windows;
        color = Colors.purple;
        break;
      case 'ssh':
        icon = Icons.terminal;
        color = Colors.teal;
        break;
      case 'telnet':
        icon = Icons.computer;
        color = Colors.grey;
        break;
      case 'ftp':
        icon = Icons.folder_open;
        color = Colors.amber;
        break;
      default:
        icon = Icons.settings_ethernet;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: service.isEnabled 
          ? color.withOpacity(0.2) 
          : Colors.grey.withOpacity(0.2),
      child: Icon(
        icon,
        color: service.isEnabled ? color : Colors.grey,
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap, {
    Color? valueColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
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
  ) {
    final currentCert = service.certificate;
    final hasCertificate = currentCert != null && currentCert.isNotEmpty && currentCert != 'none';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasCertificate 
            ? Colors.green.withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasCertificate ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                hasCertificate ? Icons.verified : Icons.warning_amber,
                color: hasCertificate ? Colors.green : Colors.orange,
                size: 20,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
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
            const Text(
              'Select Certificate:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                                : Colors.grey,
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
                      _log.i('User selected certificate: $value for service: ${service.id}');
                      context.read<IpServiceBloc>().add(
                        UpdateServiceCertificate(
                          serviceId: service.id,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No certificates available. Create one below or in Certificates page.',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Create new certificate button
              OutlinedButton.icon(
                onPressed: () => _showCreateCertificateForApiSslDialog(context, service),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create New'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              // Go to certificates page
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.certificates),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Manage'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              // Refresh certificates
              IconButton(
                onPressed: () {
                  _log.i('Refreshing certificates list');
                  context.read<IpServiceBloc>().add(const LoadAvailableCertificates());
                },
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Refresh certificates',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditPortDialog(BuildContext context, IpService service) {
    final controller = TextEditingController(text: service.port.toString());
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit ${service.name.toUpperCase()} Port'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Port',
              hintText: 'Enter port number',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.warning_amber, color: Colors.orange, size: 48),
          title: const Text('Certificate Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The ${service.name.toUpperCase()} service requires a certificate to work.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Without a certificate, clients will not be able to connect securely.',
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
            ElevatedButton.icon(
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.security, color: Colors.teal, size: 48),
          title: const Text('Create Certificate for API-SSL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A self-signed certificate will be created and automatically assigned to the api-ssl service.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Certificate Name',
                  hintText: 'e.g., api-ssl-cert',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commonNameController,
                decoration: const InputDecoration(
                  labelText: 'Common Name (CN)',
                  hintText: 'e.g., router.local',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
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
            ElevatedButton.icon(
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
