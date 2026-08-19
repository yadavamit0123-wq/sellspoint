import 'package:eClassify/data/cubits/followers/follow_user_list_cubit.dart';
import 'package:eClassify/data/model/user/follow_user.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/json_helper.dart';
import 'package:eClassify/utils/log.dart';

class FollowRepository {
  FollowRepository._internal();

  static final _instance = FollowRepository._internal();

  static FollowRepository get instance => _instance;

  Future<void> followUser({required int userId}) async {
    try {
      await Api.post(url: Api.followUserApi, parameter: {Api.userId: userId});
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> unFollowUser({required int userId}) async {
    try {
      await Api.post(url: Api.unFollowUserApi, parameter: {Api.userId: userId});
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getFollowUsers({required FollowUserListType type, int? userId, int page = 1}) async {
    try {
      final endpoint = switch(type){
        FollowUserListType.followers => Api.followersApi,
        FollowUserListType.following => Api.followingApi,
      };

      final response = await Api.get(
        url: endpoint,
        queryParameters: {Api.userId: ?userId, Api.page: page},
      );

      final users = JsonHelper.parseList(
        response['data']['data'] as List?,
        FollowUser.fromJson,
      );

      final hasMore = response['data']['per_page'] as int == users.length;
      final followersCount = response['data']['total'] as int;

      return {
        'users': users,
        'has_more': hasMore,
        'total_count': followersCount,
      };
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
