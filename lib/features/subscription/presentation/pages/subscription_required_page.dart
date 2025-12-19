import 'package:flutter/material.dart';
import '../../../../core/subscription/subscription_service.dart';
import '../../../../injection_container.dart' as di;

class SubscriptionRequiredPage extends StatefulWidget {
  const SubscriptionRequiredPage({super.key});

  @override
  State<SubscriptionRequiredPage> createState() => _SubscriptionRequiredPageState();
}

class _SubscriptionRequiredPageState extends State<SubscriptionRequiredPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _purchaseSubscription() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final subscriptionService = di.sl<SubscriptionService>();
      final success = await subscriptionService.purchaseSubscription();

      if (mounted) {
        if (success) {
          // Subscription successful, go back
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _errorMessage = 'خرید لغو شد یا با خطا مواجه شد';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'خطا در برقراری ارتباط با کافه بازار';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_membership,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 32),

                // Title
                Text(
                  isRtl ? 'دوره رایگان به پایان رسید' : 'Free Trial Ended',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  isRtl
                      ? 'برای ادامه استفاده از دستیار شبکه، لطفاً اشتراک ماهانه را خریداری کنید.'
                      : 'To continue using Network Assistant, please purchase a monthly subscription.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Features Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRtl ? 'امکانات اشتراک:' : 'Subscription Features:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFeature(
                          context,
                          isRtl ? 'مدیریت کامل روترهای MikroTik' : 'Full MikroTik Router Management',
                        ),
                        _buildFeature(
                          context,
                          isRtl ? 'فایروال و امنیت شبکه' : 'Firewall & Network Security',
                        ),
                        _buildFeature(
                          context,
                          isRtl ? 'مانیتورینگ و گزارش‌گیری' : 'Monitoring & Reporting',
                        ),
                        _buildFeature(
                          context,
                          isRtl ? 'پشتیبانی 24/7' : '24/7 Support',
                        ),
                        _buildFeature(
                          context,
                          isRtl ? 'آپدیت‌های منظم' : 'Regular Updates',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isRtl ? '۳۰۰,۰۰۰ تومان / ماه' : '300,000 Toman / Month',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Purchase Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _purchaseSubscription,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.shopping_cart),
                    label: Text(
                      isRtl ? 'خرید اشتراک' : 'Purchase Subscription',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
