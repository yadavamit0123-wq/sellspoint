import 'package:eClassify/data/model/item/item_model.dart';

abstract final class ItemJobHelper {
  static bool isJobListing(ItemModel item) {
    if (item.itemType?.toLowerCase() == 'job') return true;
    if (item.category?.isJobCategory == true) return true;
    return false;
  }
}
