import 'package:eClassify/data/repositories/referral_repository.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';

void showReferralApplyFeedback(
  BuildContext context,
  ReferralApplyResult? result,
) {
  switch (result) {
    case ReferralApplyResult.success:
      HelperUtils.showSnackBarMessage(
        context,
        'Referral code applied! ₹10 signup bonus is in your wallet.',
      );
    case ReferralApplyResult.failed:
      HelperUtils.showSnackBarMessage(
        context,
        'Referral code could not be applied. Please try again from profile.',
        type: MessageType.error,
      );
    case ReferralApplyResult.noPendingCode:
    case null:
      break;
  }
}
