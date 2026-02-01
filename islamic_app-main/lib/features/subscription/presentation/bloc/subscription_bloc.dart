import 'dart:async';

import 'package:deenhub/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/subscription_service.dart';
import '../../domain/models/subscription_product.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';
part 'subscription_bloc.freezed.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionService _subscriptionService;
  late StreamSubscription _productsSubscription;
  late StreamSubscription _purchaseStatusSubscription;

  SubscriptionBloc(this._subscriptionService)
      : super(const SubscriptionState()) {
    on<SubscriptionEvent>((event, emit) async {
      await event.map(
        initialize: (e) => _initialize(e, emit),
        loadProducts: (e) => _loadProducts(e, emit),
        purchase: (e) => _purchase(e, emit),
        restorePurchases: (e) => _restorePurchases(e, emit),
        purchaseCompleted: (e) => _purchaseCompleted(e, emit),
      );
    });

    // Initialize subscriptions
    _productsSubscription =
        _subscriptionService.productsStream.listen((products) {
      add(SubscriptionEvent.loadProducts());
    });

    _purchaseStatusSubscription =
        _subscriptionService.purchaseStatusStream.listen((success) {
      add(SubscriptionEvent.purchaseCompleted(success));
    });

    // Check if user is already subscribed
    _checkSubscriptionStatus();
  }

  Future<void> _initialize(
      _Initialize event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _subscriptionService.initialize();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _loadProducts(
      _LoadProducts event, Emitter<SubscriptionState> emit) async {
    logger.i('Load products');
    emit(state.copyWith(isLoading: true));
    final products = await _subscriptionService.productsStream.first;
    logger.i('Load products: $products');
    emit(state.copyWith(
      isLoading: false,
      products: products,
    ));
    logger.i('Load products: ${state.products}');
  }

  Future<void> _purchase(
      _Purchase event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isPurchaseInProgress: true));
    final success = await _subscriptionService.purchase(event.product);
    logger.i('Purchase check: $success');
    if (!success) {
      emit(state.copyWith(
        isPurchaseInProgress: false,
        errorMessage: 'Failed to start purchase process. Please check your internet connection and try again.',
      ));
    } else {
      // If purchase initiated successfully, keep the progress indicator
      // The actual completion will be handled by the purchase status stream
      logger.i('Purchase initiated successfully, waiting for completion');
    }
  }

  Future<void> _restorePurchases(
      _RestorePurchases event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isRestoringPurchases: true));
    await _subscriptionService.restorePurchases();
    emit(state.copyWith(isRestoringPurchases: false));
  }

  Future<void> _purchaseCompleted(
      _PurchaseCompleted event, Emitter<SubscriptionState> emit) async {
    logger.i('Purchase completed: $event');
    emit(state.copyWith(
      isPurchaseInProgress: false,
      isPurchaseCompleted: event.success,
      isSubscribed: event.success,
      errorMessage: event.success
          ? ''
          : (event.success == false ? 'Purchase failed or was canceled' : ''),
    ));
  }

  Future<void> _checkSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSubscribed = prefs.getBool('isSubscribed') ?? false;

    if (isSubscribed) {
      // Check if subscription is still valid
      final expiryDateStr = prefs.getString('subscriptionExpiry');
      if (expiryDateStr != null) {
        final expiryDate = DateTime.tryParse(expiryDateStr);
        final isValid =
            expiryDate != null && expiryDate.isAfter(DateTime.now());

        if (isValid) {
          // add(const SubscriptionEvent.purchaseCompleted(true));
        } else {
          // Subscription expired
          await prefs.setBool('isSubscribed', false);
        }
      }
    }
  }

  @override
  Future<void> close() {
    logger.i('Close subscription bloc');
    _productsSubscription.cancel();
    _purchaseStatusSubscription.cancel();
    return super.close();
  }
}
