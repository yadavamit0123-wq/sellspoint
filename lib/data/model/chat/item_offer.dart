import 'dart:math';

import 'package:eClassify/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
class ItemOffer {
  ItemOffer({
    required this.id,
    required this.name,
    required this.image,
    required this.unreadCount,
    this.offerUnreadCount = 0,
    required this.lastUpdatedAt,
    required this.users,
    this.totalUsers,
  });

  ItemOffer.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      image = json['image'] as String,
      unreadCount = json['unread_chat_count'] as int,
      offerUnreadCount = 0,
      lastUpdatedAt = DateTime.parse(json['last_offer_updated'] as String),
      users = JsonHelper.parseList(
        json['other_users'] as List?,
        ItemOfferUser.fromJson,
      ),
      totalUsers = json['total_other_users'] as int?;

  // Item Id
  final int id;
  final String name;
  final String image;
  final int unreadCount;
  final int offerUnreadCount;
  final DateTime lastUpdatedAt;
  final List<ItemOfferUser> users;
  final int? totalUsers;

  int get totalUnreadCount => unreadCount + offerUnreadCount;

  int get remainingUsers => (totalUsers ?? users.length) - min(4, users.length);

  ItemOffer copyWith({
    int? unreadCount,
    int? offerUnreadCount,
    DateTime? lastUpdatedAt,
    List<ItemOfferUser>? users,
    int? totalUsers,
  }) => ItemOffer(
    id: id,
    name: name,
    image: image,
    unreadCount: unreadCount ?? this.unreadCount,
    offerUnreadCount: offerUnreadCount ?? this.offerUnreadCount,
    lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    users: users ?? this.users,
    totalUsers: totalUsers ?? this.totalUsers,
  );

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is ItemOffer && other.id == id;

  static ItemOffer fromNotification(Map<String, dynamic> data) {
    return ItemOffer(
      id: int.parse(data['item_id'].toString()),
      name: data['item_name'] as String,
      image: data['item_image'] as String,
      unreadCount: 0,
      offerUnreadCount: 1,
      lastUpdatedAt: DateTime.now(),
      users: [
        ItemOfferUser(
          id: int.parse(data['user_id'].toString()),
          offerId: int.parse(data['item_offer_id'].toString()),
          name: data['user_name'] as String,
          profile: data['user_profile'] as String?,
        ),
      ],
    );
  }
}

@immutable
class ItemOfferUser {
  ItemOfferUser({
    required this.id,
    required this.offerId,
    required this.name,
    required this.profile,
  });

  ItemOfferUser.fromJson(Json json)
    : id = json['id'] as int,
      offerId = json['offer_id'] as int,
      name = json['name'] as String,
      profile = json['profile'] as String?;

  final int id;
  final int offerId;
  final String name;
  final String? profile;

  @override
  bool operator ==(Object other) => other is ItemOfferUser && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
