import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../bloc/hotspot_bloc.dart';
import '../bloc/hotspot_event.dart';
import '../bloc/hotspot_state.dart';

final _log = AppLogger.tag('HotspotResetDialog');

class HotspotResetDialog extends StatefulWidget {
  const HotspotResetDialog({super.key});

  @override
  State<HotspotResetDialog> createState() => _HotspotResetDialogState();
}

class _HotspotResetDialogState extends State<HotspotResetDialog> {
  // Reset options
  bool _deleteUsers = true;
  bool _deleteProfiles = true;
  bool _deleteIpBindings = true;
  bool _deleteWalledGarden = true;
  bool _deleteServers = true;
  bool _deleteServerProfiles = true;
  bool _deleteIpPools = false;
  
  // Safety confirmation
  final _confirmController = TextEditingController();
  bool get _isConfirmValid => _confirmController.text.toUpperCase() == 'RESET';
  
  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotspotBloc, HotspotState>(
      listener: (context, state) {
        if (state is HotspotResetSuccess) {
          _log.i('HotSpot reset successful');
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('HotSpot has been reset successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is HotspotError) {
          _log.e('HotSpot reset error: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is HotspotResetInProgress;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700]),
              const SizedBox(width: 12),
              const Text('Reset HotSpot'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This action will permanently delete all selected HotSpot data. '
                            'This cannot be undone!',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Options Header
                  Text(
                    'Select what to delete:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Checkboxes
                  _buildCheckbox(
                    title: 'Users',
                    subtitle: 'All HotSpot users',
                    value: _deleteUsers,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteUsers = v ?? true),
                    icon: Icons.people,
                  ),
                  _buildCheckbox(
                    title: 'User Profiles',
                    subtitle: 'Custom user profiles (except default)',
                    value: _deleteProfiles,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteProfiles = v ?? true),
                    icon: Icons.badge,
                  ),
                  _buildCheckbox(
                    title: 'IP Bindings',
                    subtitle: 'MAC/IP binding rules',
                    value: _deleteIpBindings,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteIpBindings = v ?? true),
                    icon: Icons.link,
                  ),
                  _buildCheckbox(
                    title: 'Walled Garden',
                    subtitle: 'Allowed sites entries',
                    value: _deleteWalledGarden,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteWalledGarden = v ?? true),
                    icon: Icons.fence,
                  ),
                  _buildCheckbox(
                    title: 'HotSpot Servers',
                    subtitle: 'All configured servers',
                    value: _deleteServers,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteServers = v ?? true),
                    icon: Icons.router,
                  ),
                  _buildCheckbox(
                    title: 'Server Profiles',
                    subtitle: 'Server configuration profiles',
                    value: _deleteServerProfiles,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteServerProfiles = v ?? true),
                    icon: Icons.settings,
                  ),
                  
                  const Divider(height: 24),
                  
                  // Optional - IP Pools
                  _buildCheckbox(
                    title: 'IP Pools (Optional)',
                    subtitle: 'HotSpot-related IP pools only',
                    value: _deleteIpPools,
                    onChanged: isLoading ? null : (v) => setState(() => _deleteIpPools = v ?? false),
                    icon: Icons.dns,
                    isOptional: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Safety Confirmation
                  Text(
                    'Type "RESET" to confirm:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: 'Type RESET here',
                      border: const OutlineInputBorder(),
                      suffixIcon: _isConfirmValid 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  
                  // Loading indicator
                  if (state is HotspotResetInProgress)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            state.currentStep,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading || !_isConfirmValid 
                  ? null 
                  : () => _performReset(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Reset HotSpot'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCheckbox({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool?)? onChanged,
    required IconData icon,
    bool isOptional = false,
  }) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, size: 20, color: isOptional ? Colors.grey : Colors.blue[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isOptional ? Colors.grey[700] : null,
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
  
  void _performReset(BuildContext context) {
    _log.i('Performing HotSpot reset...');
    context.read<HotspotBloc>().add(ResetHotspot(
      deleteUsers: _deleteUsers,
      deleteProfiles: _deleteProfiles,
      deleteIpBindings: _deleteIpBindings,
      deleteWalledGarden: _deleteWalledGarden,
      deleteServers: _deleteServers,
      deleteServerProfiles: _deleteServerProfiles,
      deleteIpPools: _deleteIpPools,
    ));
  }
}
