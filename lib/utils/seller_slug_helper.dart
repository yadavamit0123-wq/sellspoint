/// Helpers for seller profile share URLs (`saaho-mori-1277`).
class SellerSlugHelper {
  SellerSlugHelper._();

  static int? parseSellerId(String value) {
    final trimmed = Uri.decodeComponent(value.trim());
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return int.tryParse(trimmed);
    }

    final match = RegExp(r'-(\d+)$').firstMatch(trimmed);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }

  static String buildSlug({required String name, required int id, String? slug}) {
    if (slug != null && slug.isNotEmpty) {
      return slug;
    }

    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');

    return '${base.isEmpty ? 'user' : base}-$id';
  }
}
