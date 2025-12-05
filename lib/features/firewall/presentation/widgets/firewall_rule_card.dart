import 'package:flutter/material.dart';
import '../../domain/entities/firewall_rule.dart';

class FirewallRuleCard extends StatefulWidget {
  final FirewallRule rule;
  final int index;
  final Function(bool enabled) onToggle;

  const FirewallRuleCard({
    super.key,
    required this.rule,
    required this.index,
    required this.onToggle,
  });

  @override
  State<FirewallRuleCard> createState() => _FirewallRuleCardState();
}

class _FirewallRuleCardState extends State<FirewallRuleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final rule = widget.rule;
    final isDisabled = rule.disabled;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDisabled ? 1 : 2,
      color: isDisabled ? Colors.grey[100] : null,
      child: Column(
        children: [
          // Header - Always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Index number
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getTypeColor(rule.type).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.index.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(rule.type),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rule.displayTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDisabled ? Colors.grey : null,
                                  decoration: isDisabled 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                ),
                              ),
                            ),
                            // Status badges
                            if (rule.dynamic)
                              _buildBadge('D', Colors.blue, 'Dynamic'),
                            if (rule.invalid)
                              _buildBadge('!', Colors.red, 'Invalid'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rule.summary,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Toggle switch
                  Switch(
                    value: !isDisabled,
                    onChanged: (value) {
                      widget.onToggle(value);
                    },
                    activeThumbColor: Colors.green,
                  ),
                  // Expand icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) _buildExpandedContent(rule),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
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
      ),
    );
  }

  Widget _buildExpandedContent(FirewallRule rule) {
    final params = rule.displayParameters;
    
    if (params.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No additional parameters',
          style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Parameters',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...params.entries.map((entry) => _buildParameterRow(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(FirewallRuleType type) {
    switch (type) {
      case FirewallRuleType.filter:
        return Colors.blue;
      case FirewallRuleType.nat:
        return Colors.green;
      case FirewallRuleType.mangle:
        return Colors.orange;
      case FirewallRuleType.raw:
        return Colors.purple;
      case FirewallRuleType.addressList:
        return Colors.indigo;
      case FirewallRuleType.layer7Protocol:
        return Colors.teal;
    }
  }
}
