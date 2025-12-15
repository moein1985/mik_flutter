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
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(rule.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDisabled 
              ? colorScheme.outline.withAlpha(51)
              : typeColor.withAlpha(77),
        ),
      ),
      color: isDisabled ? colorScheme.surfaceContainerHighest.withAlpha(128) : null,
      child: Column(
        children: [
          // Header - Always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: _isExpanded ? Radius.zero : const Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status indicator dot
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDisabled ? Colors.grey : Colors.green,
                      boxShadow: isDisabled ? null : [
                        BoxShadow(
                          color: Colors.green.withAlpha(102),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  // Index number with colored background
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: typeColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.index.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
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
                                  fontSize: 15,
                                  color: isDisabled ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                                  decoration: isDisabled 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Status tags
                        if (rule.dynamic || rule.invalid)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (rule.dynamic)
                                  _buildTag('Dynamic', Colors.blue),
                                if (rule.invalid)
                                  _buildTag('Invalid', Colors.red),
                              ],
                            ),
                          ),
                        Text(
                          rule.summary,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
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
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_isExpanded) _buildExpandedContent(rule, colorScheme),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildExpandedContent(FirewallRule rule, ColorScheme colorScheme) {
    final params = rule.displayParameters;
    
    if (params.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(77),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          'No additional parameters',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(77),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'All Parameters',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: params.entries.map((entry) => _buildParameterRow(entry.key, entry.value, colorScheme)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterRow(String key, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 12,
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
