import 'dart:developer';

import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/login_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin extends LoginSystem {
  GoogleSignIn? _googleSignIn;

  /// Web client ID from Firebase (required for Google Sign-In + Firebase Auth on Android).
  static const _googleWebClientId =
      '229203066228-ltbl68i0ng3rva3glrhcc6gvheta5kip.apps.googleusercontent.com';

  @override
  void init() {
    _googleSignIn = GoogleSignIn(
      scopes: ['profile', 'email'],
      serverClientId: _googleWebClientId,
    );
  }

  @override
  Future<UserCredential?> login() async {
    try {
      emit(MProgress());
      GoogleSignInAccount? googleSignIn = await _googleSignIn?.signIn();
      if (googleSignIn == null) {
        emit(
          MFail(
            "loginCancelledByUser".translate(
              Constant.navigatorKey.currentContext!,
            ),
          ),
        );
        return null;
      }

      GoogleSignInAuthentication? googleAuth =
          await googleSignIn.authentication;

      AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await firebaseAuth.signInWithCredential(
        authCredential,
      );
      emit(MSuccess());

      return userCredential;
    }
    on Exception catch (e, st) {
      log('$e $st');
      rethrow;
    }
  }

  void signOut() async {
    if (await _googleSignIn?.isSignedIn() ?? false) {
      _googleSignIn?.signOut();
      _googleSignIn?.disconnect();
    }
  }

  @override
  void onEvent(MLoginState state) {}
}
