// ignore_for_file: public_member_api_docs, sort_constructors_first

class UserModel {
  int? id;
  String? name;
  String? email;
  num? wallet;
  String? mobile;
  String? profile;
  String? address;
  String? createdAt;
  int? customerTotalPost;
  String? fcmId;
  String? emailVerifiedAt;
  String? firebaseId;
  int? isActive;
  bool? isProfileCompleted;
  String? type;
  int? isPersonalDetailShow;
  int? autoApproveItem;
  String? countryCode;
  int? notification;
  String? token;
  String? updatedAt;
  int? isVerified;
  String? referId;
  String? byReferId;

  UserModel(
      {this.address,
      this.createdAt,
      this.customerTotalPost,
      this.email,
      this.fcmId,
      this.firebaseId,
        this.countryCode,
        this.emailVerifiedAt,
      this.id,
      this.isActive,
      this.isProfileCompleted,
      this.type,
      this.mobile,
      this.name,
      this.notification,
      this.profile,
        this.autoApproveItem,
        this.wallet,
      this.token,
      this.updatedAt,
      this.isPersonalDetailShow,
      this.isVerified, this.referId, this.byReferId});

  UserModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    createdAt = json['created_at'];
    customerTotalPost = json['customertotalpost'] as int?;
    email = json['email'];
    fcmId = json['fcm_id'];
    countryCode = json['country_code'];
    emailVerifiedAt = json['email_verified_at'];

    wallet = json['wallet'];
    firebaseId = json['firebase_id'];
    id = json['id'];
    isActive = json['isActive'] as int?;
    isProfileCompleted = json['isProfileCompleted'];
    type = json['type'];
    mobile = json['mobile'];
    name = json['name'];
    autoApproveItem = json['auto_approve_item'];
    notification = (json['notification'] != null
        ? (json['notification'] is int)
            ? json['notification']
            : int.parse(json['notification'])
        : null);
    profile = json['profile'];
    token = json['token'];
    updatedAt = json['updated_at'];
    isVerified = json['is_verified'];
    referId = json['reffer_id'];
    byReferId = json['by_reffer_id'];
    isPersonalDetailShow = (json['show_personal_details'] != null
        ? (json['show_personal_details'] is int)
            ? json['show_personal_details']
            : int.parse(json['show_personal_details'])
        : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['created_at'] = createdAt;
    data['customertotalpost'] = customerTotalPost;
    data['email'] = email;
    data['auto_approve_item'] = autoApproveItem;
    data['fcm_id'] = fcmId;
    data['country_code'] = countryCode;
    data['firebase_id'] = firebaseId;
    data['id'] = id;
    data['wallet'] = wallet;
    data['isActive'] = isActive;
    data['email_verified_at'] = emailVerifiedAt;
    data['isProfileCompleted'] = isProfileCompleted;
    data['type'] = type;
    data['mobile'] = mobile;
    data['name'] = name;
    data['notification'] = notification;
    data['profile'] = profile;
    data['token'] = token;
    data['updated_at'] = updatedAt;
    data['show_personal_details'] = isPersonalDetailShow;
    data['is_verified'] = isVerified;
    data['reffer_id'] = referId;
    data['by_reffer_id'] = byReferId;
    return data;
  }

  @override
  String toString() {
    return 'UserModel(address: $address, createdAt: $createdAt, customertotalpost: $customerTotalPost, email: $email, fcmId: $fcmId, firebaseId: $firebaseId, id: $id, isActive: $isActive, isProfileCompleted: $isProfileCompleted, type: $type, mobile: $mobile, name: $name, profile: $profile, token: $token, updatedAt: $updatedAt,notification:$notification,isPersonalDetailShow:$isPersonalDetailShow,isVerified:$isVerified)';
  }
}

class BuyerModel {
  int? id;
  String? name;
  String? profile;

  BuyerModel({this.id, this.name, this.profile});

  BuyerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile'] = this.profile;
    return data;
  }
}
