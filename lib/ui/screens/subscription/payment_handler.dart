import 'package:eClassify/data/cubits/subscription/get_payment_intent_cubit.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/payment_gatways.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/payment/gateaways/payment_webview.dart';
import 'package:eClassify/utils/payment/gateaways/stripe_service.dart';
import 'package:eClassify/utils/payment/payment_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentHandler {
  const PaymentHandler._();

  /// Initialize and launch specific payment SDKs such as Stripe, Razorpay, etc.
  ///
  /// This method assumes that `paymentIntent` is the raw map received from
  /// the payment intent API (e.g. `state.paymentIntent`).
  static void setupPaymentGateway({
    required BuildContext context,
    required String? selectedGateway,
    required SubscriptionPackage package,
    required Map<String, dynamic> paymentIntent,
  }) {
    if (selectedGateway == Constant.paymentTypeStripe) {
      StripeService.initStripe(PaymentSettings.stripePublishableKey, "test");
      PaymentGateways.stripe(
        context,
        price: package.discountedPrice.toDouble(),
        packageId: package.id,
        paymentIntent: paymentIntent,
      );
    } else if (selectedGateway == Constant.paymentTypePaystack ||
        selectedGateway == Constant.paymentTypeFlutterwave ||
        selectedGateway == Constant.paymentTypePaypal) {
      if (paymentIntent["payment_gateway_response"]['status'] == 'error') {
        HelperUtils.showSnackBarMessage(
          context,
          paymentIntent["payment_gateway_response"]['message'],
        );
        return;
      }

      String authUrl() {
        if (selectedGateway == Constant.paymentTypePaystack) {
          return paymentIntent["payment_gateway_response"]["data"]["authorization_url"];
        } else if (selectedGateway == Constant.paymentTypeFlutterwave) {
          return paymentIntent["payment_gateway_response"]["data"]["link"];
        } else if (selectedGateway == Constant.paymentTypePaypal) {
          return paymentIntent["approval_url"];
        } else {
          throw UnsupportedError('No authUrl found');
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            authorizationUrl: authUrl(),
            reference: selectedGateway == Constant.paymentTypePaystack
                ? paymentIntent["payment_gateway_response"]["data"]["reference"]
                : null,
            onSuccess: (reference) {
              HelperUtils.showSnackBarMessage(
                context,
                "paymentSuccessfullyCompleted".translate(context),
              );
            },
            onFailed: (reference) {
              HelperUtils.showSnackBarMessage(
                context,
                "purchaseFailed".translate(context),
              );
            },
            onCancel: () {
              HelperUtils.showSnackBarMessage(
                context,
                "subscriptionsCancelled".translate(context),
              );
            },
          ),
        ),
      );
    } else if (selectedGateway == Constant.paymentTypePhonepe) {
      PaymentGateways.phonepeCheckSum(
        context: context,
        getData: paymentIntent["payment_gateway_response"],
      );
    } else if (selectedGateway == Constant.paymentTypeRazorpay) {
      PaymentGateways.razorpay(
        orderId: paymentIntent["id"].toString(),
        context: context,
        packageId: package.id,
        price: package.discountedPrice.toDouble(),
      );
    } else if (selectedGateway == Constant.paymentTypePaytabs ||
        selectedGateway == Constant.paymentTypeDpo) {
      final url = paymentIntent["payment_url"]?.toString();
      if (url == null || url.isEmpty) {
        HelperUtils.showSnackBarMessage(
          context,
          "purchaseFailed".translate(context),
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            authorizationUrl: url,
            onSuccess: (reference) {
              HelperUtils.showSnackBarMessage(
                context,
                "paymentSuccessfullyCompleted".translate(context),
              );
            },
            onFailed: (reference) {
              HelperUtils.showSnackBarMessage(
                context,
                "purchaseFailed".translate(context),
              );
            },
            onCancel: () {
              HelperUtils.showSnackBarMessage(
                context,
                "subscriptionsCancelled".translate(context),
              );
            },
          ),
        ),
      );
    }
  }

  /// Decides whether to show bank details or request a payment intent via Cubit.
  static void processPayment({
    required BuildContext context,
    required String selectedGateway,
    required int packageId,
  }) {
    if (selectedGateway == Constant.paymentTypeBankTransfer) {
      _showBankDetailsDialog(context, packageId);
    } else {
      context.read<GetPaymentIntentCubit>().getPaymentIntent(
        paymentMethod: getPaymentMethodName(selectedGateway),
        packageId: packageId,
      );
    }
  }

  /// Maps internal gateway types to display/API-compatible identifiers.
  static String getPaymentMethodName(String? selectedGateway) {
    return switch (selectedGateway) {
      Constant.paymentTypeStripe => "Stripe",
      Constant.paymentTypePaystack => "Paystack",
      Constant.paymentTypeRazorpay => "Razorpay",
      Constant.paymentTypePhonepe => "PhonePe",
      Constant.paymentTypeFlutterwave => "FlutterWave",
      Constant.paymentTypePaypal => "PayPal",
      Constant.paymentTypePaytabs => "Paytabs",
      Constant.paymentTypeDpo => "DPO",
      Constant.paymentTypeBankTransfer => "bankTransfer",
      _ => "",
    };
  }

  static void _showBankDetailsDialog(BuildContext context, int packageId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: CustomText(
          'bankAccountDetails'.translate(context),
          fontWeight: FontWeight.bold,
        ),
        content: BlocListener<GetPaymentIntentCubit, GetPaymentIntentState>(
          bloc: context.read<GetPaymentIntentCubit>(),
          listener: (context, state) {
            if (state is GetPaymentIntentInSuccess) {
              Navigator.pop(context);
              _showHideLoaderWithMsg(
                false,
                context,
                msg: state.message.toString(),
              );
            } else if (state is GetPaymentIntentInProgress) {
              _showHideLoaderWithMsg(true, context);
            } else if (state is GetPaymentIntentFailure) {
              Navigator.pop(context);
              _showHideLoaderWithMsg(
                false,
                context,
                msg: state.error.toString(),
              );
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'pleaseTransferAmountToFollowingBank'.translate(context),
                fontSize: 14,
              ),
              _buildDetailField(
                context,
                'accountHolder'.translate(context),
                PaymentSettings.bankAccountHolderName,
              ),
              _buildDetailField(
                context,
                'accountNumber'.translate(context),
                PaymentSettings.bankAccountNumber,
              ),
              _buildDetailField(
                context,
                'bankName'.translate(context),
                PaymentSettings.bankName,
              ),
              _buildDetailField(
                context,
                'swiftIfscCode'.translate(context),
                PaymentSettings.bankIfscSwiftCode,
              ),
            ],
          ),
        ),
        actions: [
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.color.secondary,
                    foregroundColor: context.color.onSecondary,
                  ),
                  onPressed: Navigator.of(context).pop,
                  child: Text('cancel'.translate(context)),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<GetPaymentIntentCubit>().getPaymentIntent(
                      paymentMethod: "bankTransfer",
                      packageId: packageId,
                    );
                  },
                  child: Text('confirmPayment'.translate(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailField(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelMedium),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.colorScheme.secondaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(value, style: context.labelMedium),
        ),
      ],
    );
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
