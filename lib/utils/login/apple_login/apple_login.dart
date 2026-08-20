import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:eClassify/utils/login/lib/login_system.dart';

class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;

  @override
  void init() async {}

  Future<UserCredential?> login() async {
    try {
      emit(MProgress());

      final AuthorizationCredentialAppleID appleIdCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      oAuthProvider = OAuthProvider('apple.com');
      if (oAuthProvider != null) {
        credential = oAuthProvider!.credential(
          idToken: appleIdCredential.identityToken,
          accessToken: appleIdCredential.authorizationCode,
        );

        final UserCredential userCredential = await firebaseAuth
            .signInWithCredential(credential!);

        if (userCredential.additionalUserInfo!.isNewUser) {
          final givenName = appleIdCredential.givenName;
          final familyName = appleIdCredential.familyName;
          var userName = '$givenName $familyName'.trim();
          if (userName.isEmpty) {
            userName = 'user_${DateTime.now().toIso8601String()}';
          }
          await userCredential.user!.updateDisplayName(userName);
          await userCredential.user!.reload();
        }

        emit(MSuccess());

        return userCredential;
      }
      return null;
    } catch (e) {
      emit(MFail(e));
      throw e;
    }
  }

  @override
  void onEvent(MLoginState state) {
    print("Login state is $state");
  }
}
