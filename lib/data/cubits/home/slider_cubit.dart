import 'dart:developer';

import 'package:eClassify/data/model/home/home_slider.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SliderState {}

class SliderInitial extends SliderState {}

class SliderLoading extends SliderState {}

class SliderSuccess extends SliderState {
  SliderSuccess({required this.sliders});
  final List<HomeSlider> sliders;
}

class SliderFailure extends SliderState {
  SliderFailure({required this.error});
  final Object error;
}

class SliderCubit extends Cubit<SliderState> {
  SliderCubit() : super(SliderInitial());

  final _repository = HomeRepository.instance;

  Future<void> fetchSliders({required LeafLocation? location}) async {
    try {
      emit(SliderLoading());
      final sliders = await _repository.getSliders(location: location);
      emit(SliderSuccess(sliders: sliders));
    } catch (e, st) {
      log('$e', name: 'fetchSliders');
      log('$st', name: 'fetchSliders');
      emit(SliderFailure(error: e));
    }
  }
}
