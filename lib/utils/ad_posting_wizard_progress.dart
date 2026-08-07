import 'package:eClassify/data/model/item/ad_posting_step.dart';

/// Step counts for in-app wizard + confirm location screen.
abstract final class AdPostingWizardProgress {
  /// Wizard [steps] plus one confirm-location step.
  static int totalWithLocation(List<AdPostingStep> steps) => steps.length + 1;

  static int confirmLocationStepIndex(List<AdPostingStep> steps) =>
      totalWithLocation(steps);
}
