

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:deenhub/core/utils/primitive_utils.dart';
import 'package:deenhub/main.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/services/supabase_provider.dart';
import 'package:deenhub/core/services/shared_prefs_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/notification/services/subscription_notification_service.dart';
import '../../domain/models/subscription_product.dart';

class SubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final StreamController<List<SubscriptionProduct>> _productsController =
  StreamController<List<SubscriptionProduct>>.broadcast();
  final StreamController<bool> _purchaseStatusController =
  StreamController<bool>.broadcast();

  // ADD: Subscription status change stream
  final StreamController<bool> _subscriptionStatusController =
  StreamController<bool>.broadcast();

  Stream<List<SubscriptionProduct>> get productsStream =>
      _productsController.stream;
  Stream<bool> get purchaseStatusStream => _purchaseStatusController.stream;

  // ADD: Expose subscription status stream
  Stream<bool> get subscriptionStatusStream => _subscriptionStatusController.stream;

  bool _isAvailable = false;
  List<SubscriptionProduct> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs
  static const String _barakahAccessId = 'deenhub_barakah_access';
  static const String _quranLiteId = 'deenhub_quran_lite';
  static const String _deenhubProId = 'deenhub_pro';
  static const String _quranLiteYearlyId = 'deenhub_quran_lite_yearly';
  static const String _deenhubProYearlyId = 'deenhub_pro_yearly';

  Set<String> get _productIds => {
    _quranLiteId,
    _deenhubProId,
    _quranLiteYearlyId,
    _deenhubProYearlyId,
  };

  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();

    logger.i('🔄 IAP Available: $_isAvailable');

    if (!_isAvailable) {
      _productsController.add([]);
      // Still load mock products for UI display
      await loadProducts();
      // Start real-time monitoring even if IAP is not available
      await startRealTimeSubscriptionMonitoring();
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(_IAPPaymentQueueDelegate());
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _updateStreamOnDone,
      onError: _updateStreamOnError,
    );

    // Validate existing subscription status
    await validateSubscriptionStatus();

    await loadProducts();

    // Start real-time subscription monitoring
    await startRealTimeSubscriptionMonitoring();
  }

  Future<void> loadProducts() async {
    try {
      logger.i('📦 Loading subscription products...');

      // Always provide all plans (including free Barakah Access)
      _products = [
        // Monthly plans
        SubscriptionProduct(
          id: _barakahAccessId,
          title: 'Barakah Access',
          description: 'For those who cannot afford',
          price: 0.0,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.monthly,
          type: SubscriptionType.barakahAccess,
          productDetails: null,
          isPopular: false,
          features: [
            '📖 Full Quran access',
            '🧠 Memorization tools',
            '🕋 Mosque locator',
          ],
          specialNote:
          '"We trust your intention. If you\'re genuinely unable to pay, consider it a gift. Allah knows best and is a sufficient witness."',
        ),
        SubscriptionProduct(
          id: _quranLiteId,
          title: 'Quran Lite',
          description: 'Essential Quran features at an affordable price',
          price: 0.99,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.monthly,
          type: SubscriptionType.quranLite,
          productDetails: null,
          isPopular: false,
          features: [
            '📖 Full Quran access',
            '🧠 Memorization tools and daily goals',
            '🎧 Audio recitations',
            '🔍 Search by verse and chapter',
          ],
          sponsorNote:
          '"We need your support to keep DeenHub running and make Quran access available for everyone."',
        ),
        SubscriptionProduct(
          id: _deenhubProId,
          title: 'DeenHub Pro',
          description:
          'Unlock the full spiritual experience and support others on their journey',
          price: 4.99,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.monthly,
          type: SubscriptionType.deenhubPro,
          productDetails: null,
          isPopular: true,
          features: [
            '✅ Everything in Quran Lite',
            '📚 Full Hadith collection with advanced search',
            '🤖 AI-powered chatbot for Islamic guidance',
            '💡 AI Quran explanation for deeper understanding',
            '🧭 Personalized spiritual goals & reminders',
            '🚫 100% Ad-free experience',
          ],
          sponsorNote:
          'Your subscription helps fund free Quran access for those in need.',
        ),
        // Yearly plans
        SubscriptionProduct(
          id: _barakahAccessId,
          title: 'Barakah Access',
          description: 'For those who cannot afford',
          price: 0.0,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.yearly,
          type: SubscriptionType.barakahAccess,
          productDetails: null,
          isPopular: false,
          features: [
            '📖 Full Quran access',
            '🧠 Memorization tools',
            '🕋 Mosque locator',
          ],
          specialNote:
          '"We trust your intention. If you\'re genuinely unable to pay, consider it a gift. Allah knows best and is a sufficient witness."',
        ),
        SubscriptionProduct(
          id: _quranLiteYearlyId,
          title: 'Quran Lite',
          description: 'Yearly plan — simple and affordable',
          price: 9.99,
          originalPrice: 11.99,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.yearly,
          type: SubscriptionType.quranLite,
          productDetails: null,
          isPopular: false,
          features: [
            '📖 Full Quran access',
            '🧠 Memorization tools and daily goals',
            '🎧 Audio recitations',
            '🔍 Search by verse and chapter',
          ],
          sponsorNote:
          'Your yearly support keeps Quran access available for everyone.',
        ),
        SubscriptionProduct(
          id: _deenhubProYearlyId,
          title: 'DeenHub Pro',
          description: 'Yearly plan with special savings',
          price: 49.99,
          originalPrice: 59.99,
          currencyCode: 'USD',
          currencySymbol: '\$',
          period: SubscriptionPeriod.yearly,
          type: SubscriptionType.deenhubPro,
          productDetails: null,
          isPopular: true,
          features: [
            '✅ Everything in Quran Lite',
            '📚 Full Hadith collection with advanced search',
            '🤖 AI-powered chatbot for Islamic guidance',
            '💡 AI Quran explanation for deeper understanding',
            '🧭 Personalized spiritual goals & reminders',
            '🚫 100% Ad-free experience',
          ],
          sponsorNote: 'Save with yearly and support those in need.',
        ),
      ];

      // Try to get actual product details from store if available
      if (_isAvailable) {
        logger.i('🔄 Querying store for product details...');
        final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);

        logger.i('📦 Store returned ${response.productDetails.length} products');
        logger.i('❌ Not found: ${response.notFoundIDs}');

        if (response.productDetails.isNotEmpty) {
          for (final product in response.productDetails) {
            logger.i('✅ Found product: ${product.id} - ${product.title} - ${product.price}');

            final index = _products.indexWhere((p) => p.id == product.id);
            if (index != -1) {
              // Parse price string to double
              final priceString =
              product.price.replaceAll(RegExp(r'[^0-9.,]'), '');
              final price = double.tryParse(priceString.replaceAll(',', '.')) ??
                  _products[index].price;

              _products[index] = _products[index].copyWith(
                productDetails: product,
                price: price,
                currencyCode: product.currencyCode,
                currencySymbol: product.currencySymbol,
              );

              logger.i('✅ Updated product details for: ${product.id}');
            }
          }
        } else {
          logger.w('⚠️ No products found in store. Using mock data.');
        }
      } else {
        logger.w('⚠️ Store not available. Using mock data.');
      }

      _productsController.add(_products);
      logger.i('✅ Products loaded successfully: ${_products.length}');
    } catch (e) {
      logger.e('❌ Error loading products: $e');
      // Still provide the default products
      _productsController.add(_products);
    }
  }

  Future<bool> purchase(SubscriptionProduct product) async {
    try {
      logger.i('🛒 Starting purchase for: ${product.id}');

      // Handle Barakah Access (free) separately
      if (product.type == SubscriptionType.barakahAccess) {
        logger.i('✅ Barakah Access - Free subscription');
        await _handleBarakahAccess(product);
        return true;
      }

      // Check if IAP is available
      if (!_isAvailable) {
        logger.e('❌ IAP not available on this device');
        // In debug mode, allow simulated purchases even if IAP is not available
        if (kDebugMode) {
          logger.i('⚠️ IAP not available but in debug mode - simulating purchase');
          await _simulatePurchase(product);
          return true;
        } else {
          _purchaseStatusController.add(false);
          return false;
        }
      }

      // For development/testing - simulate purchase if product details missing
      if (product.productDetails == null) {
        if (kDebugMode) {
          logger.i('⚠️ Development mode - simulating purchase');
          await _simulatePurchase(product);
          return true;
        } else {
          logger.e('❌ Product details not available. Product not configured in store.');
          _purchaseStatusController.add(false);
          return false;
        }
      }

      // Start real purchase
      logger.i('🔄 Starting real purchase process...');
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product.productDetails!,
        applicationUserName: null,
      );

      bool result = false;
      if (Platform.isAndroid) {
        logger.i('🤖 Android - Using buyNonConsumable');
        result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else if (Platform.isIOS) {
        logger.i('🍎 iOS - Using buyNonConsumable');
        result = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      logger.i('Purchase initiated: $result');
      return result;
    } catch (e) {
      logger.e('❌ Error purchasing product: $e');
      _purchaseStatusController.add(false);
      return false;
    }
  }

  // Handle Barakah Access (free subscription)
  Future<void> _handleBarakahAccess(SubscriptionProduct product) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('subscriptionType', 'barakah_access');

    final expiryDate = DateTime.now().add(const Duration(days: 180)); // 6 months
    await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
    await prefs.setString('subscriptionPeriod', 'monthly');

    await _updateSubscriptionInSupabase('barakah_access', expiryDate);

    _purchaseStatusController.add(true);
    _subscriptionStatusController.add(true); // ADD: Broadcast status change

    Future.microtask(() async {
      try {
        final notificationService = getIt<SubscriptionNotificationService>();
        await notificationService.showSubscriptionSuccessNotification(
          subscriptionType: 'Barakah Access',
        );
      } catch (e) {
        logger.e('Error showing notification: $e');
      }
    });
  }

  // Direct subscription for Barakah Access
  Future<bool> subscribeToBarakahAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('subscriptionType', 'barakah_access');

      final expiryDate = DateTime.now().add(const Duration(days: 180));
      await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
      await prefs.setString('subscriptionPeriod', 'monthly');

      await _updateSubscriptionInSupabase('barakah_access', expiryDate);

      _purchaseStatusController.add(true);
      _subscriptionStatusController.add(true); // ADD: Broadcast status change

      Future.microtask(() async {
        try {
          final notificationService = getIt<SubscriptionNotificationService>();
          await notificationService.showSubscriptionSuccessNotification(
            subscriptionType: 'Barakah Access',
          );
        } catch (e) {
          logger.e('Error showing notification: $e');
        }
      });

      logger.i('✅ Barakah Access subscription activated');
      return true;
    } catch (e) {
      logger.e('❌ Error subscribing to Barakah Access: $e');
      return false;
    }
  }

  // Update subscription in Supabase
  Future<void> _updateSubscriptionInSupabase(
      String subscriptionType, DateTime expiryDate) async {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      final userId = prefsHelper.userId;

      if (userId == null) {
        logger.w('⚠️ No user ID - skipping Supabase update');
        return;
      }

      final supabase = getIt<SupabaseProvider>().client;

      await supabase.from('user_profiles').update({
        'subscription_status': subscriptionType,
        'subscription_expiry': expiryDate.toIso8601String(),
        'has_subscription': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      logger.i('✅ Supabase updated: $subscriptionType');

      // Update local cache
      prefsHelper.setSubscriptionStatus = subscriptionType;
      prefsHelper.setSubscriptionExpiry = expiryDate;
      prefsHelper.sharedPrefs.saveData('isSubscribed', true);

      Future.microtask(() async {
        try {
          final notificationService = getIt<SubscriptionNotificationService>();
          await notificationService.showSubscriptionSuccessNotification(
            subscriptionType: subscriptionType,
          );
        } catch (e) {
          logger.e('Error showing notification: $e');
        }
      });
    } catch (e) {
      logger.e('❌ Error updating Supabase: $e');
    }
  }

  // Simulate purchase for development
  Future<void> _simulatePurchase(SubscriptionProduct product) async {
    final prefs = await SharedPreferences.getInstance();

    String subscriptionTypeStr;
    switch (product.type) {
      case SubscriptionType.barakahAccess:
        subscriptionTypeStr = 'barakah_access';
        break;
      case SubscriptionType.quranLite:
        subscriptionTypeStr = 'quran_lite';
        break;
      case SubscriptionType.deenhubPro:
        subscriptionTypeStr = 'deenhub_pro';
        break;
    }
    await prefs.setString('subscriptionType', subscriptionTypeStr);

    // Save period
    final periodStr = product.period == SubscriptionPeriod.yearly ? 'yearly' : 'monthly';
    await prefs.setString('subscriptionPeriod', periodStr);

    final now = DateTime.now();
    final expiryDate = product.period == SubscriptionPeriod.monthly
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));
    await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());

    await _updateSubscriptionInSupabase(subscriptionTypeStr, expiryDate);

    _purchaseStatusController.add(true);
    _subscriptionStatusController.add(true); // ADD: Broadcast status change

    logger.i('✅ Simulated purchase successful: $subscriptionTypeStr');
  }

  Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      logger.w('⚠️ Cannot restore - IAP not available');
      return false;
    }

    try {
      logger.i('🔄 Starting purchase restoration...');
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      logger.e('❌ Error restoring purchases: $e');
      return false;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    logger.i('📦 Purchase update received: ${purchaseDetailsList.length} items');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      await _processPurchase(purchaseDetails);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    logger.i('🔄 Processing purchase: ${purchaseDetails.productID} - ${purchaseDetails.status}');

    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        logger.i('⏳ Purchase pending: ${purchaseDetails.productID}');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        logger.i('✅ Purchase successful/restored: ${purchaseDetails.productID}');
        await _handleSuccessfulPurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        logger.e('❌ Purchase error: ${purchaseDetails.error?.message}');
        _handlePurchaseError(purchaseDetails.error!);
        _purchaseStatusController.add(false);
        break;

      case PurchaseStatus.canceled:
        logger.i('❌ Purchase canceled: ${purchaseDetails.productID}');
        _purchaseStatusController.add(false);
        break;
    }

    if (purchaseDetails.pendingCompletePurchase) {
      logger.i('✅ Completing purchase: ${purchaseDetails.productID}');
      await _iap.completePurchase(purchaseDetails);
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    logger.i('🔄 Verifying purchase: ${purchaseDetails.productID}');

    final bool isValid = await _verifyPurchaseWithValidation(purchaseDetails);

    if (isValid) {
      logger.i('✅ Purchase verified and activated');
      _purchaseStatusController.add(true);

      Future.microtask(() async {
        try {
          final notificationService = getIt<SubscriptionNotificationService>();
          String subscriptionType = 'DeenHub';
          if (purchaseDetails.productID.contains('deenhub_pro')) {
            subscriptionType = 'DeenHub Pro';
          } else if (purchaseDetails.productID.contains('quran_lite')) {
            subscriptionType = 'Quran Lite';
          } else if (purchaseDetails.productID.contains('barakah_access')) {
            subscriptionType = 'Barakah Access';
          }

          await notificationService.showSubscriptionSuccessNotification(
            subscriptionType: subscriptionType,
          );
        } catch (e) {
          logger.e('Error showing notification: $e');
        }
      });
    } else {
      logger.e('❌ Purchase verification failed');
      _purchaseStatusController.add(false);
    }
  }

  Future<bool> _verifyPurchaseWithValidation(PurchaseDetails purchaseDetails) async {
    try {
      if (Platform.isIOS) {
        return await _verifyIOSPurchase(purchaseDetails);
      }

      if (Platform.isAndroid) {
        return await _verifyAndroidPurchase(purchaseDetails);
      }

      return false;
    } catch (e) {
      logger.e('❌ Verification error: $e');
      return false;
    }
  }

  Future<bool> _verifyIOSPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final receiptData = purchaseDetails.verificationData.localVerificationData;

      bool isValid = await _verifyIOSReceipt(receiptData, false);

      if (!isValid) {
        logger.i('🔄 Trying sandbox environment...');
        isValid = await _verifyIOSReceipt(receiptData, true);
      }

      if (isValid) {
        await _storeValidatedPurchase(purchaseDetails);
      }

      return isValid;
    } catch (e) {
      logger.e('❌ iOS verification error: $e');
      return false;
    }
  }

  Future<bool> _verifyIOSReceipt(String receiptData, bool isSandbox) async {
    try {
      final url = isSandbox
          ? 'https://sandbox.itunes.apple.com/verifyReceipt'
          : 'https://buy.itunes.apple.com/verifyReceipt';

      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receipt-data': receiptData,
          'password': '1807a910b2cf49409e5c88e4f9d9d6de',
          "exclude-old-transactions": true
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final status = responseData['status'];

        if (status == 0) {
          return true;
        } else if (status == 21007) {
          return !isSandbox;
        } else {
          logger.e('❌ App Store status: $status');
          return false;
        }
      }

      return false;
    } on TimeoutException {
      logger.e('❌ Verification timeout');
      return false;
    } catch (e) {
      logger.e('❌ Receipt verification error: $e');
      return false;
    }
  }

  Future<bool> _verifyAndroidPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final androidPurchase = purchaseDetails as GooglePlayPurchaseDetails;
      final purchaseToken = androidPurchase.billingClientPurchase.purchaseToken;
      final productId = androidPurchase.productID;

      final isValid = purchaseToken.isNotEmpty &&
          (productId == _quranLiteId ||
              productId == _deenhubProId ||
              productId == _quranLiteYearlyId ||
              productId == _deenhubProYearlyId);

      if (isValid) {
        await _storeValidatedPurchase(purchaseDetails);
      }

      return isValid;
    } catch (e) {
      logger.e('❌ Android verification error: $e');
      return false;
    }
  }

  Future<void> _storeValidatedPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String subscriptionTypeStr;
      Duration subscriptionDuration;

      if (purchaseDetails.productID == _barakahAccessId) {
        subscriptionTypeStr = 'barakah_access';
        subscriptionDuration = const Duration(days: 180);
      } else if (purchaseDetails.productID == _quranLiteId) {
        subscriptionTypeStr = 'quran_lite';
        subscriptionDuration = const Duration(days: 30);
      } else if (purchaseDetails.productID == _deenhubProId) {
        subscriptionTypeStr = 'deenhub_pro';
        subscriptionDuration = const Duration(days: 30);
      } else if (purchaseDetails.productID == _quranLiteYearlyId) {
        subscriptionTypeStr = 'quran_lite';
        subscriptionDuration = const Duration(days: 365);
      } else if (purchaseDetails.productID == _deenhubProYearlyId) {
        subscriptionTypeStr = 'deenhub_pro';
        subscriptionDuration = const Duration(days: 365);
      } else {
        subscriptionTypeStr = 'barakah_access';
        subscriptionDuration = const Duration(days: 180);
      }

      await prefs.setString('subscriptionType', subscriptionTypeStr);

      // Store period
      if (purchaseDetails.productID == _quranLiteId ||
          purchaseDetails.productID == _deenhubProId) {
        await prefs.setString('subscriptionPeriod', 'monthly');
      } else if (purchaseDetails.productID == _quranLiteYearlyId ||
          purchaseDetails.productID == _deenhubProYearlyId) {
        await prefs.setString('subscriptionPeriod', 'yearly');
      }

      await prefs.setString('purchaseToken',
          purchaseDetails.verificationData.serverVerificationData);
      await prefs.setString(
          'purchaseSource', purchaseDetails.verificationData.source);
      await prefs.setString('productId', purchaseDetails.productID);

      final now = DateTime.now();
      final expiryDate = now.add(subscriptionDuration);
      await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());

      await _updateSubscriptionInSupabase(subscriptionTypeStr, expiryDate);

      // ADD: Broadcast subscription status change
      _subscriptionStatusController.add(true);

      logger.i('✅ Purchase stored: $subscriptionTypeStr');
    } catch (e) {
      logger.e('❌ Error storing purchase: $e');
      rethrow;
    }
  }

  void _handlePurchaseError(IAPError error) {
    logger.e('❌ Purchase error: ${error.message} (${error.code})');
  }

  void _updateStreamOnDone() {
    _subscription.cancel();
  }

  void _updateStreamOnError(dynamic error) {
    logger.e('❌ IAP stream error: $error');
  }

  void dispose() {
    _subscription.cancel();
    _productsController.close();
    _purchaseStatusController.close();
    _subscriptionStatusController.close(); // ADD
  }

  // Check active subscription
  static Future<bool> hasActiveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;
      final expiryDateStr = prefs.getString('subscriptionExpiry');

      if (subscriptionType.isNullOrEmpty || subscriptionType == 'free') {
        return false;
      }

      if (expiryDateStr == null) {
        return false;
      }

      final expiryDate = DateTime.tryParse(expiryDateStr);
      if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
        await _clearExpiredSubscriptionData();
        return false;
      }

      return true;
    } catch (e) {
      logger.e('Error checking subscription: $e');
      return false;
    }
  }

  static Future<void> _clearExpiredSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('subscriptionType');
    await prefs.remove('subscriptionExpiry');
    await prefs.remove('purchaseToken');
    await prefs.remove('purchaseSource');
    await prefs.remove('productId');
    await prefs.remove('subscriptionPeriod');

    logger.i('🗑️ Cleared expired subscription data');
  }

  static Future<bool> isDeenHubProSubscribed() async {
    if (!await hasActiveSubscription()) return false;
    final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;
    return subscriptionType == 'deenhub_pro';
  }

  static Future<SubscriptionType?> getCurrentSubscriptionType() async {
    if (!await hasActiveSubscription()) return null;
    final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;

    switch (subscriptionType) {
      case 'barakah_access':
        return SubscriptionType.barakahAccess;
      case 'quran_lite':
        return SubscriptionType.quranLite;
      case 'deenhub_pro':
        return SubscriptionType.deenhubPro;
      default:
        return null;
    }
  }

  static Future<bool> canAccessAIFeatures() async {
    return await isDeenHubProSubscribed();
  }

  static Future<bool> hasAnySubscription() async {
    return await hasActiveSubscription();
  }

  static Future<bool> canAccessQuranFeatures() async {
    return await hasAnySubscription();
  }

  Future<bool> validateSubscriptionStatus() async {
    if (!_isAvailable) return false;

    try {
      return await hasActiveSubscription();
    } catch (e) {
      logger.e('Error validating subscription: $e');
      return false;
    }
  }



  // ADD: Method to start real-time subscription status monitoring
  Future<void> startRealTimeSubscriptionMonitoring() async {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      final userId = prefsHelper.userId;

      if (userId == null) {
        logger.w('⚠️ No user ID - cannot start real-time subscription monitoring');
        return;
      }

      final supabase = getIt<SupabaseProvider>().client;

      // Subscribe to real-time updates for user's subscription status
      supabase
          .channel('user_profiles_changes')
          .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'user_profiles',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) {
          logger.i('Real-time subscription update received for user $userId: ${payload.newRecord}');

          // Check if subscription-related fields have changed
          final subscriptionStatus = payload.newRecord['subscription_status'];
          final subscriptionExpiry = payload.newRecord['subscription_expiry'];
          final hasSubscription = payload.newRecord['has_subscription'] ?? false;

          if (subscriptionStatus != null || subscriptionExpiry != null) {
            // Update local storage with new values
            _updateLocalSubscriptionData(
              subscriptionStatus: subscriptionStatus,
              subscriptionExpiry: subscriptionExpiry,
              hasSubscription: hasSubscription,
            );

            // Broadcast the status change to update UI
            _subscriptionStatusController.add(hasSubscription);

            logger.i('✅ Real-time subscription update processed: $subscriptionStatus');
          }
        },
      )
          .subscribe();

      logger.i('✅ Real-time subscription monitoring started for user: $userId');
    } catch (e) {
      logger.e('❌ Error starting real-time subscription monitoring: $e');
    }
  }

  // // ADD: Method to start real-time subscription status monitoring
  // Future<void> startRealTimeSubscriptionMonitoring() async {
  //   try {
  //     final prefsHelper = getIt<SharedPrefsHelper>();
  //     final userId = prefsHelper.userId;
  //
  //     if (userId == null) {
  //       logger.w('⚠️ No user ID - cannot start real-time subscription monitoring');
  //       return;
  //     }
  //
  //     final supabase = getIt<SupabaseProvider>().client;
  //
  //     // Subscribe to real-time updates for user's subscription status
  //     final subscription = supabase
  //         .from('user_profiles')
  //         .on(SupabaseEventTypes.update, (payload) {
  //           // Check if this update is for the current user
  //           if (payload.newRecord['user_id'] == userId) {
  //             logger.i('Real-time subscription update received for user $userId: ${payload.newRecord}');
  //
  //             // Check if subscription-related fields have changed
  //             final subscriptionStatus = payload.newRecord['subscription_status'];
  //             final subscriptionExpiry = payload.newRecord['subscription_expiry'];
  //             final hasSubscription = payload.newRecord['has_subscription'] ?? false;
  //
  //             if (subscriptionStatus != null || subscriptionExpiry != null) {
  //               // Update local storage with new values
  //               _updateLocalSubscriptionData(
  //                 subscriptionStatus: subscriptionStatus,
  //                 subscriptionExpiry: subscriptionExpiry,
  //                 hasSubscription: hasSubscription,
  //               );
  //
  //               // Broadcast the status change to update UI
  //               _subscriptionStatusController.add(hasSubscription);
  //
  //               logger.i('✅ Real-time subscription update processed: $subscriptionStatus');
  //             }
  //           }
  //         })
  //         .filter('user_id', 'eq', userId)
  //         .subscribe();
  //
  //     logger.i('✅ Real-time subscription monitoring started for user: $userId');
  //   } catch (e) {
  //     logger.e('❌ Error starting real-time subscription monitoring: $e');
  //   }
  // }

  // Helper method to update local subscription data
  Future<void> _updateLocalSubscriptionData({
    String? subscriptionStatus,
    String? subscriptionExpiry,
    bool? hasSubscription,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsHelper = getIt<SharedPrefsHelper>();

      // Get current values to compare with new values
      final currentSubscriptionStatus = prefsHelper.subscriptionStatus;

      if (subscriptionStatus != null) {
        await prefs.setString('subscriptionType', subscriptionStatus);
        prefsHelper.setSubscriptionStatus = subscriptionStatus;
      }

      if (subscriptionExpiry != null) {
        await prefs.setString('subscriptionExpiry', subscriptionExpiry);
        prefsHelper.setSubscriptionExpiry = DateTime.parse(subscriptionExpiry);
      }

      if (hasSubscription != null) {
        await prefs.setBool('isSubscribed', hasSubscription);
        prefsHelper.sharedPrefs.saveData('isSubscribed', hasSubscription);
      }

      // Check if subscription status changed and send notification if it did
      if (currentSubscriptionStatus != subscriptionStatus && subscriptionStatus != null) {
        Future.microtask(() async {
          try {
            final notificationService = getIt<SubscriptionNotificationService>();

            if (currentSubscriptionStatus != null && currentSubscriptionStatus != 'free') {
              // Subscription was upgraded
              await notificationService.showSubscriptionUpgradeNotification(
                currentPlan: currentSubscriptionStatus,
                newPlan: subscriptionStatus,
              );
            } else if (hasSubscription == true) {
              // New subscription activated
              await notificationService.showSubscriptionSuccessNotification(
                subscriptionType: subscriptionStatus,
              );
            }
          } catch (e) {
            logger.e('Error showing subscription notification: $e');
          }
        });
      }

      logger.i('✅ Local subscription data updated: $subscriptionStatus');
    } catch (e) {
      logger.e('❌ Error updating local subscription data: $e');
    }
  }

  // ADD: Method to handle admin subscription updates
  Future<void> handleAdminSubscriptionUpdate({
    required String subscriptionType,
    required String subscriptionExpiry,
    required bool hasSubscription,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefsHelper = getIt<SharedPrefsHelper>();

      // Get current values to compare with new values
      final currentSubscriptionStatus = prefsHelper.subscriptionStatus;

      // Update local storage with admin-provided values
      await prefs.setString('subscriptionType', subscriptionType);
      await prefs.setString('subscriptionExpiry', subscriptionExpiry);
      await prefs.setBool('isSubscribed', hasSubscription);

      prefsHelper.setSubscriptionStatus = subscriptionType;
      prefsHelper.setSubscriptionExpiry = DateTime.parse(subscriptionExpiry);
      prefsHelper.sharedPrefs.saveData('isSubscribed', hasSubscription);

      // Check if subscription status changed and send notification if it did
      if (currentSubscriptionStatus != subscriptionType) {
        Future.microtask(() async {
          try {
            final notificationService = getIt<SubscriptionNotificationService>();

            if (currentSubscriptionStatus != null && currentSubscriptionStatus != 'free') {
              // Subscription was upgraded
              await notificationService.showSubscriptionUpgradeNotification(
                currentPlan: currentSubscriptionStatus,
                newPlan: subscriptionType,
              );
            } else if (hasSubscription) {
              // New subscription activated
              await notificationService.showSubscriptionSuccessNotification(
                subscriptionType: subscriptionType,
              );
            }
          } catch (e) {
            logger.e('Error showing subscription notification: $e');
          }
        });
      }

      // Broadcast the status change to update UI
      _subscriptionStatusController.add(hasSubscription);

      logger.i('✅ Admin subscription update processed: $subscriptionType');
    } catch (e) {
      logger.e('❌ Error handling admin subscription update: $e');
    }
  }

  // ADD: Method to force refresh subscription status from Supabase
  Future<void> refreshSubscriptionStatus() async {
    try {
      final prefsHelper = getIt<SharedPrefsHelper>();
      final userId = prefsHelper.userId;

      if (userId == null) {
        logger.w('⚠️ No user ID - cannot refresh subscription status');
        return;
      }

      final supabase = getIt<SupabaseProvider>().client;

      final response = await supabase
          .from('user_profiles')
          .select('subscription_status, subscription_expiry, has_subscription')
          .eq('user_id', userId)
          .single();

      if (response != null) {
        final prefs = await SharedPreferences.getInstance();

        // Get current values to compare with new values
        final currentSubscriptionStatus = prefsHelper.subscriptionStatus;
        final currentExpiry = prefsHelper.subscriptionExpiry;

        // Update local storage with fresh data from Supabase
        final subscriptionStatus = response['subscription_status'];
        final subscriptionExpiry = response['subscription_expiry'];
        final hasSubscription = response['has_subscription'] ?? false;

        if (subscriptionStatus != null) {
          await prefs.setString('subscriptionType', subscriptionStatus);
          prefsHelper.setSubscriptionStatus = subscriptionStatus;
        }

        if (subscriptionExpiry != null) {
          await prefs.setString('subscriptionExpiry', subscriptionExpiry);
          prefsHelper.setSubscriptionExpiry = DateTime.parse(subscriptionExpiry);
        }

        await prefs.setBool('isSubscribed', hasSubscription);
        prefsHelper.sharedPrefs.saveData('isSubscribed', hasSubscription);

        // Check if subscription status changed and send notification if it did
        if (currentSubscriptionStatus != subscriptionStatus) {
          Future.microtask(() async {
            try {
              final notificationService = getIt<SubscriptionNotificationService>();

              if (currentSubscriptionStatus != null && currentSubscriptionStatus != 'free') {
                // Subscription was upgraded
                await notificationService.showSubscriptionUpgradeNotification(
                  currentPlan: currentSubscriptionStatus,
                  newPlan: subscriptionStatus,
                );
              } else if (hasSubscription) {
                // New subscription activated
                await notificationService.showSubscriptionSuccessNotification(
                  subscriptionType: subscriptionStatus,
                );
              }
            } catch (e) {
              logger.e('Error showing subscription notification: $e');
            }
          });
        }

        // Broadcast the status change to update UI
        _subscriptionStatusController.add(hasSubscription);

        logger.i('✅ Subscription status refreshed from Supabase: $subscriptionStatus');
      }
    } catch (e) {
      logger.e('❌ Error refreshing subscription status: $e');
    }
  }
}

// iOS Payment Queue Delegate
class _IAPPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction,
      SKStorefrontWrapper storefront,
      ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}






































// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:deenhub/core/utils/primitive_utils.dart';
// import 'package:deenhub/main.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_android/in_app_purchase_android.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
// import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deenhub/core/di/app_injections.dart';
// import 'package:deenhub/core/services/supabase_provider.dart';
// import 'package:deenhub/core/services/shared_prefs_helper.dart';
//
// import '../../../../core/notification/services/subscription_notification_service.dart';
// import '../../domain/models/subscription_product.dart';
//
// class SubscriptionService {
//   final InAppPurchase _iap = InAppPurchase.instance;
//   final StreamController<List<SubscriptionProduct>> _productsController =
//       StreamController<List<SubscriptionProduct>>.broadcast();
//   final StreamController<bool> _purchaseStatusController =
//       StreamController<bool>.broadcast();
//
//   Stream<List<SubscriptionProduct>> get productsStream =>
//       _productsController.stream;
//   Stream<bool> get purchaseStatusStream => _purchaseStatusController.stream;
//
//   bool _isAvailable = false;
//   List<SubscriptionProduct> _products = [];
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//
//   // Product IDs
//   static const String _barakahAccessId = 'deenhub_barakah_access';
//   static const String _quranLiteId = 'deenhub_quran_lite';
//   static const String _deenhubProId = 'deenhub_pro';
//   static const String _quranLiteYearlyId = 'deenhub_quran_lite_yearly';
//   static const String _deenhubProYearlyId = 'deenhub_pro_yearly';
//
//   Set<String> get _productIds => {
//         _quranLiteId,
//         _deenhubProId,
//         _quranLiteYearlyId,
//         _deenhubProYearlyId,
//       };
//
//   Future<void> initialize() async {
//     _isAvailable = await _iap.isAvailable();
//
//     if (!_isAvailable) {
//       _productsController.add([]);
//       return;
//     }
//
//     if (Platform.isIOS) {
//       final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
//           _iap.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
//       await iosPlatformAddition.setDelegate(_IAPPaymentQueueDelegate());
//     }
//
//     _subscription = _iap.purchaseStream.listen(
//       _onPurchaseUpdate,
//       onDone: _updateStreamOnDone,
//       onError: _updateStreamOnError,
//     );
//
//     // Validate existing subscription status
//     await validateSubscriptionStatus();
//
//     await loadProducts();
//   }
//
//   Future<void> loadProducts() async {
//     try {
//       // Always provide all plans (including free Barakah Access)
//       _products = [
//         SubscriptionProduct(
//           id: _barakahAccessId,
//           title: 'Barakah Access',
//           description: 'For those who cannot afford',
//           price: 0.0,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.monthly,
//           type: SubscriptionType.barakahAccess,
//           productDetails: null,
//           isPopular: false,
//           features: [
//             '📖 Full Quran access',
//             '🧠 Memorization tools',
//             '🕋 Mosque locator',
//           ],
//           specialNote:
//               '"We trust your intention. If you\'re genuinely unable to pay, consider it a gift. Allah knows best and is a sufficient witness."',
//         ),
//         SubscriptionProduct(
//           id: _quranLiteId,
//           title: 'Quran Lite',
//           description: 'Essential Quran features at an affordable price',
//           price: 0.99,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.monthly,
//           type: SubscriptionType.quranLite,
//           productDetails: null,
//           isPopular: false,
//           features: [
//             '📖 Full Quran access',
//             '🧠 Memorization tools and daily goals',
//             '🎧 Audio recitations',
//             '🔍 Search by verse and chapter',
//           ],
//           sponsorNote:
//               '"We need your support to keep DeenHub running and make Quran access available for everyone."',
//         ),
//         SubscriptionProduct(
//           id: _deenhubProId,
//           title: 'DeenHub Pro',
//           description:
//               'Unlock the full spiritual experience and support others on their journey',
//           price: 4.99,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.monthly,
//           type: SubscriptionType.deenhubPro,
//           productDetails: null,
//           isPopular: true,
//           features: [
//             '✅ Everything in Quran Lite',
//             '📚 Full Hadith collection with advanced search',
//             '🤖 AI-powered chatbot for Islamic guidance',
//             '💡 AI Quran explanation for deeper understanding',
//             '🧭 Personalized spiritual goals & reminders',
//             '🚫 100% Ad-free experience',
//           ],
//           sponsorNote:
//               'Your subscription helps fund free Quran access for those in need.',
//         ),
//         // Yearly plans
//         SubscriptionProduct(
//           id: _barakahAccessId,
//           title: 'Barakah Access',
//           description: 'For those who cannot afford',
//           price: 0.0,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.yearly,
//           type: SubscriptionType.barakahAccess,
//           productDetails: null,
//           isPopular: false,
//           features: [
//             '📖 Full Quran access',
//             '🧠 Memorization tools',
//             '🕋 Mosque locator',
//           ],
//           specialNote:
//               '"We trust your intention. If you\'re genuinely unable to pay, consider it a gift. Allah knows best and is a sufficient witness."',
//         ),
//         SubscriptionProduct(
//           id: _quranLiteYearlyId,
//           title: 'Quran Lite',
//           description: 'Yearly plan — simple and affordable',
//           price: 9.99, // no discount yearly
//           originalPrice: 11.99,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.yearly,
//           type: SubscriptionType.quranLite,
//           productDetails: null,
//           isPopular: false,
//           features: [
//             '📖 Full Quran access',
//             '🧠 Memorization tools and daily goals',
//             '🎧 Audio recitations',
//             '🔍 Search by verse and chapter',
//           ],
//           sponsorNote:
//               'Your yearly support keeps Quran access available for everyone.',
//         ),
//         SubscriptionProduct(
//           id: _deenhubProYearlyId,
//           title: 'DeenHub Pro',
//           description: 'Yearly plan with special savings',
//           price: 49.99, // discounted yearly (vs 59.99)
//           originalPrice: 59.99,
//           currencyCode: 'USD',
//           currencySymbol: '\$',
//           period: SubscriptionPeriod.yearly,
//           type: SubscriptionType.deenhubPro,
//           productDetails: null,
//           isPopular: true,
//           features: [
//             '✅ Everything in Quran Lite',
//             '📚 Full Hadith collection with advanced search',
//             '🤖 AI-powered chatbot for Islamic guidance',
//             '💡 AI Quran explanation for deeper understanding',
//             '🧭 Personalized spiritual goals & reminders',
//             '🚫 100% Ad-free experience',
//           ],
//           sponsorNote: 'Save with yearly and support those in need.',
//         ),
//       ];
//
//       // Try to get actual product details from store
//       if (_isAvailable) {
//         final ProductDetailsResponse response =
//             await _iap.queryProductDetails(_productIds);
//
//         if (response.productDetails.isNotEmpty) {
//           for (final product in response.productDetails) {
//             final index = _products.indexWhere((p) => p.id == product.id);
//             if (index != -1) {
//               // Parse price string to double (remove currency symbol)
//               final priceString =
//                   product.price.replaceAll(RegExp(r'[^0-9.,]'), '');
//               final price = double.tryParse(priceString.replaceAll(',', '.')) ??
//                   _products[index].price;
//
//               _products[index] = _products[index].copyWith(
//                 productDetails: product,
//                 price: price,
//                 currencyCode: product.currencyCode,
//                 currencySymbol: product.currencySymbol,
//               );
//             }
//           }
//         }
//       }
//
//       _productsController.add(_products);
//     } catch (e) {
//       debugPrint('Error loading products: $e');
//       // Still provide the default products
//       _productsController.add(_products);
//     }
//   }
//
//   Future<bool> purchase(SubscriptionProduct product) async {
//     if (!_isAvailable) return false;
//
//     try {
//       // Handle Barakah Access (free) separately
//       if (product.type == SubscriptionType.barakahAccess) {
//         logger.i('Purchase barakah access');
//         await _handleBarakahAccess(product);
//         return true;
//       }
//
//       // If productDetails is null (mock product), simulate successful purchase for testing
//       if (product.productDetails == null && kDebugMode) {
//         // For development/testing only
//         logger.i('Purchase simulate');
//         await _simulatePurchase(product);
//         return true;
//       }
//
//       if (product.productDetails == null) {
//         logger.e('Error: Product details not available for real purchase');
//         return false;
//       }
//
//       final PurchaseParam purchaseParam = PurchaseParam(
//         productDetails: product.productDetails!,
//         applicationUserName: null,
//       );
//
//       // Start the purchase - use appropriate method for subscriptions
//       if (Platform.isAndroid) {
//         // On Android, use buyNonConsumable for subscriptions
//         return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//       } else if (Platform.isIOS) {
//         // On iOS, use buyNonConsumable for subscriptions
//         return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
//       }
//
//       logger.i('Purchase failed');
//       return false;
//     } catch (e) {
//       logger.e('Error purchasing product: $e');
//       return false;
//     }
//   }
//
//   // Handle Barakah Access (free subscription) - direct database update
//   Future<void> _handleBarakahAccess(SubscriptionProduct product) async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save subscription type
//     await prefs.setString('subscriptionType', 'barakah_access');
//
//     // Set expiry to a far future date for free access
//     final expiryDate =
//         DateTime.now().add(const Duration(days: 30 * 6)); // 6 months
//     await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
//
//     // Update Supabase database
//     await _updateSubscriptionInSupabase('barakah_access', expiryDate);
//
//     // Notify listeners
//     _purchaseStatusController.add(true);
//
//     // Show notification after successful subscription (non-blocking)
//     Future.microtask(() async {
//       try {
//         final notificationService = getIt<SubscriptionNotificationService>();
//         await notificationService.showSubscriptionSuccessNotification(
//           subscriptionType: 'Barakah Access',
//         );
//       } catch (e) {
//         debugPrint('Error showing subscription notification: $e');
//         // Don't throw error as this is just a notification
//       }
//     });
//   }
//
//   // Direct subscription for Barakah Access (bypasses store)
//   Future<bool> subscribeToBarakahAccess() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Save subscription type
//       await prefs.setString('subscriptionType', 'barakah_access');
//
//       // Set expiry to a far future date for free access
//       final expiryDate =
//           DateTime.now().add(const Duration(days: 30 * 6)); // 6 months
//       await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
//
//       // Update Supabase database
//       await _updateSubscriptionInSupabase('barakah_access', expiryDate);
//
//       // Notify listeners
//       _purchaseStatusController.add(true);
//
//       // Show notification after successful subscription (non-blocking)
//       Future.microtask(() async {
//         try {
//           final notificationService = getIt<SubscriptionNotificationService>();
//           await notificationService.showSubscriptionSuccessNotification(
//             subscriptionType: 'Barakah Access',
//           );
//         } catch (e) {
//           debugPrint('Error showing subscription notification: $e');
//           // Don't throw error as this is just a notification
//         }
//       });
//
//       debugPrint('Barakah Access subscription activated successfully');
//       return true;
//     } catch (e) {
//       debugPrint('Error subscribing to Barakah Access: $e');
//       return false;
//     }
//   }
//
//   // Update subscription status in Supabase database
//   Future<void> _updateSubscriptionInSupabase(
//       String subscriptionType, DateTime expiryDate) async {
//     try {
//       final prefsHelper = getIt<SharedPrefsHelper>();
//       final userId = prefsHelper.userId;
//
//       if (userId == null) {
//         debugPrint('No user ID found, cannot update subscription in Supabase');
//         return;
//       }
//
//       final supabase = getIt<SupabaseProvider>().client;
//
//       await supabase.from('user_profiles').update({
//         'subscription_status': subscriptionType,
//         'subscription_expiry': expiryDate.toIso8601String(),
//         'has_subscription': true,
//         'updated_at': DateTime.now().toIso8601String(),
//       }).eq('user_id', userId);
//
//       debugPrint(
//           'Subscription updated in Supabase: $subscriptionType expires ${expiryDate.toIso8601String()}');
//
//       // Update local shared preferences to immediately reflect the change
//       prefsHelper.setSubscriptionStatus = subscriptionType;
//       prefsHelper.setSubscriptionExpiry = expiryDate;
//       prefsHelper.sharedPrefs.saveData('isSubscribed', true);
//
//       // Show notification after successful subscription (non-blocking)
//       Future.microtask(() async {
//         try {
//           final notificationService = getIt<SubscriptionNotificationService>();
//           await notificationService.showSubscriptionSuccessNotification(
//             subscriptionType: subscriptionType,
//           );
//         } catch (e) {
//           debugPrint('Error showing subscription notification: $e');
//           // Don't throw error as this is just a notification
//         }
//       });
//     } catch (e) {
//       debugPrint('Error updating subscription in Supabase: $e');
//       // Don't throw to avoid breaking the main flow
//     }
//   }
//
//   // For development/testing only - simulate a purchase flow
//   Future<void> _simulatePurchase(SubscriptionProduct product) async {
//     // Simulate successful purchase
//     final prefs = await SharedPreferences.getInstance();
//
//     // Save subscription type and expiry date based on product type
//     String subscriptionTypeStr;
//     switch (product.type) {
//       case SubscriptionType.barakahAccess:
//         subscriptionTypeStr = 'barakah_access';
//         break;
//       case SubscriptionType.quranLite:
//         subscriptionTypeStr = 'quran_lite';
//         break;
//       case SubscriptionType.deenhubPro:
//         subscriptionTypeStr = 'deenhub_pro';
//         break;
//     }
//     await prefs.setString('subscriptionType', subscriptionTypeStr);
//
//     // Calculate expiry date based on product period
//     final now = DateTime.now();
//     final expiryDate = product.period == SubscriptionPeriod.monthly
//         ? now.add(const Duration(days: 30))
//         : now.add(const Duration(days: 365));
//     await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
//
//     // Update Supabase database
//     await _updateSubscriptionInSupabase(subscriptionTypeStr, expiryDate);
//
//     // Notify listeners
//     _purchaseStatusController.add(true);
//   }
//
//   Future<bool> restorePurchases() async {
//     if (!_isAvailable) return false;
//
//     try {
//       debugPrint('Starting purchase restoration...');
//       await _iap.restorePurchases();
//
//       // Note: The actual restoration happens in _onPurchaseUpdate when
//       // purchases with status "restored" are received
//
//       return true;
//     } catch (e) {
//       debugPrint('Error restoring purchases: $e');
//       return false;
//     }
//   }
//
//   void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       await _processPurchase(purchaseDetails);
//     }
//   }
//
//   /// Process individual purchase
//   Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
//     switch (purchaseDetails.status) {
//       case PurchaseStatus.pending:
//         debugPrint('Purchase pending: ${purchaseDetails.productID}');
//         break;
//
//       case PurchaseStatus.purchased:
//       case PurchaseStatus.restored:
//         await _handleSuccessfulPurchase(purchaseDetails);
//         break;
//
//       case PurchaseStatus.error:
//         _handlePurchaseError(purchaseDetails.error!);
//         _purchaseStatusController.add(false);
//         break;
//
//       case PurchaseStatus.canceled:
//         debugPrint('Purchase canceled: ${purchaseDetails.productID}');
//         _purchaseStatusController.add(false);
//         break;
//     }
//
//     // Complete the purchase
//     if (purchaseDetails.pendingCompletePurchase) {
//       await _iap.completePurchase(purchaseDetails);
//     }
//   }
//
//   /// Handle successful purchase
//   Future<void> _handleSuccessfulPurchase(
//       PurchaseDetails purchaseDetails) async {
//     debugPrint(
//         'Purchase successful: ${purchaseDetails.productID} | ${purchaseDetails.status} | ${purchaseDetails.transactionDate} | ${purchaseDetails.pendingCompletePurchase} | ${purchaseDetails.error}');
//
//     // Verify purchase with proper validation
//     final bool isValid = await _verifyPurchaseWithValidation(purchaseDetails);
//
//     if (isValid) {
//       debugPrint('Subscription activated: ${purchaseDetails.productID}');
//       _purchaseStatusController.add(true);
//
//       // Show notification after successful purchase (non-blocking)
//       Future.microtask(() async {
//         try {
//           final notificationService = getIt<SubscriptionNotificationService>();
//           String subscriptionType = 'DeenHub';
//           if (purchaseDetails.productID.contains('deenhub_pro')) {
//             subscriptionType = 'DeenHub Pro';
//           } else if (purchaseDetails.productID.contains('quran_lite')) {
//             subscriptionType = 'Quran Lite';
//           } else if (purchaseDetails.productID.contains('barakah_access')) {
//             subscriptionType = 'Barakah Access';
//           }
//
//           await notificationService.showSubscriptionSuccessNotification(
//             subscriptionType: subscriptionType,
//           );
//         } catch (e) {
//           debugPrint('Error showing subscription notification: $e');
//           // Don't throw error as this is just a notification
//         }
//       });
//     } else {
//       debugPrint('Purchase verification failed');
//       _purchaseStatusController.add(false);
//     }
//   }
//
//   /// Verify purchase with proper receipt validation
//   Future<bool> _verifyPurchaseWithValidation(
//       PurchaseDetails purchaseDetails) async {
//     try {
//       // For iOS, verify with App Store
//       if (Platform.isIOS) {
//         return await _verifyIOSPurchase(purchaseDetails);
//       }
//
//       // For Android, verify with Google Play
//       if (Platform.isAndroid) {
//         return await _verifyAndroidPurchase(purchaseDetails);
//       }
//
//       return false;
//     } catch (e) {
//       debugPrint('Purchase verification error: $e');
//       return false;
//     }
//   }
//
//   /// Verify iOS purchase with App Store
//   Future<bool> _verifyIOSPurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       final receiptData =
//           purchaseDetails.verificationData.localVerificationData;
//
//       // First try production environment
//       bool isValid = await _verifyIOSReceipt(receiptData, false);
//
//       if (!isValid) {
//         // If production fails, try sandbox
//         debugPrint('Production verification failed, trying sandbox');
//         isValid = await _verifyIOSReceipt(receiptData, true);
//       }
//
//       if (isValid) {
//         await _storeValidatedPurchase(purchaseDetails);
//       }
//
//       return isValid;
//     } catch (e) {
//       debugPrint('iOS verification error: $e');
//       return false;
//     }
//   }
//
//   /// Verify iOS receipt with App Store
//   Future<bool> _verifyIOSReceipt(String receiptData, bool isSandbox) async {
//     try {
//       final url = isSandbox
//           ? 'https://sandbox.itunes.apple.com/verifyReceipt'
//           : 'https://buy.itunes.apple.com/verifyReceipt';
//
//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'receipt-data': receiptData,
//               'password': '1807a910b2cf49409e5c88e4f9d9d6de',
//               "exclude-old-transactions": true
//             }),
//           )
//           .timeout(const Duration(seconds: 15)); // Add timeout
//
//       debugPrint('Response: ${response.statusCode} | ${response.body}');
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         final status = responseData['status'];
//
//         if (status == 0) {
//           // Receipt is valid
//           return true;
//         } else if (status == 21007) {
//           // Sandbox receipt used in production - only return false if we're checking production
//           debugPrint('Sandbox receipt detected in production environment');
//           return !isSandbox; // Return false only if we're checking production (will trigger sandbox check)
//         } else {
//           debugPrint('App Store verification failed with status: $status');
//           return false;
//         }
//       }
//
//       return false;
//     } on TimeoutException {
//       debugPrint('iOS receipt verification timed out');
//       return false;
//     } catch (e) {
//       debugPrint('iOS receipt verification error: $e');
//       return false;
//     }
//   }
//
//   /// Verify Android purchase with Google Play
//   Future<bool> _verifyAndroidPurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       // For Android, you need to verify with Google Play Billing API
//       // This typically requires server-side verification
//
//       // For now, we'll do basic validation
//       final androidPurchase = purchaseDetails as GooglePlayPurchaseDetails;
//       final purchaseToken = androidPurchase.billingClientPurchase.purchaseToken;
//       final productId = androidPurchase.productID;
//
//       // Basic validation - in production, implement server-side verification
//       final isValid = purchaseToken.isNotEmpty &&
//           (productId == _quranLiteId ||
//               productId == _deenhubProId ||
//               productId == _quranLiteYearlyId ||
//               productId == _deenhubProYearlyId);
//
//       if (isValid) {
//         await _storeValidatedPurchase(purchaseDetails);
//       }
//
//       return isValid;
//     } catch (e) {
//       debugPrint('Android verification error: $e');
//       return false;
//     }
//   }
//
//   /// Store validated purchase data
//   Future<void> _storeValidatedPurchase(PurchaseDetails purchaseDetails) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // Save subscription type and expiry date based on product ID
//       String subscriptionTypeStr;
//       Duration subscriptionDuration;
//
//       if (purchaseDetails.productID == _barakahAccessId) {
//         subscriptionTypeStr = 'barakah_access';
//         subscriptionDuration =
//             const Duration(days: 30 * 6); // 6 months for free
//       } else if (purchaseDetails.productID == _quranLiteId) {
//         subscriptionTypeStr = 'quran_lite';
//         subscriptionDuration = const Duration(days: 30); // Monthly
//       } else if (purchaseDetails.productID == _deenhubProId) {
//         subscriptionTypeStr = 'deenhub_pro';
//         subscriptionDuration = const Duration(days: 30); // Monthly
//       } else if (purchaseDetails.productID == _quranLiteYearlyId) {
//         subscriptionTypeStr = 'quran_lite';
//         subscriptionDuration = const Duration(days: 365); // Yearly
//       } else if (purchaseDetails.productID == _deenhubProYearlyId) {
//         subscriptionTypeStr = 'deenhub_pro';
//         subscriptionDuration = const Duration(days: 365); // Yearly
//       } else {
//         subscriptionTypeStr = 'barakah_access'; // fallback
//         subscriptionDuration = const Duration(days: 30 * 6);
//       }
//
//       await prefs.setString('subscriptionType', subscriptionTypeStr);
//       // Optional: Store subscription period for UI/reference
//       if (purchaseDetails.productID == _quranLiteId ||
//           purchaseDetails.productID == _deenhubProId) {
//         await prefs.setString('subscriptionPeriod', 'monthly');
//       } else if (purchaseDetails.productID == _quranLiteYearlyId ||
//           purchaseDetails.productID == _deenhubProYearlyId) {
//         await prefs.setString('subscriptionPeriod', 'yearly');
//       }
//
//       // Store original purchase info for validation
//       await prefs.setString('purchaseToken',
//           purchaseDetails.verificationData.serverVerificationData);
//       await prefs.setString(
//           'purchaseSource', purchaseDetails.verificationData.source);
//       await prefs.setString('productId', purchaseDetails.productID);
//
//       // Calculate expiry date
//       final now = DateTime.now();
//       final expiryDate = now.add(subscriptionDuration);
//       await prefs.setString('subscriptionExpiry', expiryDate.toIso8601String());
//
//       // Update Supabase database
//       await _updateSubscriptionInSupabase(subscriptionTypeStr, expiryDate);
//
//       debugPrint(
//           'Purchase verified and stored successfully: $subscriptionTypeStr expires ${expiryDate.toIso8601String()}');
//     } catch (e) {
//       debugPrint('Error storing validated purchase: $e');
//       rethrow;
//     }
//   }
//
//   void _handlePurchaseError(IAPError error) {
//     debugPrint('Purchase error: ${error.message}');
//     // Handle specific error cases
//   }
//
//   void _updateStreamOnDone() {
//     _subscription.cancel();
//   }
//
//   void _updateStreamOnError(dynamic error) {
//     debugPrint('IAP stream error: $error');
//   }
//
//   void dispose() {
//     _subscription.cancel();
//     _productsController.close();
//     _purchaseStatusController.close();
//   }
//
//   // Centralized function to check if user has any active subscription
//   // Checks both subscription type and expiry date
//   static Future<bool> hasActiveSubscription() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;
//       final expiryDateStr = prefs.getString('subscriptionExpiry');
//
//       // Must have a subscription type
//       if (subscriptionType.isNullOrEmpty || subscriptionType == 'free') {
//         return false;
//       }
//
//       // Must have a valid expiry date
//       if (expiryDateStr == null) {
//         return false;
//       }
//
//       // Check if subscription hasn't expired
//       final expiryDate = DateTime.tryParse(expiryDateStr);
//       if (expiryDate == null || expiryDate.isBefore(DateTime.now())) {
//         // Subscription expired, clear expired data
//         await _clearExpiredSubscriptionData();
//         return false;
//       }
//
//       return true;
//     } catch (e) {
//       debugPrint('Error checking active subscription: $e');
//       return false;
//     }
//   }
//
//   // Clear expired subscription data from shared prefs only
//   static Future<void> _clearExpiredSubscriptionData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('subscriptionType');
//     await prefs.remove('subscriptionExpiry');
//     await prefs.remove('purchaseToken');
//     await prefs.remove('purchaseSource');
//     await prefs.remove('productId');
//     await prefs.remove('subscriptionPeriod');
//
//     debugPrint('Cleared expired subscription data from shared prefs');
//   }
//
//   // Check if user has DeenHub Pro subscription
//   static Future<bool> isDeenHubProSubscribed() async {
//     try {
//       // First check if user has any active subscription
//       if (!await hasActiveSubscription()) return false;
//
//       final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;
//
//       // Check if it's specifically DeenHub Pro
//       return subscriptionType == 'deenhub_pro';
//     } catch (e) {
//       debugPrint('Error checking DeenHub Pro subscription: $e');
//       return false;
//     }
//   }
//
//   // Check specific subscription type
//   static Future<SubscriptionType?> getCurrentSubscriptionType() async {
//     try {
//       // First check if user has any active subscription
//       if (!await hasActiveSubscription()) return null;
//
//       final subscriptionType = getIt<SharedPrefsHelper>().subscriptionStatus;
//
//       switch (subscriptionType) {
//         case 'barakah_access':
//           return SubscriptionType.barakahAccess;
//         case 'quran_lite':
//           return SubscriptionType.quranLite;
//         case 'deenhub_pro':
//           return SubscriptionType.deenhubPro;
//         default:
//           return null;
//       }
//     } catch (e) {
//       debugPrint('Error getting current subscription type: $e');
//       return null;
//     }
//   }
//
//   // Check if user can access AI features (DeenHub Pro only)
//   static Future<bool> canAccessAIFeatures() async {
//     return await isDeenHubProSubscribed();
//   }
//
//   // Check if user has any active subscription (including Barakah Access)
//   // This is an alias for hasActiveSubscription for backward compatibility
//   static Future<bool> hasAnySubscription() async {
//     return await hasActiveSubscription();
//   }
//
//   // Check if user can access Quran features (any subscription including Barakah Access)
//   static Future<bool> canAccessQuranFeatures() async {
//     return await hasAnySubscription();
//   }
//
//   // Validate and refresh subscription status from stores
//   Future<bool> validateSubscriptionStatus() async {
//     if (!_isAvailable) return false;
//
//     try {
//       // Use the centralized function to check subscription status
//       return await hasActiveSubscription();
//     } catch (e) {
//       debugPrint('Error validating subscription status: $e');
//       return false;
//     }
//   }
//
// }
//
// // For iOS only - Payment Queue Delegate
// class _IAPPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
//   @override
//   bool shouldContinueTransaction(
//     SKPaymentTransactionWrapper transaction,
//     SKStorefrontWrapper storefront,
//   ) {
//     return true;
//   }
//
//   @override
//   bool shouldShowPriceConsent() {
//     return false;
//   }
// }
