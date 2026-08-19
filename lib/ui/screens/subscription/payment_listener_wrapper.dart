import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:eClassify/data/cubits/subscription/get_payment_intent_cubit.dart';
import 'package:eClassify/data/cubits/subscription/iap_cubit.dart';
import 'package:eClassify/data/cubits/system/get_payment_methods_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/payment_handler.dart';
import 'package:eClassify/ui/screens/widgets/app_dialog.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/meta_sdk_service.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/payment/payment_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentListenerWrapper extends StatelessWidget {
  const PaymentListenerWrapper({
    super.key,
    required this.child,
    required this.package,
    required this.selectedGateway,
  });

  final Widget child;
  final ValueNotifier<SubscriptionPackage?> package;
  final ValueNotifier<String?> selectedGateway;

  // ── IAP outcome handlers called by BlocListener ──────────────────────── //

  void _onIapSuccess(BuildContext context) {
    final pkg = package.value;
    if (pkg != null) {
      MetaSdkService.logPurchase(
        amount: pkg.discountedPrice.toDouble(),
        currency: Constant.systemSettings.defaultCurrency.code,
        orderId: 'iap_${pkg.id}',
        packageId: pkg.id,
      );
    }
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'purchaseCompleted'.translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            'purchaseCompletedSuccessfully'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          positiveButtonLabel: 'ok'.translate(context),
          onPositiveTapped: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.activePlanScreen,
              (route) => route.isFirst,
            );
          },
        );
      },
    );
  }

  void _onIapError(BuildContext context, String message) {
    HelperUtils.showSnackBarMessage(context, message);
  }

  void _onIapProductNotFound(BuildContext context, String productId) {
    HelperUtils.showSnackBarMessage(
      context,
      'iapProductNotFound'.translate(context),
    );
  }

  void _onIapStoreUnavailable(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'iapStoreUnavailable'.translate(context),
    );
  }

  void _onIapCancelled(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'purchaseHasBeenCanceled'.translate(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GetPaymentIntentCubit, GetPaymentIntentState>(
          listener: (context, state) {
            // Bank transfer flow is handled by PaymentHandler directly.
            if (selectedGateway.value == null) {
              return;
            }

            if (state is GetPaymentIntentInSuccess) {
              _showHideLoaderWithMsg(false, context);
              PaymentHandler.setupPaymentGateway(
                context: context,
                selectedGateway: selectedGateway.value,
                package: package.value!,
                paymentIntent: state.paymentIntent,
              );
            } else if (state is GetPaymentIntentFailure) {
              _showHideLoaderWithMsg(
                false,
                context,
                msg: state.error.toString(),
              );
            } else if (state is GetPaymentIntentInProgress) {
              _showHideLoaderWithMsg(true, context);
            }
          },
        ),
        BlocListener<AssignFreePackageCubit, AssignFreePackageState>(
          listener: (context, state) {
            if (state is AssignFreePackageInSuccess) {
              _showHideLoaderWithMsg(
                false,
                context,
                msg: state.responseMessage,
              );
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.activePlanScreen,
                (route) => route.isFirst,
              );
            } else if (state is AssignFreePackageFailure) {
              _showHideLoaderWithMsg(
                false,
                context,
                msg: state.error.toString(),
              );
            } else if (state is AssignFreePackageInProgress) {
              _showHideLoaderWithMsg(true, context);
            }
          },
        ),
        BlocListener<GetPaymentMethodsCubit, GetPaymentMethodsState>(
          listener: (context, state) {
            if (state is GetPaymentMethodsSuccess) {
              setPaymentGateways(state);
            }
          },
        ),
        BlocListener<IapCubit, IapState>(
          listener: (context, state) {
            if (state is IapInProgress) {
              LoadingOverlay.show(context);
            } else {
              LoadingOverlay.hide();
              if (state is IapSuccess) {
                _onIapSuccess(context);
              } else if (state is IapPurchaseError) {
                _onIapError(context, state.message);
              } else if (state is IapProductNotFound) {
                _onIapProductNotFound(context, state.productId);
              } else if (state is IapStoreUnavailable) {
                _onIapStoreUnavailable(context);
              } else if (state is IapPurchaseCancelled) {
                _onIapCancelled(context);
              }
            }
            // IapPurchaseRestored is intentionally ignored — consumables
            // cannot be restored; the state is emitted only for logging.
          },
        ),
      ],
      child: child,
    );
  }

  void setPaymentGateways(GetPaymentMethodsSuccess state) {
    PaymentSettings.stripeCurrency = state.stripeCurrency ?? "";
    PaymentSettings.stripePublishableKey = state.stripePublishableKey ?? "";
    PaymentSettings.stripeStatus = state.stripeStatus;
    PaymentSettings.payStackCurrency = state.payStackCurrency ?? "";
    PaymentSettings.payStackStatus = state.payStackStatus;
    PaymentSettings.razorpayKey = state.razorPayKey ?? "";
    PaymentSettings.razorpayCurrency = state.razorPayCurrency ?? "";
    PaymentSettings.razorpayStatus = state.razorPayStatus;
    PaymentSettings.phonePeCurrency = state.phonePeCurrency ?? "";
    PaymentSettings.phonePeStatus = state.phonePeStatus;
    PaymentSettings.flutterwaveCurrency = state.flutterWaveCurrency ?? "";
    PaymentSettings.flutterwaveStatus = state.flutterWaveStatus;
    PaymentSettings.phonePeCurrency = state.phonePeCurrency ?? "";
    PaymentSettings.bankAccountNumber = state.bankAccountNumber ?? "";
    PaymentSettings.bankAccountHolderName = state.bankAccountHolder ?? "";
    PaymentSettings.bankIfscSwiftCode = state.bankIfscSwiftCode ?? "";
    PaymentSettings.bankName = state.bankName ?? "";
    PaymentSettings.bankTransferStatus = state.bankTransferStatus;
    PaymentSettings.paypalCurrency = state.paypalCurrency ?? '';
    PaymentSettings.paypalStatus = state.paypalStatus;
    PaymentSettings.paytabsCurrency = state.paytabsCurrency ?? '';
    PaymentSettings.paytabsStatus = state.paytabsStatus;
    PaymentSettings.dpoCurrency = state.dpoCurrency ?? '';
    PaymentSettings.dpoStatus = state.dpoStatus;

    PaymentSettings.updatePaymentGateways();
  }

  static void _showHideLoaderWithMsg(
    bool isShow,
    BuildContext context, {
    String? msg,
  }) {
    isShow ? LoadingOverlay.show(context) : LoadingOverlay.hide();
    if (msg != null) {
      HelperUtils.showSnackBarMessage(context, msg);
    }
  }
}
