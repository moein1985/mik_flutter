import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ping_result.dart';
import '../bloc/tools_bloc.dart';
import '../bloc/tools_event.dart';
import '../bloc/tools_state.dart';

class PingPage extends StatefulWidget {
  const PingPage({super.key});

  @override
  State<PingPage> createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  final _targetController = TextEditingController();
  final _sizeController = TextEditingController(text: '56');
  final _ttlController = TextEditingController(text: '64');
  final _intervalController = TextEditingController(text: '1');
  final _countController = TextEditingController(text: '100');
  
  bool _showAdvancedOptions = false;
  bool _doNotFragment = false;
  bool _isRunning = false;
  
  // Selected dropdown values
  String? _selectedInterface;
  String? _selectedSrcAddress;
  
  // Available options from router
  List<String> _interfaces = [];
  List<String> _ipAddresses = [];

  @override
  void initState() {
    super.initState();
    // Load network info when page opens
    context.read<ToolsBloc>().add(const LoadNetworkInfo());
  }

  @override
  void dispose() {
    _targetController.dispose();
    _sizeController.dispose();
    _ttlController.dispose();
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _startPing() {
    final l10n = AppLocalizations.of(context)!;
    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterTarget)),
      );
      return;
    }

    setState(() => _isRunning = true);

    context.read<ToolsBloc>().add(StartPing(
      target: _targetController.text.trim(),
      interval: int.tryParse(_intervalController.text) ?? 1,
      count: int.tryParse(_countController.text) ?? 100,
      size: int.tryParse(_sizeController.text),
      ttl: int.tryParse(_ttlController.text),
      srcAddress: _selectedSrcAddress,
      interfaceName: _selectedInterface,
      doNotFragment: _doNotFragment,
    ));
  }

  void _stopPing() {
    setState(() => _isRunning = false);
    context.read<ToolsBloc>().add(const StopPing());
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
        title: Text(l10n.ping),
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
          if (state is PingFailed) {
            setState(() => _isRunning = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PingCompleted) {
            setState(() => _isRunning = false);
          } else if (state is NetworkInfoLoaded) {
            setState(() {
              _interfaces = state.interfaces;
              _ipAddresses = state.ipAddresses;
            });
          }
        },
        builder: (context, state) {
          PingResult? result;
          if (state is PingUpdating) {
            result = state.result;
          } else if (state is PingCompleted) {
            result = state.result;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Tip Card
                _buildQuickTipCard(l10n),
                
                const SizedBox(height: 16),
                
                // Target Input Card
                _buildTargetInputCard(colorScheme, l10n),
                
                const SizedBox(height: 16),
                
                // Control Buttons
                _buildControlButtons(colorScheme, l10n),
                
                const SizedBox(height: 16),
                
                // Advanced Options (collapsible)
                _buildAdvancedOptionsCard(colorScheme, l10n),
                
                const SizedBox(height: 16),
                
                // Live Statistics
                if (result != null || _isRunning) ...[
                  _buildStatisticsCard(result, colorScheme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Round Trip Time
                  _buildRttCard(result, colorScheme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Packet History
                  _buildPacketHistoryCard(result, colorScheme, l10n),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetInputCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _targetController,
          enabled: !_isRunning,
          decoration: InputDecoration(
            labelText: l10n.targetHost,
            hintText: l10n.targetHostHint,
            prefixIcon: const Icon(Icons.gps_fixed),
            suffixIcon: _targetController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _isRunning ? null : () {
                      _targetController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (!_isRunning) _startPing();
          },
        ),
      ),
    );
  }

  Widget _buildControlButtons(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _isRunning ? null : _startPing,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.start),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton.icon(
            onPressed: _isRunning ? _stopPing : null,
            icon: const Icon(Icons.stop),
            label: Text(l10n.stop),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickTipCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.pingQuickTip,
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

  Widget _buildAdvancedOptionsCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l10n.advancedOptions),
            subtitle: Text(l10n.forAdvancedUsers),
            trailing: Icon(
              _showAdvancedOptions 
                  ? Icons.keyboard_arrow_up 
                  : Icons.keyboard_arrow_down,
            ),
            onTap: () => setState(() => _showAdvancedOptions = !_showAdvancedOptions),
          ),
          if (_showAdvancedOptions) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Packet Size & TTL Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l10n.packetSize, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.packetSize, l10n.packetSizeHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _sizeController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixText: l10n.bytes,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l10n.ttl, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.ttl, l10n.ttlHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _ttlController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Interval & Count Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l10n.interval, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.interval, l10n.intervalHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _intervalController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixText: l10n.sec,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l10n.count, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.count, l10n.countHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _countController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Source Address Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l10n.sourceAddress, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          _buildHelpIcon(l10n.sourceAddress, l10n.sourceAddressHelp),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSrcAddress,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        hint: Text(l10n.autoDefault),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n.autoDefault),
                          ),
                          ..._ipAddresses.map((ip) => DropdownMenuItem<String>(
                            value: ip,
                            child: Text(ip),
                          )),
                        ],
                        onChanged: _isRunning ? null : (value) {
                          setState(() => _selectedSrcAddress = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Interface Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l10n.interface, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          _buildHelpIcon(l10n.interface, l10n.interfaceHelp),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedInterface,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        hint: Text(l10n.autoDefault),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n.autoDefault),
                          ),
                          ..._interfaces.map((iface) => DropdownMenuItem<String>(
                            value: iface,
                            child: Text(iface),
                          )),
                        ],
                        onChanged: _isRunning ? null : (value) {
                          setState(() => _selectedInterface = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Do Not Fragment Switch
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: Row(
                        children: [
                          Text(l10n.doNotFragment),
                          const SizedBox(width: 4),
                          _buildHelpIcon(l10n.doNotFragment, l10n.doNotFragmentHelp),
                        ],
                      ),
                      subtitle: Text(l10n.forMtuTesting),
                      value: _doNotFragment,
                      onChanged: _isRunning ? null : (value) {
                        setState(() => _doNotFragment = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(PingResult? result, ColorScheme colorScheme, AppLocalizations l10n) {
    final sent = result?.packetsSent ?? 0;
    final received = result?.packetsReceived ?? 0;
    final loss = result?.packetLossPercent ?? 0;
    final successRate = sent > 0 ? (received / sent) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.liveStatistics,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isRunning)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(l10n.sent, '$sent', Colors.blue),
                _buildStatItem(l10n.received, '$received', Colors.green),
                _buildStatItem(l10n.loss, '$loss%', 
                    loss > 0 ? Colors.red : Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: successRate,
                minHeight: 10,
                backgroundColor: Colors.red.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${(successRate * 100).toStringAsFixed(1)}% ${l10n.successRate}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          label == 'Sent' 
              ? Icons.upload 
              : label == 'Received' 
                  ? Icons.download 
                  : Icons.warning,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRttCard(PingResult? result, ColorScheme colorScheme, AppLocalizations l10n) {
    String formatDuration(Duration? d) {
      if (d == null || d == Duration.zero) return '-';
      if (d.inMilliseconds > 0) {
        return '${d.inMilliseconds}ms';
      }
      return '${d.inMicroseconds}μs';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.roundTripTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRttItem(l10n.min, formatDuration(result?.minRtt), Colors.blue),
                  _buildRttItem(l10n.avg, formatDuration(result?.avgRtt), Colors.green),
                  _buildRttItem(l10n.max, formatDuration(result?.maxRtt), Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRttItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPacketHistoryCard(PingResult? result, ColorScheme colorScheme, AppLocalizations l10n) {
    final packets = result?.packets ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.packetHistory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.packetsCount(packets.length),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (packets.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.waitingForPackets,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: packets.length,
                  reverse: true, // Show newest first
                  itemBuilder: (context, index) {
                    final packet = packets[packets.length - 1 - index];
                    return _buildPacketItem(packet, result?.target ?? '', l10n);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPacketItem(PingPacket packet, String target, AppLocalizations l10n) {
    final isSuccess = packet.received;
    String rttText;
    if (packet.rtt != null) {
      if (packet.rtt!.inMilliseconds > 0) {
        rttText = '${packet.rtt!.inMilliseconds}ms';
      } else {
        rttText = '${packet.rtt!.inMicroseconds}μs';
      }
    } else {
      rttText = packet.error ?? l10n.timeout;
    }

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        child: Icon(
          isSuccess ? Icons.check : Icons.close,
          size: 16,
          color: Colors.white,
        ),
      ),
      title: Text(
        '#${packet.sequence + 1}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(target),
      trailing: Text(
        rttText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSuccess ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
