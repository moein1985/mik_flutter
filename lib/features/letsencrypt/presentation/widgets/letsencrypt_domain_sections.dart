import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/precheck_result.dart';
import '../bloc/letsencrypt_bloc.dart';
import '../bloc/letsencrypt_event.dart';

/// Domain section for Hardware RouterBOARD (with Cloud DDNS support)
class HardwareRouterDomainSection extends StatelessWidget {
  final PreCheckResult result;
  final TextEditingController dnsNameController;
  final bool useCloudDdns;
  final ValueChanged<bool> onUseCloudDdnsChanged;

  const HardwareRouterDomainSection({
    super.key,
    required this.result,
    required this.dnsNameController,
    required this.useCloudDdns,
    required this.onUseCloudDdnsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cloudCheck = result.getCheck(PreCheckType.cloudEnabled);
    final dnsCheck = result.getCheck(PreCheckType.dnsAvailable);
    final cloudEnabled = cloudCheck?.passed ?? false;
    final dnsAvailable = dnsCheck?.passed ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.letsEncryptDomainSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCloudDdnsOption(context, l10n, cloudEnabled, dnsAvailable),
            const SizedBox(height: 12),
            _buildCustomDomainOption(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudDdnsOption(
    BuildContext context,
    AppLocalizations l10n,
    bool cloudEnabled,
    bool dnsAvailable,
  ) {
    return InkWell(
      onTap: () => onUseCloudDdnsChanged(true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: useCloudDdns ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: useCloudDdns ? Colors.green : Colors.grey.shade300,
            width: useCloudDdns ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  // ignore: deprecated_member_use
                  child: Radio<bool>(
                    value: true,
                    // ignore: deprecated_member_use
                    groupValue: useCloudDdns,
                    // ignore: deprecated_member_use
                    onChanged: (v) => onUseCloudDdnsChanged(v!),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.letsEncryptUseCloudDdns,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (cloudEnabled && dnsAvailable)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            if (useCloudDdns) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: _buildCloudDdnsContent(context, l10n, cloudEnabled, dnsAvailable),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCloudDdnsContent(
    BuildContext context,
    AppLocalizations l10n,
    bool cloudEnabled,
    bool dnsAvailable,
  ) {
    if (dnsAvailable && result.dnsName != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  result.dnsName!,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.letsEncryptCloudDdnsDesc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      );
    } else if (!cloudEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.read<LetsEncryptBloc>().add(
                    AutoFixIssue(PreCheckType.cloudEnabled),
                  );
            },
            icon: const Icon(Icons.cloud, size: 18),
            label: Text(l10n.letsEncryptEnableCloudDdns),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.letsEncryptCloudDdnsDesc,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.letsEncryptCloudDdnsWaiting,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      );
    }
  }

  Widget _buildCustomDomainOption(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => onUseCloudDdnsChanged(false),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: !useCloudDdns ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: !useCloudDdns ? Colors.green : Colors.grey.shade300,
            width: !useCloudDdns ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  // ignore: deprecated_member_use
                  child: Radio<bool>(
                    value: false,
                    // ignore: deprecated_member_use
                    groupValue: useCloudDdns,
                    // ignore: deprecated_member_use
                    onChanged: (v) => onUseCloudDdnsChanged(v!),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.letsEncryptUseCustomDomain,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (!useCloudDdns && dnsNameController.text.trim().isNotEmpty)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
            if (!useCloudDdns) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: dnsNameController,
                      decoration: InputDecoration(
                        hintText: l10n.letsEncryptDomainPlaceholder,
                        border: const OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: const Icon(Icons.language, size: 20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.letsEncryptCustomDomainDesc,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Domain section for Virtual x86/CHR routers (no Cloud DDNS)
class VirtualRouterDomainSection extends StatelessWidget {
  final PreCheckResult result;
  final TextEditingController dnsNameController;
  final VoidCallback onDomainChanged;

  const VirtualRouterDomainSection({
    super.key,
    required this.result,
    required this.dnsNameController,
    required this.onDomainChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasValidDomain = dnsNameController.text.trim().isNotEmpty;

    return Column(
      children: [
        _buildWarningCard(l10n),
        const SizedBox(height: 16),
        _buildDomainInputCard(context, l10n, theme, hasValidDomain),
      ],
    );
  }

  Widget _buildWarningCard(AppLocalizations l10n) {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_off, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.letsEncryptCloudNotSupportedTitle,
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.letsEncryptCloudNotSupportedMessage,
              style: TextStyle(color: Colors.orange.shade900, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.letsEncryptDontWorry,
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainInputCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    bool hasValidDomain,
  ) {
    return Card(
      color: hasValidDomain ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n, theme, hasValidDomain),
            const SizedBox(height: 16),
            _buildDomainInput(l10n),
            if (result.publicIp != null) ..._buildIpInfo(l10n),
            const SizedBox(height: 16),
            _buildHelpSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme, bool hasValidDomain) {
    return Row(
      children: [
        Icon(
          Icons.dns,
          color: hasValidDomain ? Colors.green.shade700 : theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.letsEncryptCustomDomainRequired,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasValidDomain ? Colors.green.shade700 : null,
            ),
          ),
        ),
        if (hasValidDomain)
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
      ],
    );
  }

  Widget _buildDomainInput(AppLocalizations l10n) {
    return TextField(
      controller: dnsNameController,
      decoration: InputDecoration(
        hintText: l10n.letsEncryptDomainPlaceholder,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.language),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (_) => onDomainChanged(),
    );
  }

  List<Widget> _buildIpInfo(AppLocalizations l10n) {
    return [
      const SizedBox(height: 12),
      Text(
        l10n.letsEncryptDomainMustPointTo,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Colors.blue.shade700, size: 16),
            const SizedBox(width: 8),
            Text(
              '${l10n.letsEncryptYourIp}: ${result.publicIp}',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildHelpSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Colors.grey.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.letsEncryptNoFreeDomain,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.letsEncryptFreeDomainProviders,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ActionChip(
                avatar: const Text('🦆', style: TextStyle(fontSize: 20)),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.letsEncryptDuckDnsSimple),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new, size: 14),
                  ],
                ),
                onPressed: () async {
                  final url = Uri.parse('https://www.duckdns.org');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open DuckDNS website'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
