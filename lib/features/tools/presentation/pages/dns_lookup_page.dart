import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/dns_lookup_result.dart';
import '../bloc/tools_bloc.dart';
import '../bloc/tools_event.dart';
import '../bloc/tools_state.dart';

/// DNS Record types supported by RouterOS
enum DnsRecordType {
  a('A', 'IPv4 Address'),
  aaaa('AAAA', 'IPv6 Address'),
  mx('MX', 'Mail Exchange'),
  txt('TXT', 'Text Record'),
  cname('CNAME', 'Canonical Name'),
  ns('NS', 'Name Server'),
  soa('SOA', 'Start of Authority'),
  ptr('PTR', 'Pointer Record'),
  srv('SRV', 'Service Record');

  final String code;
  final String description;
  const DnsRecordType(this.code, this.description);
}

class DnsLookupPage extends StatefulWidget {
  const DnsLookupPage({super.key});

  @override
  State<DnsLookupPage> createState() => _DnsLookupPageState();
}

class _DnsLookupPageState extends State<DnsLookupPage> {
  final _domainController = TextEditingController();
  final _dnsServerController = TextEditingController();
  final _timeoutController = TextEditingController(text: '5000');
  
  bool _showAdvancedOptions = false;
  bool _isRunning = false;
  DnsRecordType _selectedRecordType = DnsRecordType.a;

  @override
  void dispose() {
    _domainController.dispose();
    _dnsServerController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  void _startLookup() {
    final l10n = AppLocalizations.of(context)!;
    if (_domainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterDomainName)),
      );
      return;
    }

    setState(() => _isRunning = true);

    context.read<ToolsBloc>().add(StartDnsLookup(
      domain: _domainController.text.trim(),
      timeout: int.tryParse(_timeoutController.text) ?? 5000,
      recordType: _selectedRecordType.code,
      dnsServer: _dnsServerController.text.trim().isNotEmpty 
          ? _dnsServerController.text.trim() 
          : null,
    ));
  }

  void _showHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpIcon(String title, String content) {
    return IconButton(
      icon: Icon(Icons.help_outline, size: 20, color: Colors.grey.shade600),
      onPressed: () => _showHelpDialog(title, content),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dnsLookup),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ToolsBloc>().add(const ClearResults());
              setState(() => _isRunning = false);
            },
            tooltip: l10n.clearResults,
          ),
        ],
      ),
      body: BlocConsumer<ToolsBloc, ToolsState>(
        listener: (context, state) {
          if (state is DnsLookupFailed) {
            setState(() => _isRunning = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DnsLookupCompleted) {
            setState(() => _isRunning = false);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Domain Name Input
                _buildInputCard(l10n, colorScheme),
                
                const SizedBox(height: 16),
                
                // Advanced Options
                _buildAdvancedOptions(l10n, colorScheme),
                
                const SizedBox(height: 16),
                
                // Start/Stop Button
                _buildActionButton(l10n, colorScheme),
                
                const SizedBox(height: 24),
                
                // Results Section
                if (state is DnsLookupInProgress)
                  _buildLoadingIndicator(l10n)
                else if (state is DnsLookupCompleted)
                  _buildResultsCard(state.result, l10n, colorScheme)
                else if (state is DnsLookupFailed)
                  _buildErrorCard(state.error, l10n),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dns, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.dnsLookup,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildHelpIcon(
                  l10n.dnsLookup,
                  l10n.dnsLookupHelpText,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Domain Name Field
            TextField(
              controller: _domainController,
              decoration: InputDecoration(
                labelText: l10n.domainName,
                hintText: 'google.com',
                prefixIcon: const Icon(Icons.language),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _startLookup(),
            ),
            
            const SizedBox(height: 16),
            
            // Record Type Dropdown with Help
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<DnsRecordType>(
                    value: _selectedRecordType,
                    decoration: InputDecoration(
                      labelText: l10n.recordType,
                      prefixIcon: const Icon(Icons.category),
                      border: const OutlineInputBorder(),
                    ),
                    items: DnsRecordType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text('${type.code} - ${type.description}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedRecordType = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey.shade600),
                    onPressed: () => _showRecordTypesHelp(l10n),
                    tooltip: l10n.recordTypeHelp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordTypesHelp(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.recordTypeHelp)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRecordTypeItem('A', l10n.recordTypeADesc),
              _buildRecordTypeItem('AAAA', l10n.recordTypeAAAADesc),
              _buildRecordTypeItem('MX', l10n.recordTypeMXDesc),
              _buildRecordTypeItem('TXT', l10n.recordTypeTXTDesc),
              _buildRecordTypeItem('CNAME', l10n.recordTypeCNAMEDesc),
              _buildRecordTypeItem('NS', l10n.recordTypeNSDesc),
              _buildRecordTypeItem('SOA', l10n.recordTypeSOADesc),
              _buildRecordTypeItem('PTR', l10n.recordTypePTRDesc),
              _buildRecordTypeItem('SRV', l10n.recordTypeSRVDesc),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTypeItem(String type, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions(AppLocalizations l10n, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.primary),
            title: Text(l10n.advancedOptions),
            trailing: IconButton(
              icon: Icon(
                _showAdvancedOptions 
                    ? Icons.expand_less 
                    : Icons.expand_more,
              ),
              onPressed: () {
                setState(() => _showAdvancedOptions = !_showAdvancedOptions);
              },
            ),
            onTap: () {
              setState(() => _showAdvancedOptions = !_showAdvancedOptions);
            },
          ),
          if (_showAdvancedOptions) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DNS Server Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dnsServerController,
                          decoration: InputDecoration(
                            labelText: l10n.dnsServer,
                            hintText: '8.8.8.8',
                            prefixIcon: const Icon(Icons.dns_outlined),
                            border: const OutlineInputBorder(),
                            helperText: l10n.dnsServerHelper,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildHelpIcon(
                        l10n.dnsServer,
                        l10n.dnsServerHelpText,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Timeout Field
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _timeoutController,
                          decoration: InputDecoration(
                            labelText: l10n.timeoutMs,
                            prefixIcon: const Icon(Icons.timer),
                            border: const OutlineInputBorder(),
                            suffixText: 'ms',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildHelpIcon(
                        l10n.timeoutMs,
                        l10n.timeoutHelpText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(AppLocalizations l10n, ColorScheme colorScheme) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isRunning ? null : _startLookup,
        icon: _isRunning 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.search),
        label: Text(
          _isRunning ? l10n.lookingUp : l10n.lookupDns,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.lookingUp),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(DnsLookupResult result, AppLocalizations l10n, ColorScheme colorScheme) {
    final hasResults = result.hasResults;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  hasResults ? Icons.check_circle : Icons.error,
                  color: hasResults ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.dnsResults,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (result.responseTime != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${result.responseTime!.inMilliseconds}ms',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Domain Info
            _buildInfoRow(
              icon: Icons.language,
              label: l10n.domainName,
              value: result.domain,
              color: Colors.blue,
            ),
            
            if (result.recordType != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.category,
                label: l10n.recordType,
                value: result.recordType!,
                color: Colors.purple,
              ),
            ],
            
            if (result.dnsServer != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.dns_outlined,
                label: l10n.dnsServer,
                value: result.dnsServer!,
                color: Colors.orange,
              ),
            ],
            
            if (hasResults) ...[
              const SizedBox(height: 16),
              
              // IPv4 Addresses
              if (result.ipv4Addresses.isNotEmpty)
                _buildAddressSection(
                  title: l10n.ipv4Addresses,
                  addresses: result.ipv4Addresses,
                  icon: Icons.public,
                  color: Colors.blue,
                ),
              
              // IPv6 Addresses
              if (result.ipv6Addresses.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAddressSection(
                  title: l10n.ipv6Addresses,
                  addresses: result.ipv6Addresses,
                  icon: Icons.public,
                  color: Colors.green,
                ),
              ],
              
              // Other records (MX, TXT, etc.)
              if (result.otherRecords.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAddressSection(
                  title: l10n.records,
                  addresses: result.otherRecords,
                  icon: Icons.list_alt,
                  color: Colors.purple,
                ),
              ],
            ] else if (result.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection({
    required String title,
    required List<String> addresses,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                '$title (${addresses.length})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...addresses.map((address) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SelectableText(
                    address,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    // Copy to clipboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.error,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(error),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
