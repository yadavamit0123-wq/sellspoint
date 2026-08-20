import 'dart:convert';

import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/meta_sdk_service.dart';
import 'package:eClassify/utils/payment/gateaways/stripe_service.dart';
import 'package:eClassify/utils/payment/payment_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGateways {
  static Future<void> stripe(
    BuildContext context, {
    required double price,
    required int packageId,
    required dynamic paymentIntent,
  }) async {
    String paymentIntentId = paymentIntent["id"].toString();
    String clientSecret =
        paymentIntent['payment_gateway_response']["client_secret"].toString();

    await StripeService.payWithPaymentSheet(
      context: context,
      merchantDisplayName: AppConfig.applicationName,
      amount: paymentIntent["amount"].toString(),
      currency: PaymentSettings.stripeCurrency,
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
  }

  static Future<void> phonepeCheckSum({
    required BuildContext context,
    required dynamic getData,
  }) async {
    try {
      await PhonePePaymentSdk.init(
            getData["environment"],
            getData["merchantId"],
            getData["flowId"],
            getData["enableLogging"],
          )
          .then((val) {
            Map<String, dynamic> payload = {
              "orderId": getData["request"]["orderId"],
              "merchantId": getData["request"]["merchantId"],
              "merchantOrderId": getData["request"]["merchantOrderId"],
              "token": getData["request"]["token"],
              "paymentMode": {"type": "PAY_PAGE"},
            };

            String request = jsonEncode(payload);
            print("Payment Request: $request");

            startPaymentPhonePe(
              context: context,
              request: request,
              appSchema: getData["appSchema"],
              orderId: getData["request"]["orderId"]?.toString(),
            );
          })
          .catchError((error) {
            print("phonepe catch error***${error.toString()}");
            HelperUtils.showSnackBarMessage(
              context,
              error.toString(),
              type: MessageType.error,
            );
            return null;
          });
    } catch (error) {
      print("phonepe error***${error.toString()}");
      HelperUtils.showSnackBarMessage(
        context,
        error.toString(),
        type: MessageType.error,
      );
    }
  }

  static void startPaymentPhonePe({
    required BuildContext context,
    required String request,
    required String appSchema,
    String? orderId,
  }) async {
    try {
      PhonePePaymentSdk.startTransaction(request, appSchema)
          .then((response) {
            print('phonepe response***$response');
            if (response != null) {
              String status = response['status'].toString();
              print("phonepe status***$status");
              if (status == 'SUCCESS') {
                print("status success");
                MetaSdkService.logPurchase(
                  amount: 0,
                  currency: PaymentSettings.phonePeCurrency.isNotEmpty
                      ? PaymentSettings.phonePeCurrency
                      : Constant.systemSettings.defaultCurrency.code,
                  orderId: orderId,
                );
                HelperUtils.showSnackBarMessage(
                  context,
                  "paymentSuccessfullyCompleted".translate(context),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                print("phonepe else failed***");
                HelperUtils.showSnackBarMessage(
                  context,
                  "purchaseFailed".translate(context),
                  type: MessageType.error,
                );
              }
            } else {
              print("phonepe else failed1***");
              HelperUtils.showSnackBarMessage(
                context,
                "purchaseFailed".translate(context),
                type: MessageType.error,
              );
            }
          })
          .catchError((error) {
            print("phonepe error22***${error.toString()}");
            HelperUtils.showSnackBarMessage(
              context,
              error.toString(),
              type: MessageType.error,
            );
            return null;
          });
    } catch (error) {
      print("phonepe error11***${error.toString()}");
      HelperUtils.showSnackBarMessage(
        context,
        error.toString(),
        type: MessageType.error,
      );
    }
  }

  static void razorpay({
    required BuildContext context,
    required price,
    required orderId,
    required packageId,
  }) {
    final Razorpay razorpay = Razorpay();

    var options = {
      'key': PaymentSettings.razorpayKey,
      'amount': price! * 100,
      'name': HiveUtils.getUserDetails().name ?? "",
      'description': '',
      'order_id': orderId,
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile ?? "",
        'email': HiveUtils.getUserDetails().email ?? "",
      },
      "notes": {"package_id": packageId, "user_id": HiveUtils.getUserId()},
    };

    if (PaymentSettings.razorpayKey != "") {
      razorpay.open(options);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (
        PaymentSuccessResponse response,
      ) async {
        await _purchase(context, price: price, packageId: packageId);
      });
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (
        PaymentFailureResponse response,
      ) {
        HelperUtils.showSnackBarMessage(
          context,
          "purchaseFailed".translate(context),
        );
      });
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (e) {});
    } else {
      HelperUtils.showSnackBarMessage(context, "setAPIkey".translate(context));
    }
  }

  static Future<void> _purchase(BuildContext context, {required price, required packageId}) async {
    try {
      Future.delayed(Duration.zero, () {
        MetaSdkService.logPurchase(
          amount: (price as num).toDouble(),
          currency: PaymentSettings.razorpayCurrency.isNotEmpty
              ? PaymentSettings.razorpayCurrency
              : Constant.systemSettings.defaultCurrency.code,
          orderId: 'razorpay_$packageId',
          packageId: packageId,
        );
        HelperUtils.showSnackBarMessage(
          context,
          "success".translate(context),
          type: MessageType.success,
          messageDuration: 5,
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        "purchaseFailed".translate(context),
        type: MessageType.error,
      );
    }
  }
}
