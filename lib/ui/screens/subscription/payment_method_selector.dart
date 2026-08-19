import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_assets.dart';

import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/payment/payment_settings.dart';
import 'package:flutter/material.dart';

class PaymentMethodSelector {
  const PaymentMethodSelector._();

  /// Shows the payment method selection bottom sheet and returns the
  /// selected gateway type as a String.
  ///
  /// - Returns `null` if the sheet is dismissed without a selection.
  static Future<String?> show(
    BuildContext context, {
    String? initialGateway,
  }) async {
    final enabledGateways = PaymentSettings.getEnabledPaymentGateways();

    if (enabledGateways.isEmpty) {
      return null;
    }

    final selectedGateway = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.color.secondaryColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: Constant.appContentPadding,
            children: [
              Text(
                'selectPaymentMethod'.translate(context),
                style: context.titleMedium.bold,
              ),
              ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 15),
                itemCount: enabledGateways.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _PaymentMethodTile(
                    gateway: enabledGateways[index],
                    onSelect: (String? value) {
                      Navigator.pop(context, value);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    return selectedGateway;
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentGateway gateway;
  final ValueChanged<String?> onSelect;

  const _PaymentMethodTile({required this.gateway, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomImage(
        src: _gatewayIcon(gateway.type),
        size: Size.square(24),
      ),
      title: Text(gateway.name),
      onTap: () => onSelect(gateway.type),
    );
  }

  String _gatewayIcon(String type) {
    switch (type) {
      case Constant.paymentTypeStripe:
        return AppAssets.payment.stripe;
      case Constant.paymentTypePaystack:
        return AppAssets.payment.paystack;
      case Constant.paymentTypeRazorpay:
        return AppAssets.payment.razorpay;
      case Constant.paymentTypePhonepe:
        return AppAssets.payment.phonePe;
      case Constant.paymentTypeFlutterwave:
        return AppAssets.payment.flutterwave;
      case Constant.paymentTypeBankTransfer:
        return AppAssets.payment.bankTransfer;
      case Constant.paymentTypePaypal:
        return AppAssets.payment.paypal;
      case Constant.paymentTypePaytabs:
        return AppAssets.payment.paytabs;
      case Constant.paymentTypeDpo:
        return AppAssets.payment.dpo;
      default:
        return "";
    }
  }
}
