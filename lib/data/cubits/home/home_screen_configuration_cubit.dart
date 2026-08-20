import 'package:eClassify/data/model/home/home_section.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeConfigurationState {}

class HomeConfigurationInitial extends HomeConfigurationState {}

class HomeConfigurationLoading extends HomeConfigurationState {}

class HomeConfigurationSuccess extends HomeConfigurationState {
  HomeConfigurationSuccess({required this.sections});

  final List<HomeSection> sections;
}

class HomeConfigurationFailure extends HomeConfigurationState {
  HomeConfigurationFailure({required this.error});

  final Object error;
}

class HomeConfigurationCubit extends Cubit<HomeConfigurationState> {
  HomeConfigurationCubit() : super(HomeConfigurationInitial());

  Future<void> getHomeConfiguration() async {
    try {
      emit(HomeConfigurationLoading());

      final sections = await HomeRepository.instance.getHomeConfiguration();

      emit(HomeConfigurationSuccess(sections: sections));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(HomeConfigurationFailure(error: e));
    }
  }
}
