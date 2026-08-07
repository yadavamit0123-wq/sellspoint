import 'package:eClassify/ui/screens/item/add_item_screen/select_category.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';

/// Resets legacy post-ad globals after a successful in-app wizard post.
abstract final class AdPostingWizardCleanup {
  static const _cloudKeys = [
    'item_details',
    'with_more_details',
    'breadCrumb',
  ];

  static void afterSuccessfulPost() {
    screenStack = 0;
    for (final key in _cloudKeys) {
      CloudState.cloudData.remove(key);
    }
  }

  static void onWizardLocationAborted() {
    if (screenStack > 0) {
      screenStack--;
    }
  }
}
