import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on double {
  String currencyFormat([Currency? currency]) {
    final formatted = this.decimalFormat;

    if (currency != null) {
      return NumberFormat.currency(
        name: currency.code,
        symbol: currency.symbol,
      ).format(this);
    }

    return Constant.systemSettings.defaultCurrency.isSymbolOnLeft
        ? '${Constant.systemSettings.defaultCurrency.symbol} $formatted'
        : '$formatted ${Constant.systemSettings.defaultCurrency.symbol}';
  }

  String get decimalFormat {
    final supportsLocale = NumberFormat.localeExists(AppSession.currentLocale);
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: supportsLocale ? AppSession.currentLocale : Intl.defaultLocale,
      decimalDigits: 2,
    );
    return numberFormat.format(this);
  }
}
