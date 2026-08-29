import 'package:eClassify/data/model/user/user_model.dart';
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
    String code, {
    String? ownReferralCode,
  }) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      await HiveUtils.clearPendingReferralCode();
      return const ReferralValidationResult(valid: true);
    }

    final ownCode = ownReferralCode?.trim();
    if (ownCode != null &&
        ownCode.isNotEmpty &&
        trimmed.toLowerCase() == ownCode.toLowerCase()) {
      return const ReferralValidationResult(
        valid: false,
        message: 'You cannot use your own referral code',
      );
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

  static Future<ReferralApplyResult> applyPendingReferralAndRefresh(
    String userId,
  ) async {
    final result = await applyPendingReferral(userId);
    if (result == ReferralApplyResult.success) {
      await refreshUserWallet();
    }
    return result;
  }

  /// Fetches latest profile (wallet, by_reffer_id) from server into Hive.
  static Future<UserModel?> refreshUserWallet() async {
    try {
      final response = await Api.get(url: Api.userProfile);
      if (response['error'] != false) return null;
      final data = response['data'];
      if (data is! Map) return null;
      HiveUtils.setUserData(data);
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  static Future<ReferralApplyResult> applyPendingReferral(String userId) async {
    final code = HiveUtils.getPendingReferralCode();
    if (code == null || code.isEmpty) {
      return ReferralApplyResult.noPendingCode;
    }

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
        return ReferralApplyResult.success;
      }
    } catch (_) {
      // Caller shows error when result is failed
    }
    return ReferralApplyResult.failed;
  }
}

enum ReferralApplyResult { noPendingCode, success, failed }

class ReferralValidationResult {
  const ReferralValidationResult({required this.valid, this.message});

  final bool valid;
  final String? message;
}
