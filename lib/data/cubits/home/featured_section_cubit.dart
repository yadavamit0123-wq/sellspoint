import 'package:eClassify/data/model/home/featured_section.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FeaturedSectionState {}

class FeaturedSectionInitial extends FeaturedSectionState {}

class FeaturedSectionLoading extends FeaturedSectionState {}

class FeaturedScreenSuccess extends FeaturedSectionState {
  FeaturedScreenSuccess({required this.sections});

  final List<FeaturedSection> sections;
}

class FeaturedSectionFailure extends FeaturedSectionState {
  FeaturedSectionFailure({required this.error});

  final Object? error;
}

class FeaturedSectionCubit extends Cubit<FeaturedSectionState> {
  FeaturedSectionCubit() : super(FeaturedSectionInitial());

  void fetch({required LeafLocation? location}) async {
    try {
      emit(FeaturedSectionLoading());
      final sections = await HomeRepository.instance.getFeaturedSection(
        location: location,
      );

      emit(FeaturedScreenSuccess(sections: sections));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(FeaturedSectionFailure(error: e));
    }
  }
}
