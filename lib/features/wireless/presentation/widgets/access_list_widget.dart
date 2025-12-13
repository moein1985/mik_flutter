import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/access_list_entry.dart';
import '../../domain/entities/wireless_interface.dart';
import '../bloc/wireless_bloc.dart';
import '../bloc/wireless_event.dart';
import '../bloc/wireless_state.dart';

class AccessListWidget extends StatefulWidget {
  const AccessListWidget({super.key});

  @override
  State<AccessListWidget> createState() => _AccessListWidgetState();
}

class _AccessListWidgetState extends State<AccessListWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<WirelessBloc>().add(const LoadAccessList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocConsumer<WirelessBloc, WirelessState>(
        listenWhen: (previous, current) {
          return current is WirelessOperationSuccess ||
              current is WirelessOperationError;
        },
        listener: (context, state) {
          if (state is WirelessOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is WirelessOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          return current is AccessListLoading ||
              current is AccessListLoaded ||
              current is AccessListError;
        },
        builder: (context, state) {
          if (state is AccessListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccessListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WirelessBloc>().add(const LoadAccessList());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AccessListLoaded) {
            if (state.accessList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.list_alt, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No access list entries'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Entry'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WirelessBloc>().add(const LoadAccessList());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.accessList.length,
                itemBuilder: (context, index) {
                  final entry = state.accessList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: entry.authentication
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          entry.authentication ? Icons.check : Icons.block,
                          color: entry.authentication
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      title: Text(
                        entry.macAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.router,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Interface: ${entry.interface}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: entry.authentication
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.authentication ? 'Allow' : 'Deny',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: entry.authentication
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (entry.forwarding)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Forwarding',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (entry.comment?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.comment!,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () =>
                                _showAddEditDialog(context, entry: entry),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            onPressed: () =>
                                _showDeleteDialog(context, entry),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        tooltip: 'Add Access List Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {AccessListEntry? entry}) {
    final isEdit = entry != null;
    final macController = TextEditingController(text: entry?.macAddress ?? '');
    final commentController = TextEditingController(text: entry?.comment ?? '');
    final apTxLimitController =
        TextEditingController(text: entry?.apTxLimit ?? '');
    final clientTxLimitController =
        TextEditingController(text: entry?.clientTxLimit ?? '');
    final signalRangeController =
        TextEditingController(text: entry?.signalRange ?? '');
    final timeController = TextEditingController(text: entry?.time ?? '');

    String? selectedInterface = entry?.interface;
    bool authentication = entry?.authentication ?? true;
    bool forwarding = entry?.forwarding ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Access List Entry' : 'Add Access List Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MAC Address
                TextFormField(
                  controller: macController,
                  decoration: const InputDecoration(
                    labelText: 'MAC Address *',
                    hintText: 'XX:XX:XX:XX:XX:XX',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Interface dropdown
                BlocBuilder<WirelessBloc, WirelessState>(
                  buildWhen: (previous, current) =>
                      current is WirelessInterfacesLoaded,
                  builder: (context, state) {
                    List<WirelessInterface> interfaces = [];
                    if (state is WirelessInterfacesLoaded) {
                      interfaces = state.interfaces
                          .cast<WirelessInterface>();
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: selectedInterface,
                      decoration: const InputDecoration(
                        labelText: 'Interface *',
                        border: OutlineInputBorder(),
                      ),
                      items: interfaces.map((iface) {
                        return DropdownMenuItem(
                          value: iface.name,
                          child: Text(iface.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedInterface = value;
                        });
                      },
                      hint: const Text('Select interface'),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Authentication switch
                SwitchListTile(
                  title: const Text('Authentication'),
                  subtitle:
                      Text(authentication ? 'Allow connection' : 'Deny connection'),
                  value: authentication,
                  onChanged: (value) {
                    setState(() {
                      authentication = value;
                    });
                  },
                ),

                // Forwarding switch
                SwitchListTile(
                  title: const Text('Forwarding'),
                  subtitle: const Text('Enable packet forwarding'),
                  value: forwarding,
                  onChanged: (value) {
                    setState(() {
                      forwarding = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Optional fields
                ExpansionTile(
                  title: const Text('Advanced Settings (Optional)'),
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: apTxLimitController,
                      decoration: const InputDecoration(
                        labelText: 'AP TX Limit',
                        hintText: 'e.g., 10M',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: clientTxLimitController,
                      decoration: const InputDecoration(
                        labelText: 'Client TX Limit',
                        hintText: 'e.g., 5M',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: signalRangeController,
                      decoration: const InputDecoration(
                        labelText: 'Signal Range',
                        hintText: 'e.g., -70..-30',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: 'e.g., 1h, 30m',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        labelText: 'Comment',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (macController.text.isEmpty || selectedInterface == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('MAC Address and Interface are required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newEntry = AccessListEntry(
                  id: entry?.id ?? '',
                  macAddress: macController.text.trim(),
                  interface: selectedInterface!,
                  authentication: authentication,
                  forwarding: forwarding,
                  apTxLimit: apTxLimitController.text.isEmpty
                      ? null
                      : apTxLimitController.text,
                  clientTxLimit: clientTxLimitController.text.isEmpty
                      ? null
                      : clientTxLimitController.text,
                  signalRange: signalRangeController.text.isEmpty
                      ? null
                      : signalRangeController.text,
                  time: timeController.text.isEmpty ? null : timeController.text,
                  comment: commentController.text.isEmpty
                      ? null
                      : commentController.text,
                );

                Navigator.of(dialogContext).pop();

                if (isEdit) {
                  context
                      .read<WirelessBloc>()
                      .add(UpdateAccessListEntry(newEntry));
                } else {
                  context.read<WirelessBloc>().add(AddAccessListEntry(newEntry));
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );

    // Load interfaces if needed
    context.read<WirelessBloc>().add(const LoadWirelessInterfaces());
  }

  void _showDeleteDialog(BuildContext context, AccessListEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Are you sure you want to delete this access list entry?\n\nMAC: ${entry.macAddress}\nInterface: ${entry.interface}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context
                  .read<WirelessBloc>()
                  .add(RemoveAccessListEntry(entry.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
