import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Base state for API keys
abstract class GetPaymentMethodsState {}

class GetPaymentMethodsInitial extends GetPaymentMethodsState {}

class GetPaymentMethodsLoading extends GetPaymentMethodsState {}

class GetPaymentMethodsFailure extends GetPaymentMethodsState {
  GetPaymentMethodsFailure(this.error);

  final String error;
}

/// Success state containing all payment gateway settings
class GetPaymentMethodsSuccess extends GetPaymentMethodsState {
  final String? stripePublishableKey;

  //
  final String? razorPayKey;

  // Currency codes
  final String? razorPayCurrency;
  final String? payStackCurrency;
  final String? stripeCurrency;
  final String? phonePeCurrency;
  final String? flutterWaveCurrency;
  final String? paypalCurrency;
  final String? paytabsCurrency;
  final String? dpoCurrency;

  // Bank transfer details
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankIfscSwiftCode;

  // Status flags
  final int razorPayStatus;
  final int payStackStatus;
  final int stripeStatus;
  final int phonePeStatus;
  final int flutterWaveStatus;
  final int bankTransferStatus;
  final int paypalStatus;
  final int paytabsStatus;
  final int dpoStatus;

  GetPaymentMethodsSuccess({
    this.razorPayKey,
    this.razorPayCurrency,
    this.payStackCurrency,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.phonePeCurrency,
    this.flutterWaveCurrency,
    this.paypalCurrency,
    this.paytabsCurrency,
    this.dpoCurrency,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankName,
    this.bankIfscSwiftCode,
    this.razorPayStatus = 0,
    this.payStackStatus = 0,
    this.stripeStatus = 0,
    this.phonePeStatus = 0,
    this.flutterWaveStatus = 0,
    this.bankTransferStatus = 0,
    this.paypalStatus = 0,
    this.paytabsStatus = 0,
    this.dpoStatus = 0,
  });
}

/// Cubit responsible for managing payment API keys and settings
class GetPaymentMethodsCubit extends Cubit<GetPaymentMethodsState> {
  GetPaymentMethodsCubit() : super(GetPaymentMethodsInitial());

  /// Fetches payment API keys and settings from the server
  Future<void> fetch() async {
    try {
      emit(GetPaymentMethodsLoading());

      final result = await Api.get(url: Api.getPaymentSettingsApi);
      final data = result['data'] ?? {};

      emit(
        GetPaymentMethodsSuccess(
          razorPayKey: _getData(data, Api.razorpay, Api.apiKey),
          // Razorpay settings
          razorPayCurrency: _getData(data, Api.razorpay, Api.currencyCode),
          razorPayStatus: _getIntData(data, Api.razorpay, Api.status),

          // Paystack settings
          payStackCurrency: _getData(data, Api.payStack, Api.currencyCode),
          payStackStatus: _getIntData(data, Api.payStack, Api.status),

          // Stripe settings
          stripeCurrency: _getData(data, Api.stripe, Api.currencyCode),
          stripePublishableKey: _getData(data, Api.stripe, Api.apiKey),
          stripeStatus: _getIntData(data, Api.stripe, Api.status),

          // PhonePe settings
          phonePeCurrency: _getData(data, Api.phonePe, Api.currencyCode),
          phonePeStatus: _getIntData(data, Api.phonePe, Api.status),

          // Flutterwave settings
          flutterWaveCurrency: _getData(
            data,
            Api.flutterwave,
            Api.currencyCode,
          ),
          flutterWaveStatus: _getIntData(data, Api.flutterwave, Api.status),

          // Paytabs settings
          paytabsCurrency: _getData(data, Api.paytabs, Api.currencyCode),
          paytabsStatus: _getIntData(data, Api.paytabs, Api.status),

          // DPO settings
          dpoCurrency: _getData(data, Api.dpo, Api.currencyCode),
          dpoStatus: _getIntData(data, Api.dpo, Api.status),

          // Bank transfer settings
          bankAccountHolder: _getData(
            data,
            Api.bankTransfer,
            Api.accountHolderName,
          ),
          bankAccountNumber: _getData(
            data,
            Api.bankTransfer,
            Api.accountNumber,
          ),
          bankName: _getData(data, Api.bankTransfer, Api.bankName),
          bankIfscSwiftCode: _getData(
            data,
            Api.bankTransfer,
            Api.ifscSwiftCode,
          ),
          bankTransferStatus: _getIntData(data, Api.bankTransfer, Api.status),

          // PayPal Settings
          paypalCurrency: _getData(data, Api.paypal, Api.currencyCode),
          paypalStatus: _getIntData(data, Api.paypal, Api.status),
        ),
      );
    } catch (e) {
      emit(GetPaymentMethodsFailure(e.toString()));
    }
  }

  /// Gets string data from nested map with default value
  ///
  /// [data] - The data map to search in
  /// [type] - The payment gateway type
  /// [key] - The key to look up
  /// [defaultValue] - Default value if key is not found
  String _getData(
    Map<String, dynamic> data,
    String type,
    String key, {
    String defaultValue = '',
  }) => data[type]?[key]?.toString() ?? defaultValue;

  /// Gets integer data from nested map with default value
  ///
  /// [data] - The data map to search in
  /// [type] - The payment gateway type
  /// [key] - The key to look up
  /// [defaultValue] - Default value if key is not found
  int _getIntData(
    Map<String, dynamic> data,
    String type,
    String key, {
    int defaultValue = 0,
  }) =>
      int.tryParse(
        _getData(data, type, key, defaultValue: defaultValue.toString()),
      ) ??
      defaultValue;
}
