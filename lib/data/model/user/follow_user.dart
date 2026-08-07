class FollowUser {
  FollowUser({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.profile,
    required this.isFollowing,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      profile: json['profile'] as String?,
      isFollowing: json['is_following'] == 1 ||
          json['is_following'] == true ||
          json['is_following'] == '1',
    );
  }

  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? profile;
  final bool isFollowing;
}
