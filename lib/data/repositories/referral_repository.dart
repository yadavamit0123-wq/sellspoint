import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/hive_utils.dart';

/// Sells Point referral API helpers (check + apply after signup).
class ReferralRepository {
  ReferralRepository._();

  static Future<Map<String, dynamic>> checkReferralCode(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw ApiException('Referral code is required');
    }
    return Api.get(url: '${Api.referralCheckApi}/$trimmed');
  }

  /// Validates optional referral code (old live app flow) and stores until signup completes.
  static Future<ReferralValidationResult> validateAndSavePendingCode(
    String code,
  ) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      await HiveUtils.clearPendingReferralCode();
      return const ReferralValidationResult(valid: true);
    }

    try {
      final response = await checkReferralCode(trimmed);
      if (response['error'] == true) {
        return ReferralValidationResult(
          valid: false,
          message: response['message']?.toString() ?? 'Invalid Referral Code',
        );
      }

      await HiveUtils.setPendingReferralCode(trimmed);
      return ReferralValidationResult(
        valid: true,
        message: response['message']?.toString(),
      );
    } on ApiException catch (e) {
      return ReferralValidationResult(valid: false, message: e.errorMessage);
    } catch (_) {
      return const ReferralValidationResult(
        valid: false,
        message: 'Invalid Referral Code',
      );
    }
  }

  static Future<void> applyPendingReferral(String userId) async {
    final code = HiveUtils.getPendingReferralCode();
    if (code == null || code.isEmpty) return;

    try {
      final response = await Api.post(
        url: Api.referralApplyApi,
        parameter: {
          'user_id': userId,
          'reffer_code': code,
        },
      );
      if (response['error'] == false) {
        HiveUtils.clearPendingReferralCode();
      }
    } catch (_) {
      // Non-fatal: user can apply from profile later
    }
  }
}

class ReferralValidationResult {
  const ReferralValidationResult({required this.valid, this.message});

  final bool valid;
  final String? message;
}
