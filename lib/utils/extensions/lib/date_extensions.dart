import 'package:eClassify/utils/app_session.dart';
import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String format({DateFormat? format, String? formatString}) {
    final localeExists = DateFormat.localeExists(AppSession.currentLocale);
    final locale = localeExists ? AppSession.currentLocale : Intl.defaultLocale;

    final dateFormat =
        format ?? DateFormat(formatString ?? 'MMM d, yyyy', locale);
    return dateFormat.format(this);
  }
}
