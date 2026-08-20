
import 'package:eClassify/utils/json_helper.dart';

enum VerificationRequestStatus {
  initial('initial'),
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  resubmitted('resubmited');

  const VerificationRequestStatus(this.value);
  final String value;

  static VerificationRequestStatus parse(String value) =>
      VerificationRequestStatus.values.firstWhere(
        (element) => element.value == value,
        orElse: () => VerificationRequestStatus.initial,
      );
}

class VerificationRequest {
  final int id;
  final VerificationRequestStatus? status;
  final String? rejectionReason;
  final List<VerificationFieldValues>? verificationFieldValues;

  VerificationRequest.fromJson(Json json)
    : id = json['id'] as int,
      status = VerificationRequestStatus.parse(json['status'] as String? ?? ''),
      rejectionReason = json['rejection_reason'] as String?,
      verificationFieldValues = JsonHelper.parseList(
        json['verification_field_values'] as List?,
        VerificationFieldValues.fromJson,
      );
}

class VerificationFieldValues {
  final int id;
  final int verificationFieldId;
  final int verificationRequestId;
  final int? languageId;
  final String? value;

  VerificationFieldValues.fromJson(Json json)
    : id = json['id'] as int,
      verificationFieldId = json['verification_field_id'] as int,
      verificationRequestId = json['verification_request_id'] as int,
      languageId = json['language_id'] as int?,
      value = json['value'] as String?;
}
