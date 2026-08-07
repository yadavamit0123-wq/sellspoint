import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/delete_user_cubit.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/report/update_report_items_list_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/login/lib/login_status.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// Phone OTP re-auth before Firebase + backend account deletion (2.14 flow).
class DeleteAccountVerificationScreen extends StatefulWidget {
  const DeleteAccountVerificationScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(builder: (_) => const DeleteAccountVerificationScreen());
  }

  @override
  State<DeleteAccountVerificationScreen> createState() =>
      _DeleteAccountVerificationScreenState();
}

class _DeleteAccountVerificationScreenState
    extends State<DeleteAccountVerificationScreen> {
  String? otp;
  bool _otpSent = false;
  bool _isResendEnabled = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  late PhoneLoginPayload _phoneLoginPayload;

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().init();
    context.read<AuthenticationCubit>().listen((MLoginState state) {
      if (state is MOtpSendInProgress && mounted) {
        Widgets.showLoader(context);
      }
      if (state is MVerificationPending && mounted) {
        Widgets.hideLoder(context);
        setState(() => _otpSent = true);
        HelperUtils.showSnackBarMessage(
          context,
          'optsentsuccessflly'.translate(context),
        );
      }
      if (state is MFail && mounted) {
        Widgets.hideLoder(context);
        HelperUtils.showSnackBarMessage(context, state.error.toString());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    final user = HiveUtils.getUserDetails();
    final mobile = user.mobile?.trim();
    if (mobile == null || mobile.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'phoneNumberNotFound'.translate(context),
      );
      Navigator.pop(context);
      return;
    }

    var dialCode = user.countryCode?.replaceAll('+', '').trim();
    if (dialCode == null || dialCode.isEmpty) {
      dialCode = HiveUtils.getCountryCode() ?? Constant.defaultCountryCode;
    }

    _phoneLoginPayload = PhoneLoginPayload(mobile, dialCode);
    context.read<AuthenticationCubit>().setData(
          payload: _phoneLoginPayload,
          type: AuthenticationType.phone,
        );
    context.read<AuthenticationCubit>().verify();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendSeconds = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
        if (mounted) setState(() => _isResendEnabled = true);
      } else if (mounted) {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _verifyAndDelete() {
    if (otp == null || otp!.trim().length < 6) {
      HelperUtils.showSnackBarMessage(
        context,
        'pleaseEnterSixDigits'.translate(context),
      );
      return;
    }
    _phoneLoginPayload.setOTP(otp!.trim());
    context.read<AuthenticationCubit>().authenticate();
  }

  Future<void> _clearSessionAndGoLogin(String? message) async {
    if (message != null && message.isNotEmpty && mounted) {
      HelperUtils.showSnackBarMessage(context, message);
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    HiveUtils.clear();
    Constant.favoriteItemList.clear();
    if (mounted) {
      context.read<UserDetailsCubit>().clear();
      context.read<FavoriteCubit>().resetState();
      context.read<UpdatedReportItemCubit>().clearItem();
      context.read<GetBuyerChatListCubit>().resetState();
      context.read<BlockedUsersListCubit>().resetState();
      await HiveUtils.logoutUser(context, onLogout: () {});
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }

  String _displayPhone() {
    final user = HiveUtils.getUserDetails();
    final code = user.countryCode ?? '+${HiveUtils.getCountryCode()}';
    return '$code ${user.mobile ?? ''}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationCubit, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationInProcess) {
              Widgets.showLoader(context);
            }
            if (state is AuthenticationSuccess) {
              context.read<AuthenticationCubit>().deleteUser();
            }
            if (state is AuthenticationUserDeleted) {
              Widgets.hideLoder(context);
              context.read<DeleteUserCubit>().deleteUser();
            }
            if (state is AuthenticationUserDeletionFailure) {
              Widgets.hideLoder(context);
              if (state.error is FirebaseAuthException &&
                  (state.error as FirebaseAuthException).code ==
                      'requires-recent-login') {
                HelperUtils.showSnackBarMessage(
                  context,
                  'loginRequiredWarning'.translate(context),
                );
              } else {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.error.toString(),
                );
              }
            }
          },
        ),
        BlocListener<DeleteUserCubit, DeleteUserState>(
          listener: (context, state) async {
            if (state is DeleteUserFetchInProgress) {
              Widgets.showLoader(context);
            }
            if (state is DeleteUserFetchSuccess) {
              Widgets.hideLoder(context);
              final msg = state.deleteUser is Map
                  ? state.deleteUser['message']?.toString()
                  : null;
              await _clearSessionAndGoLogin(
                msg ?? 'userDeletedSuccessfully'.translate(context),
              );
            }
            if (state is DeleteUserFetchFailure) {
              Widgets.hideLoder(context);
              HelperUtils.showSnackBarMessage(context, state.errorMessage);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: true,
          title: 'verifyAccount'.translate(context),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'deleteAccountVerification'.translate(context),
                fontSize: context.font.extraLarge,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              CustomText(
                'weNeedToVerifyIdentity'.translate(context),
                color: context.color.textLightColor,
              ),
              const SizedBox(height: 8),
              CustomText(
                _displayPhone(),
                fontSize: context.font.large,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 32),
              if (!_otpSent)
                Center(child: UiUtils.progress())
              else ...[
                CustomText('enterOTP'.translate(context)),
                const SizedBox(height: 16),
                Center(
                  child: PinFieldAutoFill(
                    decoration: UnderlineDecoration(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: context.color.textColorDark,
                      ),
                      colorBuilder:
                          FixedColorBuilder(context.color.territoryColor),
                    ),
                    currentCode: otp,
                    codeLength: 6,
                    onCodeChanged: (code) => otp = code,
                    onCodeSubmitted: (code) => otp = code,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: _isResendEnabled
                      ? TextButton(
                          onPressed: () {
                            context.read<AuthenticationCubit>().setData(
                                  payload: _phoneLoginPayload,
                                  type: AuthenticationType.phone,
                                );
                            context.read<AuthenticationCubit>().verify();
                            _startResendTimer();
                          },
                          child: CustomText(
                            'resendOTP'.translate(context),
                            color: context.color.territoryColor,
                          ),
                        )
                      : CustomText(
                          '${'resendOtpIn'.translate(context)} 0:${_resendSeconds.toString().padLeft(2, '0')}',
                          color: context.color.textLightColor,
                        ),
                ),
                const SizedBox(height: 24),
                UiUtils.buildButton(
                  context,
                  buttonTitle: 'verifyAndDelete'.translate(context),
                  radius: 8,
                  onPressed: _verifyAndDelete,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
