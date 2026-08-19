import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/log.dart';

class AIRepository {
  AIRepository._internal();

  static final AIRepository _instance = AIRepository._internal();

  static AIRepository get instance => _instance;

  Future<Map<String, dynamic>> generateMeta({
    required String title,
    required String price,
    required String languageId,
    required String currencyISOCode,
    required String category,
  }) async {
    try {
      final response = await Api.post(
        url: Api.generateMeta,
        parameter: {
          'title': title,
          'price': price,
          'language_id': languageId,
          'currency_iso_code': currencyISOCode,
          'category_name': category,
        },
      );
      return response['data'];
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<String> generateDescription({
    required String title,
    required String price,
    required String languageId,
    required String category,
    required String currencyISOCode,
  }) async {
    try {
      final response = await Api.post(
        url: Api.generateDescription,
        parameter: {
          'title': title,
          'price': price,
          'language_id': languageId,
          'category': category,
          'currency_iso_code': currencyISOCode,
        },
      );
      return response['data']['description'];
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }
}
