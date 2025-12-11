import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/traceroute_hop.dart';
import '../bloc/tools_bloc.dart';
import '../bloc/tools_event.dart';
import '../bloc/tools_state.dart';

class TraceroutePage extends StatefulWidget {
  const TraceroutePage({super.key});

  @override
  State<TraceroutePage> createState() => _TraceroutePageState();
}

class _TraceroutePageState extends State<TraceroutePage> {
  final _targetController = TextEditingController();
  final _maxHopsController = TextEditingController(text: '30');
  final _timeoutController = TextEditingController(text: '1000');
  final _countController = TextEditingController(text: '3');
  
  bool _showAdvancedOptions = false;
  bool _isRunning = false;
  String? _currentTarget;

  @override
  void dispose() {
    _targetController.dispose();
    _maxHopsController.dispose();
    _timeoutController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _startTraceroute() {
    final l10n = AppLocalizations.of(context)!;
    if (_targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterTarget)),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _currentTarget = _targetController.text.trim();
    });

    context.read<ToolsBloc>().add(StartTraceroute(
      target: _targetController.text.trim(),
      maxHops: int.tryParse(_maxHopsController.text) ?? 30,
      timeout: int.tryParse(_timeoutController.text) ?? 1000,
    ));
  }

  void _stopTraceroute() {
    setState(() => _isRunning = false);
    context.read<ToolsBloc>().add(const StopTraceroute());
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
        title: Text(l10n.traceroute),
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
          if (state is TracerouteFailed) {
            setState(() => _isRunning = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TracerouteCompleted) {
            setState(() => _isRunning = false);
          }
        },
        builder: (context, state) {
          List<TracerouteHop> hops = [];
          if (state is TracerouteUpdating) {
            hops = state.hops;
          } else if (state is TracerouteCompleted) {
            hops = state.hops;
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
                
                // Progress indicator when running
                if (_isRunning && hops.isEmpty)
                  _buildProgressCard(colorScheme, l10n),
                
                // Route Path Results
                if (hops.isNotEmpty) ...[
                  _buildSummaryCard(hops, colorScheme, l10n),
                  
                  const SizedBox(height: 16),
                  
                  // Hops List
                  _buildHopsCard(hops, colorScheme, l10n),
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
            prefixIcon: const Icon(Icons.route),
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
            if (!_isRunning) _startTraceroute();
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
            onPressed: _isRunning ? null : _startTraceroute,
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
            onPressed: _isRunning ? _stopTraceroute : null,
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.tracerouteQuickTip,
              style: TextStyle(
                color: Colors.green.shade800,
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
                  // Max Hops & Timeout Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(l10n.maxHopsLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.maxHopsLabel, l10n.maxHopsHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _maxHopsController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixText: l10n.hops,
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
                                Text(l10n.timeoutMsLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                _buildHelpIcon(l10n.timeoutMsLabel, l10n.timeoutMsHelp),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _timeoutController,
                              enabled: !_isRunning,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixText: l10n.ms,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Probes per Hop
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l10n.countProbes, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 4),
                          _buildHelpIcon(l10n.countProbes, l10n.countProbesHelp),
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              l10n.tracerouteInProgress(_currentTarget ?? ''),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.waitingForHops,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<TracerouteHop> hops, ColorScheme colorScheme, AppLocalizations l10n) {
    final totalHops = hops.length;
    final reachableHops = hops.where((h) => h.isReachable).length;
    final totalTime = _calculateTotalTime(hops);
    final targetReached = hops.isNotEmpty && hops.last.isReachable;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.routePath,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: targetReached ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: targetReached ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    icon: Icons.format_list_numbered,
                    label: l10n.hopCount(totalHops),
                    value: '$reachableHops/$totalHops',
                    color: Colors.blue,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  _buildSummaryItem(
                    icon: Icons.timer,
                    label: l10n.totalTime,
                    value: totalTime,
                    color: Colors.orange,
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  _buildSummaryItem(
                    icon: targetReached ? Icons.check_circle : Icons.cancel,
                    label: targetReached ? l10n.targetReached : l10n.targetNotReached,
                    value: '',
                    color: targetReached ? Colors.green : Colors.orange,
                    showValue: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool showValue = true,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        if (showValue)
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHopsCard(List<TracerouteHop> hops, ColorScheme colorScheme, AppLocalizations l10n) {
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
                  l10n.routePath,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.hopCount(hops.length),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hops.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final hop = hops[index];
                return _buildHopItem(hop, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHopItem(TracerouteHop hop, AppLocalizations l10n) {
    final isReachable = hop.isReachable;
    final rttText = _formatRtt(hop.avgRtt);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReachable ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReachable ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          // Hop Number
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isReachable ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${hop.hopNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Address Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hop.hostname ?? hop.ipAddress ?? l10n.unknown,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (hop.hostname != null && hop.ipAddress != null)
                  Text(
                    hop.ipAddress!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                if (hop.status != null && hop.status!.isNotEmpty)
                  Text(
                    hop.status!,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          
          // RTT Values
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReachable ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isReachable ? rttText : l10n.timeout,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isReachable ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
              if (isReachable && hop.minRtt != null && hop.maxRtt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${_formatRtt(hop.minRtt)} - ${_formatRtt(hop.maxRtt)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRtt(Duration? rtt) {
    if (rtt == null) return '-';
    if (rtt.inMilliseconds > 0) {
      return '${rtt.inMilliseconds}ms';
    }
    return '${rtt.inMicroseconds}μs';
  }

  String _calculateTotalTime(List<TracerouteHop> hops) {
    if (hops.isEmpty) return '-';
    
    Duration total = Duration.zero;
    for (final hop in hops) {
      if (hop.avgRtt != null) {
        total += hop.avgRtt!;
      }
    }
    
    if (total.inMilliseconds > 0) {
      return '${total.inMilliseconds}ms';
    }
    return '${total.inMicroseconds}μs';
  }
}
