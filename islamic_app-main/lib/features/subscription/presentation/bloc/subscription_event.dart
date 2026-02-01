part of 'subscription_bloc.dart';

@freezed
class SubscriptionEvent with _$SubscriptionEvent {
  const factory SubscriptionEvent.initialize() = _Initialize;
  const factory SubscriptionEvent.loadProducts() = _LoadProducts;
  const factory SubscriptionEvent.purchase(SubscriptionProduct product) = _Purchase;
  const factory SubscriptionEvent.restorePurchases() = _RestorePurchases;
  const factory SubscriptionEvent.purchaseCompleted(bool success) = _PurchaseCompleted;
} 