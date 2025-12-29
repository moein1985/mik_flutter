part of 'subscription_bloc.dart';

@immutable
abstract class SubscriptionState {
  const SubscriptionState();
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final bool isSubscribed;
  final bool isTrial;
  final DateTime? expiryDate;
  final String price;

  const SubscriptionLoaded({
    required this.isSubscribed,
    required this.isTrial,
    this.expiryDate,
    this.price = '...',
  });
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
}
