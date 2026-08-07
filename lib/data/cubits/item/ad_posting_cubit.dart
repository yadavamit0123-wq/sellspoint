import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/data/model/item/ad_posting_step.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingState {
  const AdPostingState({
    required this.activeStep,
    required this.steps,
    required this.adPostingData,
  });

  final AdPostingStep activeStep;
  final List<AdPostingStep> steps;
  final AdPostingData adPostingData;

  AdPostingState copyWith({
    AdPostingStep? activeStep,
    List<AdPostingStep>? steps,
    AdPostingData? adPostingData,
  }) {
    return AdPostingState(
      activeStep: activeStep ?? this.activeStep,
      steps: steps ?? this.steps,
      adPostingData: adPostingData ?? this.adPostingData,
    );
  }
}

class AdPostingCubit extends Cubit<AdPostingState> {
  AdPostingCubit() : super(_initialState());

  static AdPostingState _initialState() {
    const steps = [
      AdPostingStep.adType,
      AdPostingStep.category,
      AdPostingStep.baseDetails,
      AdPostingStep.mediaUpload,
    ];
    return AdPostingState(
      activeStep: steps.first,
      steps: steps,
      adPostingData: const AdPostingData(),
    );
  }

  void updateData(AdPostingData Function(AdPostingData current) updater) {
    emit(state.copyWith(adPostingData: updater(state.adPostingData)));
  }

  void clearDataExceptAdType() {
    emit(
      state.copyWith(
        adPostingData: AdPostingData(adType: state.adPostingData.adType),
      ),
    );
  }

  void nextStep() {
    final index = state.steps.indexOf(state.activeStep);
    if (index < state.steps.length - 1) {
      emit(state.copyWith(activeStep: state.steps[index + 1]));
    }
  }

  void previousStep() {
    final index = state.steps.indexOf(state.activeStep);
    if (index > 0) {
      emit(state.copyWith(activeStep: state.steps[index - 1]));
    }
  }

  void jumpToStep(AdPostingStep step) {
    if (state.steps.contains(step)) {
      emit(state.copyWith(activeStep: step));
    }
  }

  void addStep(AdPostingStep step, {required AdPostingStep after}) {
    final steps = List<AdPostingStep>.from(state.steps);
    if (steps.contains(step)) return;
    final index = steps.indexOf(after);
    if (index == -1) return;
    steps.insert(index + 1, step);
    emit(state.copyWith(steps: steps));
  }

  void removeStep(AdPostingStep step) {
    final steps = List<AdPostingStep>.from(state.steps);
    if (!steps.remove(step)) return;
    var active = state.activeStep;
    if (active == step) {
      active = steps.isNotEmpty ? steps.first : active;
    }
    emit(state.copyWith(steps: steps, activeStep: active));
  }

  void reset() {
    emit(_initialState());
  }
}
