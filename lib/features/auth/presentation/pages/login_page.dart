import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../domain/entities/saved_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/saved_router_bloc.dart';
import '../bloc/saved_router_event.dart';
import '../bloc/saved_router_state.dart';
import '../../domain/entities/router_credentials.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController(text: '8728');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const LoadSavedCredentialsRequested());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      final credentials = RouterCredentials(
        host: _hostController.text.trim(),
        port: int.parse(_portController.text.trim()),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      context.read<AuthBloc>().add(
            LoginRequested(
              credentials: credentials,
              rememberMe: _rememberMe,
            ),
          );
    }
  }

  void _selectRouter(SavedRouter router) {
    setState(() {
      _hostController.text = router.host;
      _portController.text = router.port.toString();
      _usernameController.text = router.username;
      _passwordController.text = router.password;
    });
  }

  void _showSavedRoutersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider(
          create: (_) => di.sl<SavedRouterBloc>()..add(const LoadSavedRouters()),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) {
              return _SavedRoutersSheet(
                scrollController: scrollController,
                onRouterSelected: (router) {
                  Navigator.pop(bottomSheetContext);
                  _selectRouter(router);
                },
                onSaveCurrentRouter: () {
                  Navigator.pop(bottomSheetContext);
                  _showSaveRouterDialog();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showSaveRouterDialog() {
    final nameController = TextEditingController(
      text: _hostController.text.isNotEmpty
          ? '${_hostController.text}:${_portController.text}'
          : '',
    );
    bool setAsDefault = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Save Router'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Router Name',
                      hintText: 'e.g., Office Router, Home MikroTik',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: setAsDefault,
                    onChanged: (value) {
                      setDialogState(() {
                        setAsDefault = value ?? false;
                      });
                    },
                    title: const Text('Set as default'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
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
                    if (nameController.text.isNotEmpty &&
                        _hostController.text.isNotEmpty &&
                        _usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      final bloc = di.sl<SavedRouterBloc>();
                      bloc.add(SaveRouter(
                        name: nameController.text,
                        host: _hostController.text,
                        port: int.tryParse(_portController.text) ?? 8728,
                        username: _usernameController.text,
                        password: _passwordController.text,
                        isDefault: setAsDefault,
                      ));
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Router saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthUnauthenticated && state.savedCredentials != null) {
            _hostController.text = state.savedCredentials!.host;
            _portController.text = state.savedCredentials!.port.toString();
            _usernameController.text = state.savedCredentials!.username;
            _passwordController.text = state.savedCredentials!.password;
            _rememberMe = true;
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final l10n = AppLocalizations.of(context)!;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Saved Routers Button
                        TextButton.icon(
                          onPressed: _showSavedRoutersDialog,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Saved Routers'),
                        ),
                        // Language Switch Button
                        IconButton(
                          icon: const Icon(Icons.language),
                          tooltip: 'Change Language',
                          onPressed: () {
                            final currentLocale = Localizations.localeOf(context);
                            final newLocale = currentLocale.languageCode == 'en'
                                ? const Locale('fa', '')
                                : const Locale('en', '');
                            MyApp.of(context)?.setLocale(newLocale);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Logo or App Icon
                    Icon(
                      Icons.router,
                      size: 80,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    
                    // App Title
                    Text(
                      l10n.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Host Field
                    TextFormField(
                      controller: _hostController,
                      decoration: InputDecoration(
                        labelText: l10n.host,
                        prefixIcon: const Icon(Icons.dns),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter host';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Port Field
                    TextFormField(
                      controller: _portController,
                      decoration: InputDecoration(
                        labelText: l10n.port,
                        prefixIcon: const Icon(Icons.numbers),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter port';
                        }
                        final port = int.tryParse(value);
                        if (port == null || port < 1 || port > 65535) {
                          return 'Invalid port number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: l10n.username,
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Remember Me and Save Router Row
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            value: _rememberMe,
                            onChanged: isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                            title: Text(l10n.rememberMe),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: isLoading ? null : _showSaveRouterDialog,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              l10n.loginButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Bottom sheet for saved routers
class _SavedRoutersSheet extends StatelessWidget {
  final ScrollController scrollController;
  final Function(SavedRouter) onRouterSelected;
  final VoidCallback onSaveCurrentRouter;

  const _SavedRoutersSheet({
    required this.scrollController,
    required this.onRouterSelected,
    required this.onSaveCurrentRouter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Routers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onSaveCurrentRouter,
                icon: const Icon(Icons.add),
                label: const Text('Save Current'),
              ),
            ],
          ),
        ),
        const Divider(),
        // List
        Expanded(
          child: BlocConsumer<SavedRouterBloc, SavedRouterState>(
            listener: (context, state) {
              if (state is SavedRouterError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is SavedRouterOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SavedRouterLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<SavedRouter> routers = [];
              if (state is SavedRouterLoaded) {
                routers = state.routers;
              } else if (state is SavedRouterOperationSuccess && state.routers != null) {
                routers = state.routers!;
              }

              if (routers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.router_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No saved routers',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter router details and tap "Save Current"',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: scrollController,
                itemCount: routers.length,
                itemBuilder: (context, index) {
                  final router = routers[index];
                  return _SavedRouterTile(
                    router: router,
                    onTap: () => onRouterSelected(router),
                    onSetDefault: () {
                      context.read<SavedRouterBloc>().add(
                            SetDefaultSavedRouter(router.id!),
                          );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, router);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, SavedRouter router) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Router'),
          content: Text('Are you sure you want to delete "${router.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SavedRouterBloc>().add(
                      DeleteSavedRouter(router.id!),
                    );
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _SavedRouterTile extends StatelessWidget {
  final SavedRouter router;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _SavedRouterTile({
    required this.router,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: router.isDefault ? Colors.green : Colors.blue,
          child: Icon(
            router.isDefault ? Icons.star : Icons.router,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(router.name)),
            if (router.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(fontSize: 10, color: Colors.green),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${router.host}:${router.port}'),
            Text(
              'User: ${router.username}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (router.lastConnected != null)
              Text(
                'Last: ${_formatDate(router.lastConnected!)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'default':
                onSetDefault();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!router.isDefault)
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.star_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
