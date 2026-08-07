/// Semantic app version (2.14-style), tolerant of admin `x.y.z` or `x.y.z+build`.
class Version implements Comparable<Version> {
  Version({
    required this.major,
    required this.minor,
    required this.patch,
    this.build,
  });

  factory Version.fromString(String versionCode) {
    final trimmed = versionCode.trim();
    final plusParts = trimmed.split('+');
    final versionPart = plusParts[0].trim();
    final build = plusParts.length > 1 ? int.tryParse(plusParts[1].trim()) : null;

    final numbers = versionPart.split('.');
    if (numbers.isEmpty || numbers[0].isEmpty) {
      throw ArgumentError('Invalid version: $versionCode');
    }

    return Version(
      major: int.parse(numbers[0]),
      minor: numbers.length > 1 ? int.parse(numbers[1]) : 0,
      patch: numbers.length > 2 ? int.parse(numbers[2]) : 0,
      build: build,
    );
  }

  final int major;
  final int minor;
  final int patch;
  final int? build;

  @override
  int compareTo(Version other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    if (build == null || other.build == null) return 0;
    return build!.compareTo(other.build!);
  }

  bool operator >(Version other) => compareTo(other) > 0;

  @override
  String toString() => '$major.$minor.$patch${build != null ? '+$build' : ''}';
}
