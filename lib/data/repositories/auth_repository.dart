import 'dart:io';
import 'package:dio/dio.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/log.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static int? forceResendingToken;

  Future<Map<String, dynamic>> numberLoginWithApi(
      {String? phone,
      required String uid,
      required String type,
      String? fcmId,
      String? email,
      String? name,
      String? profile,
        // String? referralCode,
        String? countryCode}) async {
    Map<String, String> parameters = {
      if (phone != null) Api.mobile: phone,
      Api.firebaseId: uid,
      Api.type: type,
      Api.platformType: Platform.isAndroid ? "android" : "ios",
      if (fcmId != null) Api.fcmId: fcmId,
      if (email != null) Api.email: email,
      if (name != null) Api.name: name,
      if (countryCode != null) Api.countryCode: countryCode,
      // if (referralCode != null) Api.referredBy: referralCode ?? '',
      //if (profile != null) Api.profile: profile
    };

    Map<String, dynamic> response = await Api.post(
      url: Api.loginApi,
      parameter: parameters, /* useAuthToken: false*/
    );

    if(response['error'] == false){
      await applyReferCode(response['data']['id'].toString());
    }
    return {"token": response['token'], "data": response['data']};
  }


  Future<void> applyReferCode(String userId) async {
    var referCode = HiveUtils.getReferCode();

    if(referCode != null){
      Map<String, dynamic> response = await Api.post(
        parameter: {
          'user_id': userId,
          'reffer_code': referCode
        },
        url: '${Api.referralApplyApi}',
      );
      if(response['error'] == false){
        HiveUtils.deleteReferralCode();
      }
    }
  }

  Future<dynamic> deleteUser() async {
    Map<String, dynamic> response = await Api.delete(
      url: Api.deleteUserApi,
    );

    return response;
  }

  void loginEmailUser() async {}

  Future<void> sendOTP(
      {required String phoneNumber,
      required Function(String verificationId) onCodeSent,
      Function(dynamic e)? onError}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(
        seconds: Constant.otpTimeOutSecond,
      ),
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        onError?.call(ApiException(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        forceResendingToken = resendToken;
        onCodeSent.call(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
      forceResendingToken: forceResendingToken,
    );
  }

  Future<UserCredential> verifyOTP({
    required String otpVerificationId,
    required String otp,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: otpVerificationId, smsCode: otp);
    UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    return userCredential;
  }

  /// Whether a phone account exists (2.14 `user-exists`; optional on older admin).
  Future<bool> checkUserExists({
    required String phoneNumber,
    required String countryCode,
    bool isFromForgotPassword = false,
  }) async {
    try {
      final response = await Api.get(
        url: Api.userExistsApi,
        queryParameters: {
          Api.mobile: phoneNumber,
          Api.countryCode: countryCode,
          if (isFromForgotPassword) 'forgot_password': '1',
        },
      );
      final data = response['data'];
      if (data is Map && data['user_exists'] is bool) {
        return data['user_exists'] as bool;
      }
      return false;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String countryCode,
    required String newPassword,
    required String jwtToken,
  }) async {
    await Api.post(
      url: Api.resetPasswordApi,
      parameter: {
        'number': phoneNumber,
        Api.countryCode: countryCode,
        'new_password': newPassword,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $jwtToken'},
      ),
    );
  }
}

class MultiAuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> createUserWithEmail(
      {required String email, required String password}) async {
    try {
      UserCredential credentials =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credentials;
    } catch (e) {
      rethrow;
    }
  }
}
