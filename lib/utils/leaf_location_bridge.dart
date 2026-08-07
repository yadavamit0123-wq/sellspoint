import 'package:eClassify/data/model/location/leaf_location.dart';

/// Read-only helpers for home/list APIs from [LeafLocation.fromLegacyHive].
abstract final class LeafLocationBridge {
  static LeafLocation get current => LeafLocation.fromLegacyHive();

  static ({
    String? city,
    int? areaId,
    String? country,
    String? state,
  }) get featuredSection {
    final loc = current;
    return (
      city: loc.city,
      areaId: loc.areaId,
      country: loc.country,
      state: loc.state,
    );
  }

  static ({
    String? city,
    int? areaId,
    String? country,
    String? state,
    double? latitude,
    double? longitude,
    int? radius,
  }) get allItems {
    final loc = current;
    return (
      city: loc.city,
      areaId: loc.areaId,
      country: loc.country,
      state: loc.state,
      latitude: loc.latitude,
      longitude: loc.longitude,
      radius: loc.radius?.toInt(),
    );
  }
}
