import 'package:eClassify/utils/json_helper.dart';

class SellerRatingsModel {
  SellerRatingsModel.fromJson(Json json)
    : seller = JsonHelper.parseObject(json['seller'] as Json, Seller.fromJson),
      ratings = JsonHelper.parseList(
        json['ratings']?['data'] as List?,
        UserRatings.fromJson,
      ),
      ratingsCount = (json['ratings_count'] as Map?)?.cast<String, int>() ?? {};

  final Seller seller;
  final List<UserRatings> ratings;
  final Map<String, int> ratingsCount;
}

class Seller {
  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.phoneCode,
    required this.regionCode,
    required this.profile,
    required this.isVerified,
    required this.createdAt,
    required this.averageRating,
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.showPersonalDetails,
  });

  Seller.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String?,
      mobile = json['mobile'] as String?,
      phoneCode = json['country_code'] as String?,
      regionCode = json['region_code'] as String?,
      profile = json['profile'] as String?,
      isVerified = (json['is_verified'] as int?) == 1,
      createdAt = DateTime.tryParse(json['created_at'] as String? ?? ''),
      averageRating = json['average_rating'] as num? ?? 0.0,
      followers = json['followers_count'] as int,
      following = json['following_count'] as int,
      isFollowing = (json['is_following'] as int?) == 1,
      showPersonalDetails = (json['show_personal_details'] as int?) == 1;

  final int id;
  final String name;
  final String? email;
  final String? mobile;
  final String? phoneCode;
  final String? regionCode;
  final String? profile;
  final bool? isVerified;
  final DateTime? createdAt;
  final num averageRating;
  final int followers;
  final int following;
  final bool isFollowing;
  final bool showPersonalDetails;

  Seller copyWith({required int followers}) => Seller(
    id: id,
    name: name,
    email: email,
    mobile: mobile,
    phoneCode: phoneCode,
    regionCode: regionCode,
    profile: profile,
    isVerified: isVerified,
    createdAt: createdAt,
    averageRating: averageRating,
    followers: followers,
    following: following,
    isFollowing: isFollowing,
    showPersonalDetails: showPersonalDetails,
  );
}

class UserRatings {
  UserRatings({
    required this.id,
    required this.sellerId,
    required this.buyerId,
    required this.itemId,
    this.review,
    required this.ratings,
    this.createdAt,
    required this.buyer,
  });

  UserRatings.fromJson(Json json)
    : id = json['id'] as int,
      sellerId = json['seller_id'] as int,
      buyerId = json['buyer_id'] as int,
      itemId = json['item_id'] as int,
      review = json['review'] as String?,
      createdAt = DateTime.tryParse(
        json['created_at'] as String? ?? '',
      )?.toLocal(),
      buyer = JsonHelper.parseObject(json['buyer'] as Json, Buyer.fromJson),
      ratings = json['ratings'] as num;

  final int id;
  final int sellerId;
  final int buyerId;
  final int itemId;
  final String? review;
  final num ratings;
  final DateTime? createdAt;
  final Buyer buyer;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['seller_id'] = this.sellerId;
    data['buyer_id'] = this.buyerId;
    data['item_id'] = this.itemId;
    data['review'] = this.review;
    data['ratings'] = this.ratings;
    data['created_at'] = this.createdAt;
    data['buyer'] = this.buyer.toJson();
    return data;
  }
}

class Buyer {
  Buyer.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      profile = json['profile'] as String?;

  final int id;
  final String name;
  final String? profile;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}
