import 'package:flutter/material.dart';
import '../../injection_container.dart' as di;
import '../subscription/subscription_service.dart';
import '../../features/subscription/presentation/pages/subscription_required_page.dart';

/// Middleware to check subscription status before allowing access
class SubscriptionMiddleware {
  static Future<bool> checkSubscription(BuildContext context) async {
    try {
      final subscriptionService = di.sl<SubscriptionService>();
      final hasSubscription = await subscriptionService.hasActiveSubscription();
      
      if (!hasSubscription) {
        // Show subscription required page
        if (context.mounted) {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const SubscriptionRequiredPage(),
            ),
          );
          
          // Return true if user purchased subscription
          return result ?? false;
        }
        return false;
      }
      
      return true;
    } catch (e) {
      // On error, allow access (fail-open to avoid blocking legitimate users)
      debugPrint('⚠️ Subscription check error: $e');
      return true;
    }
  }
}
