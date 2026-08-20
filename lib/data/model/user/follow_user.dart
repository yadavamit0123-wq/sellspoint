import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/utils/json_helper.dart';

class FollowUser {
  FollowUser.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String?,
      mobile = json['mobile'] as String?,
      profile = json['profile'] as String?,
      isFollowing = json['is_following'] as int == 1;

  FollowUser.fromUser(User user, {required this.isFollowing})
    : id = user.id ?? 0,
      name = user.name ?? '',
      email = user.email,
      mobile = user.mobile,
      profile = user.profile;

  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? profile;
  final bool isFollowing;
}
