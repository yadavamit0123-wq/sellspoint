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
