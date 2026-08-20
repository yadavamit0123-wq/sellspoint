import 'dart:async';

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Exceptions thrown by [IapRepository].
class IapUnavailableException implements Exception {
  const IapUnavailableException([this.message = 'App Store is not available']);

  final String message;

  @override
  String toString() => 'IapUnavailableException: $message';
}

class IapProductNotFoundException implements Exception {
  const IapProductNotFoundException(this.productId);

  final String productId;

  @override
  String toString() =>
      'IapProductNotFoundException: Product "$productId" not found in the App Store. '
      'Ensure the product ID is registered and approved in App Store Connect.';
}

/// Pure store-interaction layer. No [BuildContext], no Cubit references.
///
/// Responsible for:
///   - Checking store availability
///   - Querying product details from App Store
///   - Initiating consumable purchases
///   - Acknowledging completed purchases with the store
///   - Verifying the purchase token against the backend
class IapRepository {
  IapRepository._internal();

  static final IapRepository _instance = IapRepository._internal();

  static IapRepository get instance => _instance;

  final InAppPurchase _store = InAppPurchase.instance;

  /// Raw purchase event stream from [InAppPurchase].
  /// The cubit subscribes to this; the repository never listens itself.
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  /// Returns `true` if the App Store is reachable.
  Future<bool> isAvailable() async {
    return _store.isAvailable();
  }

  /// Fetches product details for [productId] from App Store Connect.
  ///
  /// Returns `null` if the product is not found instead of throwing —
  /// the caller (cubit) emits the appropriate state for UI feedback.
  Future<ProductDetails?> getProduct(String productId) async {
    try {
      final response = await _store.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty) {
        Log.warning(
          'IAP: Product "$productId" not found in App Store. '
          'Verify the product ID and its status in App Store Connect.',
        );
        return null;
      }

      if (response.error != null) {
        Log.error(
          'IAP: queryProductDetails error for "$productId"',
          response.error,
          StackTrace.current,
        );
        return null;
      }

      if (response.productDetails.isEmpty) {
        Log.warning('IAP: Empty product list returned for "$productId"');
        return null;
      }

      return response.productDetails.first;
    } on Exception catch (e, stack) {
      Log.error(
        'IAP: Unexpected error querying product "$productId"',
        e,
        stack,
      );
      return null;
    }
  }

  /// Initiates a consumable purchase for [product].
  ///
  /// Throws [IapUnavailableException] if the store is not reachable.
  /// Purchase events arrive asynchronously on [purchaseStream].
  Future<void> buyConsumable(ProductDetails product) async {
    final available = await isAvailable();
    if (!available) {
      throw const IapUnavailableException();
    }

    Log.info('IAP: Initiating consumable purchase for "${product.id}"');
    try {
      await _store.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  /// Acknowledges [purchase] with the store.
  ///
  /// Must only be called for [PurchaseStatus.purchased] events.
  /// Calling this on a [PurchaseStatus.restored] consumable causes StoreKit
  /// to emit another restored event — which is the root cause of the
  /// restore-loop bug. Never call this for restored events.
  Future<void> complete(PurchaseDetails purchase) async {
    try {
      Log.info('IAP: Completing purchase ${purchase.purchaseID}');
      await _store.completePurchase(purchase);
      Log.info('IAP: Purchase ${purchase.purchaseID} completed successfully');
    } on Exception catch (e, stack) {
      Log.error(
        'IAP: Failed to complete purchase ${purchase.purchaseID}',
        e,
        stack,
      );
      // Non-fatal: the store will re-deliver the event on next launch.
    }
  }

  /// Sends the Apple purchase token to the backend for server-side validation.
  ///
  /// Returns the success message string from the API on success.
  /// Rethrows on failure so the cubit can emit [IapError].
  Future<String> verifyPurchase({
    required String purchaseToken,
    required int packageId,
  }) async {
    final Map<String, dynamic> parameters = {
      Api.purchaseToken: purchaseToken,
      Api.paymentMethod: 'apple',
      Api.packageId: packageId,
    };

    Log.info(
      'IAP: Verifying purchase token with backend (packageId=$packageId)',
    );

    final response = await Api.post(
      parameter: parameters,
      url: Api.inAppPurchaseApi,
    );

    return response['message'] as String;
  }
}
