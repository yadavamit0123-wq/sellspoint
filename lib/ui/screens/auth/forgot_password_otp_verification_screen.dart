import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
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

class ForgotPasswordOtpVerificationScreen extends StatefulWidget {
  const ForgotPasswordOtpVerificationScreen({
    required this.phoneNumber,
    required this.phoneCode,
    super.key,
  });

  final String phoneNumber;
  /// Dial code with leading `+`, e.g. `+91`.
  final String phoneCode;

  static Route route(RouteSettings settings) {
    final args = settings.arguments;
    if (args is! Map) {
      return BlurredRouter(builder: (_) => const Scaffold());
    }
    return BlurredRouter(
      builder: (_) => ForgotPasswordOtpVerificationScreen(
        phoneNumber: args['phoneNumber']?.toString() ?? '',
        phoneCode: args['phoneCode']?.toString() ?? '',
      ),
    );
  }

  @override
  State<ForgotPasswordOtpVerificationScreen> createState() =>
      _ForgotPasswordOtpVerificationScreenState();
}

class _ForgotPasswordOtpVerificationScreenState
    extends State<ForgotPasswordOtpVerificationScreen> {
  String? otp;
  bool _isResendEnabled = false;
  int _resendSeconds = 60;
  Timer? _resendTimer;
  late PhoneLoginPayload _phoneLoginPayload;
  late final String _countryCodeDigits;

  @override
  void initState() {
    super.initState();
    _countryCodeDigits =
        widget.phoneCode.startsWith('+') ? widget.phoneCode.substring(1) : widget.phoneCode;
    _phoneLoginPayload =
        PhoneLoginPayload(widget.phoneNumber, _countryCodeDigits);

    context.read<AuthenticationCubit>().init();
    context.read<AuthenticationCubit>().listen((MLoginState state) {
      if (state is MOtpSendInProgress && mounted) {
        Widgets.showLoader(context);
      }
      if (state is MVerificationPending && mounted) {
        Widgets.hideLoder(context);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationCubit>().setData(
            payload: _phoneLoginPayload,
            type: AuthenticationType.phone,
          );
      context.read<AuthenticationCubit>().verify();
      _startResendTimer();
    });
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _resendTimer?.cancel();
    super.dispose();
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

  void _verifyOtp() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginInProgress) {
                Widgets.showLoader(context);
              }
              if (state is LoginSuccess) {
                Widgets.hideLoder(context);
                final jwt = HiveUtils.getJWT();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.resetPassword,
                  (route) => route.settings.name == Routes.forgotPassword,
                  arguments: {
                    'phoneNumber': widget.phoneNumber,
                    'phoneCode': widget.phoneCode,
                    'jwtToken': jwt,
                  },
                );
              }
              if (state is LoginFailure) {
                Widgets.hideLoder(context);
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage.toString(),
                );
              }
            },
          ),
          BlocListener<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationInProcess) {
                Widgets.showLoader(context);
              }
              if (state is AuthenticationSuccess) {
                Widgets.hideLoder(context);
                final payload = state.payload as PhoneLoginPayload;
                context.read<LoginCubit>().login(
                      phoneNumber: payload.phoneNumber,
                      firebaseUserId: state.credential.user!.uid,
                      type: state.type.name,
                      credential: state.credential,
                      countryCode: widget.phoneCode,
                    );
              }
              if (state is AuthenticationFail) {
                Widgets.hideLoder(context);
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 66),
              CustomText(
                'verifyPhoneNumber'.translate(context),
                fontSize: context.font.extraLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CustomText(
                    '${widget.phoneCode} ${widget.phoneNumber}',
                    fontSize: context.font.large,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: CustomText(
                      'change'.translate(context),
                      color: context.color.territoryColor,
                      showUnderline: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 8),
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
              const SizedBox(height: 19),
              UiUtils.buildButton(
                context,
                onPressed: _verifyOtp,
                buttonTitle: 'verify'.translate(context),
                radius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
