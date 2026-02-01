import 'package:deenhub/core/notification/notification_manager.dart';
import 'package:deenhub/core/notification/notification_types.dart';
import 'package:deenhub/main.dart';

class SubscriptionNotificationService {
  final NotificationManager _notificationManager;

  SubscriptionNotificationService(this._notificationManager);

  /// Show a notification after successful subscription
  Future<void> showSubscriptionSuccessNotification({
    String? subscriptionType,
    String? userName,
  }) async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.subscriptionSuccess,
        title: '🎉 Subscription Successful!',
        body: 'Thank you for subscribing to ${subscriptionType ?? 'DeenHub'}. '
            'Your support helps us continue providing Islamic resources to the community.',
        payload: 'subscription_success:${subscriptionType ?? 'unknown'}',
      );
      
      logger.i('Subscription success notification shown');
    } catch (e) {
      logger.e('Error showing subscription success notification: $e');
    }
  }

  /// Show a notification when subscription is upgraded
  Future<void> showSubscriptionUpgradeNotification({
    String? currentPlan,
    String? newPlan,
    String? userName,
  }) async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.subscriptionSuccess,
        title: '🚀 Plan Upgrade Successful!',
        body: 'Your subscription has been upgraded from $currentPlan to $newPlan. '
            'Enjoy the enhanced features of your new plan!',
        payload: 'subscription_upgrade:${newPlan ?? 'unknown'}',
      );
      
      logger.i('Subscription upgrade notification shown');
    } catch (e) {
      logger.e('Error showing subscription upgrade notification: $e');
    }
  }

  /// Show a notification when subscription expires
  Future<void> showSubscriptionExpiryNotification({
    String? userName,
  }) async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.subscriptionSuccess,
        title: '📋 Subscription Expiring Soon',
        body: 'Your subscription is about to expire. Renew to continue enjoying premium features.',
        payload: 'subscription_expiry_warning',
      );
      
      logger.i('Subscription expiry notification shown');
    } catch (e) {
      logger.e('Error showing subscription expiry notification: $e');
    }
  }

  /// Show a notification when subscription is renewed
  Future<void> showSubscriptionRenewalNotification({
    String? subscriptionType,
    String? userName,
  }) async {
    try {
      await _notificationManager.showNotification(
        type: NotificationType.subscriptionSuccess,
        title: '🔄 Subscription Renewed!',
        body: 'Your ${subscriptionType ?? 'DeenHub'} subscription has been successfully renewed. '
            'Thank you for your continued support!',
        payload: 'subscription_renewed:${subscriptionType ?? 'unknown'}',
      );
      
      logger.i('Subscription renewal notification shown');
    } catch (e) {
      logger.e('Error showing subscription renewal notification: $e');
    }
  }
}