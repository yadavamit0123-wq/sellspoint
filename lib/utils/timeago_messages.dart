import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';

class TimeagoMessages {
  static final _messageMap = {
    'en_US': timeago.EnMessages(),
    'en_US_short': timeago.EnShortMessages(),
    'ar_SA': timeago.ArMessages(),
    'ar_SA_short': timeago.ArShortMessages(),
    'fr_FR': timeago.FrMessages(),
    'fr_FR_short': timeago.FrShortMessages(),
    'hi_IN': timeago.HiMessages(),
    'hi_IN_short': timeago.HiShortMessages(),
    'pt_BR': timeago.PtBrMessages(),
    'pt_BR_short': timeago.PtBrShortMessages(),
    'es_ES': timeago.EsMessages(),
    'es_ES_short': timeago.EsShortMessages(),
    'tr_TR': timeago.TrMessages(),
    'tr_TR_short': timeago.TrShortMessages(),
  };

  static LookupMessages getMessages(String locale) =>
      _messageMap[locale] ?? timeago.EnMessages();
}
