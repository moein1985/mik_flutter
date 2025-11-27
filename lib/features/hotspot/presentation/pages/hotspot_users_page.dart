import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

class HotspotUsersPage extends StatefulWidget {
  const HotspotUsersPage({super.key});

  @override
  State<HotspotUsersPage> createState() => _HotspotUsersPageState();
}

class _HotspotUsersPageState extends State<HotspotUsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<HotspotBloc>().add(const LoadHotspotUsers());
    context.read<HotspotBloc>().add(const LoadHotspotProfiles());
    context.read<HotspotBloc>().add(const LoadHotspotServers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HotSpot Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HotspotBloc>().add(const LoadHotspotUsers());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<HotspotBloc, HotspotState>(
        listener: (context, state) {
          if (state is HotspotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is HotspotOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HotspotLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HotspotLoaded && state.users != null) {
            final users = state.users!;

            if (users.isEmpty) {
              return const Center(
                child: Text('No users found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HotspotBloc>().add(const LoadHotspotUsers());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.disabled ? Colors.grey : Colors.green,
                        child: Icon(
                          user.disabled ? Icons.person_off : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user.profile != null)
                            Text('Profile: ${user.profile}'),
                          if (user.server != null) Text('Server: ${user.server}'),
                          if (user.comment != null)
                            Text('Comment: ${user.comment}'),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(
                                  user.disabled ? 'Disabled' : 'Enabled',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor:
                                    user.disabled ? Colors.red : Colors.green,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Switch(
                        value: !user.disabled,
                        onChanged: (value) {
                          context.read<HotspotBloc>().add(
                                ToggleHotspotUser(id: user.id, enable: value),
                              );
                        },
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(state is HotspotError
                    ? state.message
                    : 'Unable to load users'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HotspotBloc>().add(const LoadHotspotUsers());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add HotSpot User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  context.read<HotspotBloc>().add(
                        AddHotspotUser(
                          name: nameController.text,
                          password: passwordController.text,
                          comment: commentController.text.isEmpty
                              ? null
                              : commentController.text,
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
