// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eClassify/app/app_localization.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/repositories/system_repository.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/timeago_messages.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageFetchSuccess extends LanguageState {
  LanguageFetchSuccess({required this.language});

  final Language language;
}

class LanguageFailure extends LanguageState {
  LanguageFailure({required this.error});

  final Object error;
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  Future<void> loadLanguage(Language language) async {
    try {
      emit(LanguageLoading());

      final languageData = await SystemRepository.instance.getLanguage(
        languageCode: language.languageCode,
      );

      // This param is json data which contains all the translations.
      final translations = languageData['file_name'] as Map<String, dynamic>;
      AppLocalization.setTranslations(translations);

      final bool shouldStore = AppSession.currentLanguage?.id != language.id;
      if (shouldStore) {
        await HiveUtils.storeLanguage(language);
      }

      AppSession.setCurrentLanguage(language);

      Log.info('${AppSession.currentLocale}');

      // Long Messages for items
      timeago.setLocaleMessages(
        AppSession.currentLocale,
        TimeagoMessages.getMessages(AppSession.currentLocale),
      );
      // Short Messages for chats
      timeago.setLocaleMessages(
        '${AppSession.currentLocale}_short',
        TimeagoMessages.getMessages('${AppSession.currentLocale}_short'),
      );

      emit(LanguageFetchSuccess(language: language));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(LanguageFailure(error: e));
    }
  }
}
