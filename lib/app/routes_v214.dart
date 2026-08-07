import 'package:eClassify/utils/log.dart';
import 'package:flutter/material.dart';

/// Route names from eClassify 2.14 — handlers added as screens migrate.
abstract final class RoutesV214 {
  static const forgotPasswordOtpVerification =
      'forgotPasswordOtpVerification';
  static const resetPassword = 'resetPassword';
  static const deleteAccountVerification = 'deleteAccountVerification';
  static const companyPage = '/companyPage';
  static const helpAndSupportScreen = '/helpAndSupport';
  static const legalInformationScreen = '/legalInformation';
  static const categoryBrowsing = '/categoryBrowsing';
  static const adPostingScreen = '/adPostingScreen';
  static const adPostingSuccessScreen = '/adPostingSuccessScreen';
  static const videoAdEditor = '/videoAdEditor';
  static const videoAdsScreen = '/videoAdsScreen';
  static const locationScreen = '/locationScreen';
  /// Registered when 2.14 map UI lands; hub uses legacy pickers at [Routes.locationScreen].
  static const locationMapPicker = '/locationMapPicker';
  static const jobApplicationForm = '/jobApplicationForm';
  static const jobApplicationList = '/jobApplicationList';
  static const followersScreen = '/followersScreen';
  static const subscriptionCategorySelectionScreen =
      '/subscriptionCategorySelectionScreen';
  static const subscriptionPackageScreen = '/subscriptionPackageScreen';
  static const activePlanScreen = '/activePlanScreen';
  static const sellerItemChatScreen = '/sellerItemChatScreen';
  static const chatScreen = '/chatScreen';
  static const transactionReceipt = '/transactionReceipt';

  /// Sells Point only — registered in [Routes], not in stock 2.14.
  static const myWalletScreen = '/myWalletScreen';
  static const referralProgramScreen = '/referralProgramScreen';
  static const statusStoriesViewer = '/statusStoriesViewer';
}
