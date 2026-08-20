import 'package:eClassify/utils/app_session.dart';
import 'package:intl/intl.dart';

extension NumberFormatter on num {
  String get compact {
    final currentLocale = AppSession.currentLocale;
    final localeExists = NumberFormat.localeExists(currentLocale);
    final effectiveLocale = localeExists ? currentLocale : 'en_US';
    final formatter = NumberFormat.compact(locale: effectiveLocale);
    return formatter.format(this);
  }
}
