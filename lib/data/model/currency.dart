import 'package:eClassify/utils/json_helper.dart';

class Currency {
  Currency.fromJson(Json json)
    : id = json['id'] as int?,
      code = json['iso_code'] as String? ?? '',
      symbol = json['symbol'] as String,
      isSymbolOnLeft =
          (json['position'] as String? ?? json['symbol_position'] as String?) ==
          'left',
      selected = (json['selected'] as int?) == 1;

  final int? id;
  final String code;
  final String symbol;
  final bool isSymbolOnLeft;
  final bool selected;
}
