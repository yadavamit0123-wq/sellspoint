import 'package:eClassify/data/model/user_model.dart';

class ReferralHistoryModel {
  int? id;
  int? userId;
  int? fromUserId;
  int? level;
  num? amount;
  String? createdAt;
  String? updatedAt;
  UserModel? user;

  ReferralHistoryModel({
    this.id,
    this.userId,
    this.fromUserId,
    this.level,
    this.amount,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory ReferralHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryModel(
      id: json['id'],
      userId: json['user_id'],
      fromUserId: json['from_user_id'],
      level: json['level'],
      amount: json['amount'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'from_user_id': fromUserId,
      'level': level,
      'amount': amount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user?.toJson(),
    };
  }
}