import 'package:eClassify/utils/hive_utils.dart';

/// Unified location DTO for the 2.14 merge (backed by live Hive city/state/lat keys).
class LeafLocation {
  LeafLocation({
    this.placeId,
    this.area,
    this.areaId,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.radius,
    this.primaryText,
    this.secondaryText,
  }) {
    _ensureDisplayLabels();
  }

  factory LeafLocation.fromLegacyHive() {
    return LeafLocation(
      area: _asString(HiveUtils.getAreaName()),
      areaId: _asInt(HiveUtils.getAreaId()),
      city: _asString(HiveUtils.getCityName()),
      state: _asString(HiveUtils.getStateName()),
      country: _asString(HiveUtils.getCountryName()),
      latitude: _asDouble(HiveUtils.getLatitude()),
      longitude: _asDouble(HiveUtils.getLongitude()),
      radius: _asNum(HiveUtils.getNearbyRadius()),
    );
  }

  factory LeafLocation.fromJson(Map<String, dynamic> json) {
    return LeafLocation(
      placeId: json['place_id'] as String?,
      area: json['area'] as String?,
      areaId: json['area_id'] as int?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      radius: json['radius'] as num?,
      primaryText: json['primary_text'] as String?,
      secondaryText: json['secondary_text'] as String?,
    );
  }

  final String? placeId;
  final String? area;
  final int? areaId;
  final String? city;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final num? radius;
  String? primaryText;
  String? secondaryText;

  bool get isEmpty =>
      (city == null || city!.isEmpty) &&
      (state == null || state!.isEmpty) &&
      (country == null || country!.isEmpty);

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get usesRadiusFilter => radius != null && radius.toString().isNotEmpty;

  String get displayLabel => primaryText ?? city ?? state ?? country ?? '';

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'area': area,
        'area_id': areaId,
        'city': city,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'primary_text': primaryText,
        'secondary_text': secondaryText,
      };

  /// Persists into existing Hive location keys (live location picker flow).
  Future<void> applyToLegacyHive() async {
    HiveUtils.setLocation(
      city: city,
      state: state,
      country: country,
      area: area,
      areaId: areaId,
      latitude: latitude,
      longitude: longitude,
      radius: radius?.toDouble(),
    );
    await HiveUtils.setLeafLocationJson(this);
  }

  void _ensureDisplayLabels() {
    final parts = [
      if (area != null && area!.isNotEmpty) area,
      if (city != null && city!.isNotEmpty) city,
      if (state != null && state!.isNotEmpty) state,
      if (country != null && country!.isNotEmpty) country,
    ];
    primaryText ??= parts.isNotEmpty ? parts.first : null;
    secondaryText ??=
        parts.length > 1 ? parts.sublist(1).join(', ') : null;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static num? _asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }
}
