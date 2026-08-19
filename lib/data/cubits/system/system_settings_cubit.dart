import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/data/repositories/system_repository.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/meta_sdk_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SystemSettingsState {}

class SystemSettingsInitial extends SystemSettingsState {}

class SystemSettingsLoading extends SystemSettingsState {}

class SystemSettingsFailure extends SystemSettingsState {
  SystemSettingsFailure({required this.error});

  final Object error;
}

class SystemSettingsSuccess extends SystemSettingsState {
  SystemSettingsSuccess({required this.settings});

  final SystemSettings settings;
}

class SystemSettingsCubit extends Cubit<SystemSettingsState> {
  SystemSettingsCubit() : super(SystemSettingsInitial());

  Future<void> getSystemSettings() async {
    try {
      emit(SystemSettingsLoading());

      final settings = await SystemRepository.instance.getSystemSettings();

      // This isn't the ideal way to access system settings everywhere in the codebase
      // but we can't rely just on this cubit to retrieve the settings because
      // system settings instance is required in places where passing context
      // would violate the boundaries of UI and Service layer. Hence this is
      // only the sane solution as of now to avoid complicating it much
      // TODO(I): Find a better way to access system settings
      Constant.systemSettings = settings;

      await MetaSdkService.configure(settings);

      emit(SystemSettingsSuccess(settings: settings));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(SystemSettingsFailure(error: e));
    }
  }
}
