import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/certificate.dart';
import '../bloc/certificate_bloc.dart';
import '../bloc/certificate_event.dart';
import '../bloc/certificate_state.dart';

class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CertificateBloc>().add(const LoadCertificates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CertificateBloc>().add(const RefreshCertificates());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCertificateDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Certificate'),
      ),
      body: BlocConsumer<CertificateBloc, CertificateState>(
        listener: (context, state) {
          if (state is CertificateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is CertificateOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            CertificateInitial() => const Center(child: CircularProgressIndicator()),
            CertificateLoading() => const Center(child: CircularProgressIndicator()),
            CertificateCreating(:final message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 8),
                    const Text(
                      'This may take a few seconds...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            CertificateLoaded(:final certificates) => _buildCertificatesList(certificates),
            CertificateOperationSuccess(:final certificates) => _buildCertificatesList(certificates),
            CertificateError() => const Center(child: Text('Error loading certificates')),
          };
        },
      ),
    );
  }

  Widget _buildCertificatesList(List<Certificate> certificates) {
    if (certificates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No certificates found'),
            const SizedBox(height: 8),
            const Text(
              'Create a self-signed certificate to use with API-SSL',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateCertificateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Certificate'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CertificateBloc>().add(const RefreshCertificates());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          final theme = Theme.of(context);
          return _buildCertificateCard(context, cert, theme);
        },
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, Certificate cert, ThemeData theme) {
    final isValid = cert.isValid;
    final canUseForSsl = cert.canBeUsedForSsl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isValid
              ? (canUseForSsl ? Colors.green.withAlpha(51) : Colors.blue.withAlpha(51))
              : Colors.red.withAlpha(51),
          child: Icon(
            cert.ca ? Icons.verified : Icons.security,
            color: isValid
                ? (canUseForSsl ? Colors.green : Colors.blue)
                : Colors.red,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                cert.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (cert.expired)
              _buildBadge('EXPIRED', Colors.red),
            if (cert.revoked)
              _buildBadge('REVOKED', Colors.orange),
            if (canUseForSsl)
              _buildBadge('SSL Ready', Colors.green),
          ],
        ),
        subtitle: Text(
          cert.commonName ?? 'No common name',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Common Name', cert.commonName ?? 'N/A'),
                if (cert.issuer != null)
                  _buildInfoRow('Issuer', cert.issuer!),
                _buildInfoRow('Key Size', '${cert.keySize ?? "N/A"} bits'),
                if (cert.daysValid != null)
                  _buildInfoRow('Days Valid', cert.daysValid.toString()),
                
                const SizedBox(height: 8),
                
                // Status badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (cert.privateKey)
                      _buildStatusChip('Private Key', Icons.key, Colors.green),
                    if (cert.trusted)
                      _buildStatusChip('Trusted', Icons.verified_user, Colors.blue),
                    if (cert.ca)
                      _buildStatusChip('CA', Icons.account_tree, Colors.purple),
                    if (cert.isSelfSigned)
                      _buildStatusChip('Self-Signed', Icons.person, Colors.orange),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showCertificateDetails(context, cert),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Details'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, cert),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withAlpha(26),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showCreateCertificateDialog(BuildContext context) {
    final nameController = TextEditingController(text: 'api-ssl-cert');
    final commonNameController = TextEditingController(text: 'router');
    int keySize = 2048;
    int daysValid = 365;
    // Capture the bloc before showing dialog to avoid context issues
    final certificateBloc = context.read<CertificateBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Create Self-Signed Certificate'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Certificate Name',
                        hintText: 'e.g., api-ssl-cert',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commonNameController,
                      decoration: const InputDecoration(
                        labelText: 'Common Name (CN)',
                        hintText: 'e.g., router.local',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: keySize,
                      decoration: const InputDecoration(
                        labelText: 'Key Size',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1024, child: Text('1024 bits')),
                        DropdownMenuItem(value: 2048, child: Text('2048 bits (Recommended)')),
                        DropdownMenuItem(value: 4096, child: Text('4096 bits')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          keySize = value ?? 2048;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: daysValid,
                      decoration: const InputDecoration(
                        labelText: 'Validity Period',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 90, child: Text('90 days')),
                        DropdownMenuItem(value: 365, child: Text('1 year')),
                        DropdownMenuItem(value: 730, child: Text('2 years')),
                        DropdownMenuItem(value: 1825, child: Text('5 years')),
                        DropdownMenuItem(value: 3650, child: Text('10 years')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          daysValid = value ?? 365;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && commonNameController.text.isNotEmpty) {
                      certificateBloc.add(
                        CreateSelfSignedCertificate(
                          name: nameController.text,
                          commonName: commonNameController.text,
                          keySize: keySize,
                          daysValid: daysValid,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCertificateDetails(BuildContext context, Certificate cert) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.security),
              const SizedBox(width: 8),
              Expanded(child: Text(cert.name)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Name', cert.name),
                _buildDetailRow('Common Name', cert.commonName ?? 'N/A'),
                _buildDetailRow('Country', cert.country ?? 'N/A'),
                _buildDetailRow('Organization', cert.organization ?? 'N/A'),
                _buildDetailRow('Issuer', cert.issuer ?? 'N/A'),
                _buildDetailRow('Key Size', '${cert.keySize ?? "N/A"} bits'),
                _buildDetailRow('Key Type', cert.keyType ?? 'N/A'),
                _buildDetailRow('Days Valid', cert.daysValid?.toString() ?? 'N/A'),
                _buildDetailRow('Serial Number', cert.serialNumber ?? 'N/A'),
                if (cert.fingerprint != null)
                  _buildDetailRow('Fingerprint', cert.fingerprint!),
                const Divider(),
                _buildDetailRow('Private Key', cert.privateKey ? 'Yes' : 'No'),
                _buildDetailRow('Trusted', cert.trusted ? 'Yes' : 'No'),
                _buildDetailRow('CA', cert.ca ? 'Yes' : 'No'),
                _buildDetailRow('Expired', cert.expired ? 'Yes' : 'No'),
                _buildDetailRow('Revoked', cert.revoked ? 'Yes' : 'No'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Certificate cert) {
    // Check if this is a CA certificate
    final isCA = cert.ca || 
                 cert.name.toLowerCase().contains('ca') ||
                 (cert.commonName?.toLowerCase().contains('ca') ?? false);
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            isCA ? Icons.gpp_bad : Icons.warning_amber, 
            color: Colors.red, 
            size: 48,
          ),
          title: Text(isCA ? 'Delete Certificate Authority?' : 'Delete Certificate?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${cert.name}"?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (isCA) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Important Warning!',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• This is a Certificate Authority',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '• Certificates signed by this CA may become invalid',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '• You won\'t be able to create new certificates until a new CA is created',
                        style: TextStyle(fontSize: 13),
                      ),
                      Text(
                        '• SSL services may stop working',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.red, fontSize: 12),
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
                context.read<CertificateBloc>().add(DeleteCertificate(cert.id));
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(isCA ? 'Delete CA' : 'Delete'),
            ),
          ],
        );
      },
    );
  }
}
