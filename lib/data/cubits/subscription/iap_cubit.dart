import 'dart:async';

import 'package:eClassify/data/repositories/subscription/iap_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// ─────────────────────────────── States ──────────────────────────────────── //

abstract class IapState {}

/// Initial / idle state.
class IapInitial extends IapState {}

/// A consumable purchase is in progress (either triggering or verifying).
class IapInProgress extends IapState {}

/// Store + backend both confirmed purchase. [error] is the backend message.
class IapSuccess extends IapState {}

/// The product ID is not registered in App Store Connect, or is not available.
class IapProductNotFound extends IapState {
  IapProductNotFound(this.productId);

  final String productId;
}

/// `InAppPurchase.isAvailable()` returned false, or the store is unreachable.
class IapStoreUnavailable extends IapState {}

/// The user cancelled the Apple payment sheet.
class IapPurchaseCancelled extends IapState {}

/// The store returned an error during the purchase.
class IapPurchaseError extends IapState {
  IapPurchaseError(this.message);

  final String message;
}

/// A restored event was received for this consumable product.
///
/// Consumable products cannot be restored in the traditional sense — this
/// event is emitted only so it can be logged. The UI must not act on this
/// state (no dialog, no snackbar).
class IapPurchaseRestored extends IapState {}

// ─────────────────────────────── Cubit ───────────────────────────────────── //

/// Owns the purchase stream lifecycle and acts as the single bridge between
/// the App Store and the UI.
///
/// Responsibilities:
///   - Subscribing to the [IapRepository.purchaseStream]
///   - Deduplicating events by [PurchaseDetails.purchaseID]
///   - Calling [IapRepository.complete] only for [PurchaseStatus.purchased]
///     (never for restored — avoids the StoreKit re-emit loop on consumables)
///   - Verifying the purchase token with the backend
///   - Emitting typed states for every outcome so the UI reacts without any
///     global-key navigation or context captured in the repository layer
///
/// Usage:
/// ```dart
/// // In initState (iOS only):
/// context.read<IapCubit>().startListening();
///
/// // To trigger a purchase:
/// context.read<IapCubit>().buy(productId: pkg.iosProductId!, packageId: pkg.id);
/// ```
class IapCubit extends Cubit<IapState> {
  IapCubit({IapRepository? repository})
    : _repo = repository ?? IapRepository.instance,
      super(IapInitial());

  final IapRepository _repo;

  /// Tracks purchase IDs seen in this session to prevent double-processing.
  /// Instance-level (not static) so it resets with the cubit's lifecycle.
  final Set<String> _processedPurchaseIds = {};

  /// The active package ID being purchased — stored so the stream handler
  /// can forward it to the backend without re-querying.
  int? _pendingPackageId;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// Subscribes to the App Store purchase stream.
  ///
  /// Call this once from `initState` (iOS only). Safe to call multiple times —
  /// subsequent calls are no-ops if already listening.
  void startListening() {
    if (_purchaseSub != null) return;
    Log.info('IAP: Starting purchase stream listener');
    _purchaseSub = _repo.purchaseStream.listen(
      _onPurchaseEvents,
      onError: (Object error, StackTrace stack) {
        Log.error('IAP: Purchase stream error', error, stack);
        emit(IapPurchaseError('Unexpected store error. Please try again.'));
      },
    );
  }

  /// Initiates a consumable purchase for [productId].
  ///
  /// Emits [IapInProgress] immediately, then [IapStoreUnavailable] or
  /// [IapProductNotFound] synchronously if pre-conditions fail.
  /// Subsequent events (success / cancel / error) arrive via [_onPurchaseEvents].
  Future<void> buy({required String productId, required int packageId}) async {
    emit(IapInProgress());
    _pendingPackageId = packageId;

    try {
      final available = await _repo.isAvailable();
      if (!available) {
        Log.warning('IAP: Store not available');
        emit(IapStoreUnavailable());
        return;
      }

      final product = await _repo.getProduct(productId);
      if (product == null) {
        Log.warning('IAP: Product "$productId" not found');
        emit(IapProductNotFound(productId));
        return;
      }

      await _repo.buyConsumable(product);
      Log.info('IAP: Consumable purchase initiated for "$productId"');
      // Outcome arrives asynchronously on the purchase stream.
    } on IapUnavailableException catch (e) {
      Log.warning('IAP: $e');
      emit(IapStoreUnavailable());
    } on Exception catch (e, stack) {
      Log.error('IAP: buy() failed for "$productId"', e, stack);
      emit(IapPurchaseError(e.toString()));
    }
  }

  // ─────────────────────────── Stream Handler ──────────────────────────────

  Future<void> _onPurchaseEvents(List<PurchaseDetails> events) async {
    for (final purchase in events) {
      Log.info(
        'IAP: Event received — status=${purchase.status.name}, '
        'id=${purchase.purchaseID}, product=${purchase.productID}',
      );

      // ── Step 1: Deduplicate by purchaseID. ───────────────────────────────
      final pid = purchase.purchaseID;
      if (pid != null && _processedPurchaseIds.contains(pid)) {
        Log.info('IAP: Duplicate event for purchaseID=$pid — skipping');
        continue;
      }
      if (pid != null) _processedPurchaseIds.add(pid);

      // ── Step 2: Emit state for each outcome. ─────────────────────────────
      switch (purchase.status) {
        case PurchaseStatus.purchased:
          if (purchase.pendingCompletePurchase) {
            await _repo.complete(purchase);
          }
          Log.info('IAP: Purchased event received — completing purchase');
          await _handlePurchased(purchase);

        case PurchaseStatus.restored:
          // Consumable products are not restorable. Log and emit a silent
          // state — the UI BlocListener must not show any dialog for this.
          Log.info(
            'IAP: Restored event received for consumable '
            '"${purchase.productID}" — discarding silently.',
          );
          emit(IapPurchaseRestored());

        case PurchaseStatus.canceled:
          Log.info('IAP: Purchase cancelled by user');
          emit(IapPurchaseCancelled());

        case PurchaseStatus.error:
          final msg = purchase.error?.message ?? 'Unknown purchase error';
          Log.error('IAP: Purchase error — $msg', purchase.error, null);
          emit(IapPurchaseError(msg));

        case PurchaseStatus.pending:
          Log.info('IAP: Purchase pending — waiting for store confirmation');
          // Stay in IapInProgress; no state change needed.
          break;
      }
    }
  }

  Future<void> _handlePurchased(PurchaseDetails purchase) async {
    final pkg = _pendingPackageId;
    final token = purchase.purchaseID;

    if (pkg == null || token == null) {
      Log.warning(
        'IAP: Purchase succeeded but packageId or purchaseID is null. '
        'packageId=$pkg, purchaseID=$token',
      );
      emit(
        IapPurchaseError(
          'Purchase verification failed. Please contact support.',
        ),
      );
      return;
    }

    emit(IapInProgress());

    try {
      final message = await _repo.verifyPurchase(
        purchaseToken: token,
        packageId: pkg,
      );
      Log.info('IAP: Backend verification succeeded — $message');
      _pendingPackageId = null;
      emit(IapSuccess());
    } on Exception catch (e, stack) {
      Log.error('IAP: Backend verification failed', e, stack);
      emit(IapPurchaseError(e.toString()));
    }
  }

  // ─────────────────────────────── Lifecycle ───────────────────────────────

  /// Call this when the app returns to the foreground (AppLifecycleState.resumed).
  ///
  /// StoreKit does not emit a `canceled` event when the user swipe-dismisses
  /// the Apple payment sheet interactively. The only reliable signal that the
  /// sheet is gone without a result is the app resuming. If we are still in
  /// [IapInProgress] at that point, the sheet was dismissed silently — reset
  /// to [IapInitial] so the UI stops showing a loading indicator.
  void resetIfStuck() {
    if (state is IapInProgress) {
      Log.info(
        'IAP: App resumed while still in IapInProgress — '
        'payment sheet was likely dismissed without a result. Resetting.',
      );
      emit(IapInitial());
    }
  }

  @override
  Future<void> close() async {
    Log.info('IAP: Closing cubit — cancelling purchase stream subscription');
    await _purchaseSub?.cancel();
    _purchaseSub = null;
    return super.close();
  }
}
