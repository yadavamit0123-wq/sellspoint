class JobApplication {
  JobApplication({
    required this.id,
    this.itemId,
    this.userId,
    this.fullName,
    this.email,
    this.mobile,
    this.resume,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.recruiterId,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      itemId: json['item_id'] as int?,
      userId: json['user_id'] as int?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      resume: json['resume'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      recruiterId: json['recruiter_id'] as int?,
    );
  }

  final int id;
  final int? itemId;
  final int? userId;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? resume;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final int? recruiterId;
}
