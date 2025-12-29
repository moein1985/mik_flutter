import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../../core/subscription/subscription_service.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _subscriptionService;

  SubscriptionBloc({required SubscriptionService subscriptionService})
      : _subscriptionService = subscriptionService,
        super(const SubscriptionInitial()) {
    on<CheckSubscriptionStatus>(_onCheckSubscriptionStatus);
    on<PurchaseSubscription>(_onPurchaseSubscription);
  }

  Future<void> _onCheckSubscriptionStatus(
    CheckSubscriptionStatus event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final details = await _subscriptionService.getSubscriptionDetails();
      final hasActiveSub = await _subscriptionService.hasActiveSubscription();
      
      // Get price from Bazaar
      String price = 'N/A';
      if (details != null && details.price.isNotEmpty) {
        price = details.price;
      }
      
      emit(SubscriptionLoaded(
        isSubscribed: hasActiveSub,
        isTrial: false, // Poolakey manages trial automatically
        price: price,
        expiryDate: null, // Poolakey doesn't easily provide this
      ));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onPurchaseSubscription(
    PurchaseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final purchaseSuccess = await _subscriptionService.purchaseSubscription();
      if (purchaseSuccess) {
        // After a successful purchase, re-check the status to update the UI.
        add(const CheckSubscriptionStatus());
      } else {
        // If purchase failed or was cancelled, revert to the last known state.
        add(const CheckSubscriptionStatus()); 
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
      // Revert to the last known state on error.
      add(const CheckSubscriptionStatus());
    }
  }
}
