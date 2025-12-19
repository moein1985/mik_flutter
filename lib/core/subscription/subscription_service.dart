import 'package:flutter_poolakey/flutter_poolakey.dart';
import '../utils/logger.dart';

/// Service for managing Cafe Bazaar subscription
class SubscriptionService {
  static final _log = AppLogger.tag('SubscriptionService');
  
  bool _isConnected = false;
  
  // SKU for monthly subscription (300,000 Toman/month with 7-day trial)
  static const String subscriptionSku = 'monthly_subscription';
  
  /// Initialize Poolakey connection
  Future<void> initialize(String rsaPublicKey) async {
    try {
      _log.i('Initializing Poolakey...');
      
      await FlutterPoolakey.connect(
        rsaPublicKey,
        onSucceed: () {
          _log.i('✅ Poolakey connected successfully');
          _isConnected = true;
        },
        onFailed: () {
          _log.e('Failed to connect to Poolakey');
          _isConnected = false;
        },
        onDisconnected: () {
          _log.w('Poolakey disconnected');
          _isConnected = false;
        },
      );
    } catch (e) {
      _log.e('Failed to initialize Poolakey: $e');
      _isConnected = false;
    }
  }
  
  /// Check if user has active subscription
  /// Returns true if subscription is active (including trial period)
  Future<bool> hasActiveSubscription() async {
    if (!_isConnected) {
      _log.w('Poolakey not connected, assuming no subscription');
      return false;
    }
    
    try {
      _log.i('Checking subscription status...');
      
      // Get all subscribed products
      final subscribedProducts = await FlutterPoolakey.getAllSubscribedProducts();
      
      // Check if our subscription is in the list
      final hasSubscription = subscribedProducts.any(
        (purchase) => purchase.productId == subscriptionSku,
      );
      
      _log.i('Subscription status: ${hasSubscription ? "ACTIVE ✅" : "INACTIVE ❌"}');
      return hasSubscription;
    } catch (e) {
      _log.e('Error checking subscription: $e');
      return false;
    }
  }
  
  /// Start purchase flow for subscription
  Future<bool> purchaseSubscription() async {
    if (!_isConnected) {
      _log.e('Poolakey not connected');
      return false;
    }
    
    try {
      _log.i('Starting subscription purchase flow...');
      
      await FlutterPoolakey.subscribe(
        subscriptionSku,
        payload: 'network_assistant_subscription',
      );
      
      _log.i('✅ Subscription purchased successfully');
      return true;
    } catch (e) {
      _log.e('Error purchasing subscription: $e');
      return false;
    }
  }
  
  /// Get subscription details (price, title, description)
  Future<SkuDetails?> getSubscriptionDetails() async {
    if (!_isConnected) {
      _log.w('Poolakey not connected');
      return null;
    }
    
    try {
      final skuDetails = await FlutterPoolakey.getSubscriptionSkuDetails(
        [subscriptionSku],
      );
      
      if (skuDetails.isNotEmpty) {
        return skuDetails.first;
      }
      return null;
    } catch (e) {
      _log.e('Error getting subscription details: $e');
      return null;
    }
  }
  
  /// Disconnect from Poolakey
  Future<void> disconnect() async {
    try {
      await FlutterPoolakey.disconnect();
      _isConnected = false;
      _log.i('Poolakey disconnected');
    } catch (e) {
      _log.e('Error disconnecting Poolakey: $e');
    }
  }
}
