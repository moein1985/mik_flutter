import 'package:flutter/material.dart';
import '../../domain/entities/app_module.dart';

class ModuleTile extends StatelessWidget {
  final AppModule module;
  final VoidCallback? onTap;

  const ModuleTile({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: module.isEnabled ? 4 : 1,
      color: module.isEnabled ? module.color.withValues(alpha: 0.1) : Colors.grey.shade200,
      child: InkWell(
        onTap: module.isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: module.isEnabled 
                    ? module.color.withValues(alpha: 0.2) 
                    : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  module.icon,
                  size: 48,
                  color: module.isEnabled 
                    ? module.color 
                    : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                module.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: module.isEnabled 
                    ? theme.colorScheme.onSurface 
                    : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              if (module.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  module.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (!module.isEnabled) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
