import 'package:flutter/material.dart';

class LogsFilterSheet extends StatefulWidget {
  final String? selectedTopics;
  final Function(String?) onTopicsChanged;

  const LogsFilterSheet({
    super.key,
    this.selectedTopics,
    required this.onTopicsChanged,
  });

  @override
  State<LogsFilterSheet> createState() => _LogsFilterSheetState();
}

class _LogsFilterSheetState extends State<LogsFilterSheet> {
  late TextEditingController _topicsController;

  @override
  void initState() {
    super.initState();
    _topicsController = TextEditingController(text: widget.selectedTopics);
  }

  @override
  void dispose() {
    _topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Logs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _topicsController,
            decoration: const InputDecoration(
              labelText: 'Topics (comma-separated)',
              hintText: 'e.g., system,dhcp,firewall',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _topicsController.clear();
                    widget.onTopicsChanged(null);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear Filter'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final topics = _topicsController.text.trim().isEmpty
                        ? null
                        : _topicsController.text.trim();
                    widget.onTopicsChanged(topics);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Common Topics:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'system',
              'dhcp',
              'firewall',
              'hotspot',
              'wireless',
              'interface',
            ].map((topic) => FilterChip(
              label: Text(topic),
              selected: _isTopicSelected(topic),
              onSelected: (selected) {
                _toggleTopic(topic);
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  bool _isTopicSelected(String topic) {
    if (_topicsController.text.isEmpty) return false;
    final topics = _topicsController.text.split(',');
    return topics.contains(topic.trim());
  }

  void _toggleTopic(String topic) {
    final currentTopics = _topicsController.text.isEmpty
        ? <String>[]
        : _topicsController.text.split(',').map((t) => t.trim()).toList();

    if (currentTopics.contains(topic)) {
      currentTopics.remove(topic);
    } else {
      currentTopics.add(topic);
    }

    _topicsController.text = currentTopics.join(', ');
  }
}