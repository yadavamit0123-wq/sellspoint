/// FCM **data** `type` values that open the ad listing subscription catalog.
abstract final class SubscriptionNotificationPayload {
  static const subscriptionTypes = {
    'subscription',
    'package',
    'package-expired',
    'listing-package',
    'item-listing-package',
  };

  static bool isSubscriptionType(String type) =>
      subscriptionTypes.contains(type);
}
