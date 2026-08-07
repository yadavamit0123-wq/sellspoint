import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:flutter/material.dart';

/// Owner flows from reels / shortcuts into legacy edit listing screens.
abstract final class OwnerListingNavigation {
  static void openEditListing(BuildContext context, ItemModel model) {
    CloudState.cloudData.addAll({
      'edit_request': model,
      'edit_from': model.status,
    });
    Navigator.pushNamed(
      context,
      Routes.addItemDetails,
      arguments: {'isEdit': true},
    );
  }
}
