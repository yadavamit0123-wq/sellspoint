import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Session mirror of the user's selected location (Hive-backed for live app).
class LeafLocationCubit extends Cubit<LeafLocation> {
  LeafLocationCubit() : super(LeafLocation.fromLegacyHive()) {
    AppSession.setCurrentLocation(state);
  }

  void syncFromLegacyHive() {
    final location = LeafLocation.fromLegacyHive();
    emit(location);
    AppSession.setCurrentLocation(location);
  }

  Future<void> setLocation(LeafLocation location) async {
    await location.applyToLegacyHive();
    emit(location);
    AppSession.setCurrentLocation(location);
  }

  void clear() {
    HiveUtils.clearLocation();
    final empty = LeafLocation();
    emit(empty);
    AppSession.setCurrentLocation(empty);
  }
}
