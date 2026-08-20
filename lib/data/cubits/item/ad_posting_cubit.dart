import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:eClassify/data/repositories/item/video_ad_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingState {
  final AdPostingStep activeStep;
  final List<AdPostingStep> steps;
  final AdPostingData adPostingData;
  final bool isFetchingReel;

  const AdPostingState({
    required this.activeStep,
    required this.steps,
    required this.adPostingData,
    this.isFetchingReel = false,
  });

  AdPostingState copyWith({
    AdPostingStep? activeStep,
    List<AdPostingStep>? steps,
    AdPostingData? adPostingData,
    bool? isFetchingReel,
  }) {
    return AdPostingState(
      activeStep: activeStep ?? this.activeStep,
      steps: steps ?? this.steps,
      adPostingData: adPostingData ?? this.adPostingData,
      isFetchingReel: isFetchingReel ?? this.isFetchingReel,
    );
  }
}

class AdPostingCubit extends Cubit<AdPostingState> {
  AdPostingCubit([AdPostingData? data])
    : isEdit = data != null,
      super(_initialState(data)) {
    if (isEdit && data!.adType == AdItemType.videoAd && data.id != null) {
      _fetchReel(data.id!);
    }
  }

  final bool isEdit;

  Future<void> _fetchReel(int itemId) async {
    emit(state.copyWith(isFetchingReel: true));
    try {
      final response = await VideoAdRepository.instance.getVideoAds(
        itemId: itemId,
        showCurrentUserReel: true,
      );
      if (response.modelList.isNotEmpty && !isClosed) {
        final videoAd = response.modelList.first;
        updateData((current) {
          return current.copyWith(
            videoAd: FileResource.fromPath(videoAd.video),
            thumbnail: FileResource.fromPath(videoAd.thumbnail),
          );
        });
        Log.info('${state.adPostingData.toString()}');
      }
    } catch (_) {
    } finally {
      if (!isClosed) emit(state.copyWith(isFetchingReel: false));
    }
  }

  static AdPostingState _initialState([AdPostingData? data]) {
    final List<AdPostingStep> steps = [
      if (data == null) ...[AdPostingStep.adType, AdPostingStep.category],
      AdPostingStep.baseDetails,
      AdPostingStep.mediaUpload,
      AdPostingStep.location,
    ];

    return AdPostingState(
      activeStep: steps.first,
      steps: steps,
      adPostingData: data ?? const AdPostingData(),
    );
  }

  void updateData(AdPostingData Function(AdPostingData current) updater) {
    emit(state.copyWith(adPostingData: updater(state.adPostingData)));
  }

  void clearDataExceptAdType() {
    final steps = List<AdPostingStep>.from(state.steps);
    steps.removeWhere((step) => step == AdPostingStep.customFields);
    emit(
      state.copyWith(
        adPostingData: AdPostingData(adType: state.adPostingData.adType),
        steps: steps,
      ),
    );
  }

  void nextStep() {
    final currentIndex = state.steps.indexOf(state.activeStep);
    if (currentIndex < state.steps.length - 1) {
      emit(state.copyWith(activeStep: state.steps[currentIndex + 1]));
    }
    Log.info('${state.adPostingData.toString()}');
  }

  void previousStep() {
    final currentIndex = state.steps.indexOf(state.activeStep);
    if (currentIndex > 0) {
      emit(state.copyWith(activeStep: state.steps[currentIndex - 1]));
    }
  }

  void addStep(AdPostingStep step, {AdPostingStep? after}) {
    final steps = List<AdPostingStep>.from(state.steps);
    if (after != null) {
      final index = steps.indexOf(after);
      if (index == -1) return;
      steps.insert(index + 1, step);
    } else {
      steps.add(step);
    }
    emit(state.copyWith(steps: steps));
  }

  void jumpToStep(AdPostingStep step) {
    emit(state.copyWith(activeStep: step));
  }
}
