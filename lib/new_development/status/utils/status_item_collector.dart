import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';

List<StatusModel> collectStatusFromItems(Iterable<ItemModel> items) {
  final seenIds = <int>{};
  final allStatus = <StatusModel>[];

  for (final item in items) {
    final id = item.id;
    if (id == null || seenIds.contains(id)) continue;

    final images = (item.galleryImages ?? [])
        .map((image) => image.image)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
    if (images.isEmpty) continue;

    seenIds.add(id);
    allStatus.add(
      StatusModel(
        item: item,
        name: item.user?.name ?? '',
        avatarUrl: item.user?.profile ?? '',
        mediaUrls: images,
        description: item.name ?? '',
      ),
    );
  }

  return allStatus;
}
