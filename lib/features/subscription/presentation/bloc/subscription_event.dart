part of 'subscription_bloc.dart';

@immutable
abstract class SubscriptionEvent {
  const SubscriptionEvent();
}

class CheckSubscriptionStatus extends SubscriptionEvent {
  const CheckSubscriptionStatus();
}

class PurchaseSubscription extends SubscriptionEvent {
  const PurchaseSubscription();
}
