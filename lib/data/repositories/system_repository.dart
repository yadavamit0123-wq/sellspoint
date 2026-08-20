import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class SystemRepository {
  SystemRepository._();

  static final _instance = SystemRepository._();

  static SystemRepository get instance => _instance;

  Future<SystemSettings> getSystemSettings() async {
    try {
      final response = await Api.get(url: Api.getSystemSettingsApi);
      return JsonHelper.parseObject(
        response['data'] as Json,
        SystemSettings.fromJson,
      );
    } on Object catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> sendUserQuery({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      await Api.post(
        url: Api.contactUsApi,
        parameter: {
          Api.name: name,
          Api.email: email,
          'subject': subject,
          'message': message,
        },
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<Currency>> getCurrencies() async {
    try {
      final response = await Api.get(
        url: Api.getCurrenciesApi,
        queryParameters: {
          'country': ?AppSession.currentLocation?.country?.canonical,
        },
      );
      return JsonHelper.parseList(response['data'] as List?, Currency.fromJson);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getLanguage({required String languageCode}) async {
    try {
      final response = await Api.get(
        url: Api.getLanguageApi,
        queryParameters: {
          Api.languageCode: languageCode.toLowerCase(),
          Api.type: 'app',
        },
      );
      return response['data'] as Json;
    } on Object catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
