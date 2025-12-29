import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/subscription_bloc.dart';

/// A widget that conditionally shows a premium feature or a "lock" overlay.
/// If the user is not subscribed, it shows an overlay prompting them to subscribe.
class PremiumFeature extends StatelessWidget {
  final Widget child;
  final String featureName;

  const PremiumFeature({
    super.key,
    this.featureName = 'This feature',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        bool hasAccess = false;
        if (state is SubscriptionLoaded) {
          hasAccess = state.isSubscribed;
        }

        if (hasAccess) {
          return child;
        } else {
          return _LockedFeature(
            featureName: featureName,
            child: child,
          );
        }
      },
    );
  }
}

class _LockedFeature extends StatelessWidget {
  final Widget child;
  final String featureName;

  const _LockedFeature({
    required this.featureName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.dashboardSubscription);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blurred background
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: AbsorbPointer(
              absorbing: true, // Prevent interaction with the child
              child: child,
            ),
          ),
          // Lock icon and text overlay
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(128),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 32),
                const SizedBox(height: 6),
                Text(
                  l10n.premiumFeatureTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    l10n.premiumFeatureSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
