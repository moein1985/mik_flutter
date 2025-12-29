import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/subscription_bloc.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  static const routeName = '/subscription';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
        leading: GoRouter.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => GoRouter.of(context).pop(),
              )
            : null,
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionInitial || state is SubscriptionLoading && state is! SubscriptionLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionError) {
            return Center(child: Text(l10n.subscriptionError));
          }

          if (state is SubscriptionLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(context, theme, l10n, state),
                  const SizedBox(height: 32),
                  _buildPlanCard(theme, l10n, state),
                  const SizedBox(height: 48),
                  _buildCtaButton(context, theme, l10n, state),
                ],
              ),
            );
          }

          return const SizedBox.shrink(); // Should not happen
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ThemeData theme, AppLocalizations l10n, SubscriptionLoaded state) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;

    if (state.isSubscribed) {
      title = l10n.subscriptionSubscribed;
      subtitle = l10n.subscriptionSubscribedUntil(state.expiryDate?.toLocal().toString().split(' ')[0] ?? '');
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (state.isTrial) {
      title = l10n.subscriptionTrialActive;
      subtitle = l10n.subscriptionTrialEndsIn(7); // Placeholder for days
      icon = Icons.timelapse;
      iconColor = Colors.orange;
    } else {
      title = l10n.subscriptionNotSubscribed;
      subtitle = l10n.subscriptionNotSubscribedSubtitle;
      icon = Icons.hourglass_empty;
      iconColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionStatusTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(ThemeData theme, AppLocalizations l10n, SubscriptionLoaded state) {
    return Card(
      elevation: 0,
      color: theme.primaryColor.withAlpha((255 * 0.05).round()),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.primaryColor.withAlpha((255 * 0.3).round())),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionPlanTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    l10n.subscriptionMonthlyPlan,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    state.price.isEmpty || state.price == 'N/A' ? l10n.subscriptionPriceLoading : state.price,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildFeatureRow(theme, l10n.subscriptionFeature1),
            _buildFeatureRow(theme, l10n.subscriptionFeature2),
            _buildFeatureRow(theme, l10n.subscriptionFeature3),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context, ThemeData theme, AppLocalizations l10n, SubscriptionLoaded state) {
    String buttonText;
    VoidCallback? onPressed;

    final blocState = context.read<SubscriptionBloc>().state;

    if (blocState is SubscriptionLoading) {
      buttonText = l10n.subscriptionCtaButtonLoading;
      onPressed = null;
    } else if (state.isSubscribed) {
      buttonText = l10n.subscriptionCtaButtonSubscribed;
      onPressed = null;
    } else {
      // Show purchase button (trial is managed by Bazaar automatically)
      buttonText = l10n.subscriptionCtaButtonPurchase;
      onPressed = () {
        context.read<SubscriptionBloc>().add(const PurchaseSubscription());
      };
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: onPressed != null ? theme.primaryColor : Colors.grey,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      child: blocState is SubscriptionLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
          : Text(
              buttonText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildFeatureRow(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
