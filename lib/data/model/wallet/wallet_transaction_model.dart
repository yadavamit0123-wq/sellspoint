class WalletTransactionModel {
  bool? error;
  String? message;
  int? code;
  List<WalletTransactionData>? data;

  WalletTransactionModel({
    this.error,
    this.message,
    this.code,
    this.data,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      error: json['error'],
      message: json['message'],
      code: json['code'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => WalletTransactionData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'code': code,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class WalletTransactionData {
  int? id;
  int? userId;
  String? title;
  num? amount;
  String? type;
  String? status;
  String? createdAt;
  String? updatedAt;

  WalletTransactionData({
    this.id,
    this.userId,
    this.title,
    this.amount,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });


  factory WalletTransactionData.fromJson(Map<String, dynamic> json) {
    return WalletTransactionData(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      amount: json['amount'],
      type: json['type'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  bool get tranType => type == 'credit' ? true : false;
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
