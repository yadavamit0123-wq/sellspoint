import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/utils/api.dart';

class FollowRepository {
  Future<void> followUser({required int userId}) async {
    await Api.post(url: Api.followUserApi, parameter: {Api.userId: userId});
  }

  Future<void> unFollowUser({required int userId}) async {
    await Api.post(url: Api.unFollowUserApi, parameter: {Api.userId: userId});
  }

  Future<({List<FollowUser> users, int total, bool hasMore})> getFollowUsers({
    required FollowUserListType type,
    int? userId,
    int page = 1,
  }) async {
    final endpoint = type == FollowUserListType.followers
        ? Api.followersApi
        : Api.followingApi;

    final response = await Api.get(
      url: endpoint,
      queryParameters: {
        if (userId != null) Api.userId: userId,
        Api.page: page,
      },
    );

    final data = response['data'] as Map? ?? {};
    final rawList = data['data'] as List? ?? [];
    final users = rawList
        .map((e) => FollowUser.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final total = data['total'] as int? ?? users.length;
    final perPage = data['per_page'] as int? ?? users.length;
    final hasMore = page * (perPage > 0 ? perPage : users.length) < total ||
        users.length >= (perPage > 0 ? perPage : 15);

    return (users: users, total: total, hasMore: hasMore && users.isNotEmpty);
  }
}
