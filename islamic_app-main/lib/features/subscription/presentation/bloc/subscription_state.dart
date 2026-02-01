part of 'subscription_bloc.dart';

@freezed
abstract class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(false) bool isLoading,
    @Default(false) bool isSubscribed,
    @Default([]) List<SubscriptionProduct> products,
    @Default('') String errorMessage,
    @Default(false) bool isPurchaseInProgress,
    @Default(false) bool isPurchaseCompleted,
    @Default(false) bool isRestoringPurchases,
  }) = _SubscriptionState;
} 