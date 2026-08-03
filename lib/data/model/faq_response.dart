class FaqResponse {
  final bool error;
  final String message;
  final List<FaqData> data;
  final int code;

  FaqResponse({
    required this.error,
    required this.message,
    required this.data,
    required this.code,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      error: json['error'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => FaqData.fromJson(item as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'code': code,
    };
  }
}

class FaqData {
  final int id;
  final String quetions; // spelling same as API
  final String answers;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  FaqData({
    required this.id,
    required this.quetions,
    required this.answers,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaqData.fromJson(Map<String, dynamic> json) {
    return FaqData(
      id: json['id'] as int,
      quetions: json['quetions'] as String,
      answers: json['answers'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quetions': quetions,
      'answers': answers,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
