import 'package:eClassify/ui/screens/item/add_item_screen/select_category.dart';
import 'package:eClassify/ui/screens/widgets/dynamic_field.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:eClassify/utils/video_ad_editor_draft.dart';

/// Resets legacy post-ad globals after a successful in-app wizard post.
abstract final class AdPostingWizardCleanup {
  static const _cloudKeys = [
    'item_details',
    'with_more_details',
    'breadCrumb',
    'pending_reel_upload',
  ];

  static void afterSuccessfulPost() {
    screenStack = 0;
    for (final key in _cloudKeys) {
      CloudState.cloudData.remove(key);
    }
    _clearCustomFieldStatics();
  }

  /// Call when opening a new post-ad session (FAB / launcher).
  static void prepareForNewSession() {
    afterSuccessfulPost();
  }

  static void _clearCustomFieldStatics() {
    AbstractField.fieldsData.clear();
    AbstractField.files.clear();
    VideoAdEditorDraft.clear();
  }

  static void onWizardLocationAborted() {
    if (screenStack > 0) {
      screenStack--;
    }
  }
}
