import 'dart:developer';
import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/login_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/screens/auth/widgets/forgot_password_bottom_sheet.dart';
import 'package:eClassify/ui/screens/auth/widgets/terms_acceptance_dialog.dart';
import 'package:eClassify/ui/screens/auth/widgets/terms_and_conditions_widget.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/phone_input.dart';
import 'package:eClassify/ui/screens/widgets/skip_button_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/login/lib/payloads.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:eClassify/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  final String? email;

  const LoginScreen({super.key, this.email});

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static MaterialPageRoute route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => LoginScreen(email: args?['email'] as String?),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.email,
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phonePasswordController =
      TextEditingController();
  final PhoneInputController _phoneInputController = PhoneInputController();
  String phoneCode = AppConfig.defaultPhoneCode;
  bool isResendEnabled = false;
  bool isLoginButtonDisabled = true;
  late final ValueNotifier<bool> isLoginWithMobile = ValueNotifier(
    widget.email == null || widget.email!.isEmpty,
  );
  bool sendMailClicked = false;
  final _formKey = GlobalKey<FormState>();

  bool isObscure = true;
  bool isPhonePasswordObscure = true;
  late PhoneLoginPayload phoneLoginPayload;
  bool isBack = false;

  bool get isPhoneAuthEnabled => Constant.systemSettings.isPhoneAuthEnabled;

  bool get isEmailAuthEnabled => Constant.systemSettings.isEmailAuthEnabled;

  bool get isGoogleAuthEnabled => Constant.systemSettings.isGoogleAuthEnabled;

  bool get isAppleAuthEnabled => Constant.systemSettings.isAppleAuthEnabled;

  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().init();

    if (isPhoneAuthEnabled && isEmailAuthEnabled) {
      if (_emailController.text.isNotEmpty) {
        isLoginWithMobile.value = false;
      } else {
        isLoginWithMobile.value = true;
      }
    } else {
      isLoginWithMobile.value = isPhoneAuthEnabled;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _phonePasswordController.dispose();
    _emailController.dispose();
    isLoginWithMobile.dispose();
    super.dispose();
  }

  /// Handles Google/Apple authentication success.
  ///
  /// For existing users, continues directly to login.
  /// For new users, shows the [TermsAcceptanceDialog]. If accepted, proceeds with
  /// login; if declined, discards the Firebase auth session cleanly.
  Future<void> _handleSocialLogin(AuthenticationSuccess state) async {
    final firebaseUserId = state.credential.user!.uid;

    if (!Constant.requireTermsConsent) {
      context.read<LoginCubit>().login(
        firebaseUserId: firebaseUserId,
        type: state.type.name,
        credential: state.credential,
        countryCode: null,
      );
      return;
    }

    final isExistingUser = await context
        .read<AuthenticationCubit>()
        .checkSocialUserExists(firebaseId: firebaseUserId);

    if (!mounted) return;

    if (isExistingUser) {
      // Existing user – proceed directly
      context.read<LoginCubit>().login(
        firebaseUserId: firebaseUserId,
        type: state.type.name,
        credential: state.credential,
        countryCode: null,
      );
    } else {
      // New user – require terms acceptance before registering
      final accepted = await TermsAcceptanceDialog.show(context) ?? false;

      if (!mounted) return;

      if (accepted) {
        context.read<LoginCubit>().login(
          firebaseUserId: firebaseUserId,
          type: state.type.name,
          credential: state.credential,
          countryCode: null,
        );
      } else {
        // User declined – discard Firebase session
        await context.read<AuthenticationCubit>().signOut();
      }
    }
  }

  void _onTapContinue() async {
    bool isPhoneValid = true;
    if (isLoginWithMobile.value) {
      isPhoneValid = await _phoneInputController.validateAsync();
    }

    bool isFormValid = _formKey.currentState!.validate();

    if (isFormValid && isPhoneValid) {
      if (isLoginWithMobile.value) {
        // Phone login requires password (no OTP flow)
        if (_phonePasswordController.text.trim().isEmpty) {
          HelperUtils.showSnackBarMessage(
            context,
            'Password is required for phone login',
          );
          return;
        }

        // Direct login with phone + password
        phoneLoginPayload = PhoneLoginPayload(
          _phoneInputController.phoneNumber,
          _phoneInputController.phoneCode,
          _phoneInputController.regionCode,
          password: _phonePasswordController.text.trim(),
        );

        context.read<AuthenticationCubit>().setData(
          payload: phoneLoginPayload,
          type: AuthenticationType.phone,
        );
        context.read<AuthenticationCubit>().authenticateWithPhonePassword();

        setState(() {});
      } else {
        sendMailClicked = true;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: isBack,
        onPopInvokedWithResult: (didPop, result) {
          if (sendMailClicked) {
            setState(() {
              sendMailClicked = false;
            });
          } else {
            setState(() {
              isBack = true;
            });
            return;
          }
          setState(() {
            isBack = false;
          });
          return;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: context.color.backgroundColor,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SkipButtonWidget(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.main,
                      (route) => false,
                      arguments: {"from": "login", "isSkipped": true},
                    );
                  },
                ),
              ),
            ],
          ),
          backgroundColor: context.color.backgroundColor,
          bottomNavigationBar: !sendMailClicked
              ? const TermsAndConditionsWidget(showCheckbox: false)
              : SizedBox.shrink(),
          body: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginInProgress) {
                LoadingOverlay.show(context);
              }
              if (state is LoginSuccess) {
                LoadingOverlay.hide();
                context.read<UserDetailsCubit>().fill(
                  HiveUtils.getUserDetails(),
                );
                if (state.isProfileCompleted) {
                  HiveUtils.setUserIsAuthenticated(true);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.main,
                    (route) => false,
                    arguments: {'from': 'login'},
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    Routes.completeProfile,
                    arguments: {"from": "login", "popToCurrent": false},
                  );
                }
              }

              if (state is LoginFailure) {
                log('${state.errorMessage}');
                LoadingOverlay.hide();
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage.toString(),
                );
              }
            },
            child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
              listener: (context, state) {
                if (state is AuthenticationSuccess) {
                  LoadingOverlay.hide();

                  if (state.type == AuthenticationType.email) {
                    if (state.credential.user!.emailVerified) {
                      context.read<LoginCubit>().login(
                        firebaseUserId: state.credential.user!.uid,
                        type: state.type.name,
                        credential: state.credential,
                        countryCode: null,
                      );
                    }
                  } else if (state.type == AuthenticationType.phone) {
                    final payload = state.payload as PhoneLoginPayload;

                    // Check if it's password-based login
                    if (state.credential is Map &&
                        state.credential['type'] == 'phone_password') {
                      context.read<LoginCubit>().loginWithPhonePassword(
                        phoneNumber: payload.phoneNumber,
                        password: payload.password!,
                        phoneCode: "+${payload.phoneCode}",
                        regionCode: payload.regionCode,
                      );
                    }
                    // Dead Code
                    // Login screen will always receive the phone_password and hence
                    // the above condition will always be true
                    else if (Constant.systemSettings.otpProvider == 'twilio') {
                      context.read<LoginCubit>().loginWithTwilio(
                        phoneNumber: payload.phoneNumber,
                        firebaseUserId:
                            state.credential['id']?.toString() ?? '',
                        type: state.type.name,
                        credential: state.credential,
                        countryCode: "+${payload.phoneCode}",
                        regionCode: payload.regionCode,
                      );
                    } else {
                      context.read<LoginCubit>().login(
                        phoneNumber: payload.phoneNumber,
                        firebaseUserId: state.credential.user!.uid,
                        type: state.type.name,
                        credential: state.credential,
                        countryCode: "+${payload.phoneCode}",
                        regionCode: payload.regionCode,
                      );
                    }
                  } else {
                    // Google / Apple: check if user is new before proceeding
                    _handleSocialLogin(state);
                  }
                }

                if (state is AuthenticationFail) {
                  log('fail ${state.errorKey}');
                  HelperUtils.showSnackBarMessage(
                    context,
                    state.errorKey.translate(context),
                  );
                  LoadingOverlay.hide();
                }

                if (state is AuthenticationInProcess) {
                  LoadingOverlay.show(context);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: Form(key: _formKey, child: buildLoginWidget()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget mobileLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'loginWithPhoneNumber'.translate(context),
          fontSize: context.font.large,
          color: context.color.textColorDark,
        ),
        const SizedBox(height: 24),
        PhoneInput(
          controller: _phoneInputController,
          hintKey: 'mobileNoLbl',
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          hintText: "${"password".translate(context)}",
          controller: _phonePasswordController,
          validator: CustomTextFieldValidator.password,
          obscureText: isPhonePasswordObscure,
          suffix: IconButton(
            onPressed: () {
              isPhonePasswordObscure = !isPhonePasswordObscure;
              setState(() {});
            },
            icon: Icon(
              !isPhonePasswordObscure ? AppIcons.eye : AppIcons.eyeSlash,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: MaterialButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () {
              // Validate phone before showing bottom sheet
              String? prefilledPhone;
              String? prefilledRegionCode;
              if (_phoneInputController.phoneNumber.isNotEmpty) {
                prefilledPhone = _phoneInputController.phoneNumber;
                prefilledRegionCode = _phoneInputController.regionCode;
              }

              UiUtils.showBottomSheet(
                context,
                child: ForgotPasswordBottomSheet(
                  isEmailMode: false,
                  prefilledPhone: prefilledPhone,
                  prefilledRegionCode: prefilledRegionCode,
                ),
              );
            },
            child: CustomText(
              "${"forgotPassword".translate(context)}?",
              color: context.color.textLightColor,
              fontSize: context.font.normal,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: Listenable.merge([
            _phonePasswordController,
            _phoneInputController,
          ]),
          builder: (context, child) {
            final isPhoneNumberValid =
                _phoneInputController.value.text.isNotEmpty;
            final isPasswordValid =
                Validator.validatePassword(
                  _phonePasswordController.text,
                  context: context,
                ) ==
                null;

            final isDisabled = !(isPhoneNumberValid && isPasswordValid);

            return UiUtils.buildButton(
              context,
              onPressed: _onTapContinue,
              buttonTitle: 'signIn'.translate(context),
              radius: 10,
              disabledColor: const Color.fromARGB(255, 104, 102, 106),
              disabled: isDisabled,
            );
          },
        ),
      ],
    );
  }

  Widget emailLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'loginWithEmail'.translate(context),
          fontSize: context.font.large,
          color: context.color.textColorDark,
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: _emailController,
          fillColor: context.color.secondaryColor,
          borderColor: context.color.textLightColor.withValues(alpha: 0.2),
          keyboard: TextInputType.emailAddress,
          validator: CustomTextFieldValidator.email,
          hintText: "emailAddress".translate(context),
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          hintText: "${"password".translate(context)}",
          controller: _passwordController,
          validator: CustomTextFieldValidator.password,
          obscureText: isObscure,
          suffix: IconButton(
            onPressed: () {
              isObscure = !isObscure;
              setState(() {});
            },
            icon: Icon(!isObscure ? AppIcons.eye : AppIcons.eyeSlash),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: MaterialButton(
            onPressed: () {
              // Validate email before showing bottom sheet
              String? prefilledEmail;
              if (_emailController.text.isNotEmpty &&
                  Validator.validateEmail(
                        email: _emailController.text,
                        context: context,
                      ) ==
                      null) {
                prefilledEmail = _emailController.text;
              }

              UiUtils.showBottomSheet(
                context,
                child: ForgotPasswordBottomSheet(
                  isEmailMode: true,
                  prefilledEmail: prefilledEmail,
                ),
              );
            },
            child: CustomText(
              "${"forgotPassword".translate(context)}?",
              color: context.color.textLightColor,
              fontSize: context.font.normal,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: Listenable.merge([_emailController, _passwordController]),
          builder: (context, child) {
            final isEmailValid =
                Validator.validateEmail(
                  context: context,
                  email: _emailController.text,
                ) ==
                null;

            final isPasswordValid =
                Validator.validatePassword(
                  _passwordController.text,
                  context: context,
                ) ==
                null;

            final isDisabled = !(isEmailValid && isPasswordValid);

            return UiUtils.buildButton(
              context,
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? true)) {
                  return;
                }
                context.read<AuthenticationCubit>().setData(
                  payload: EmailLoginPayload(
                    email: _emailController.text,
                    password: _passwordController.text,
                    type: EmailLoginType.login,
                  ),
                  type: AuthenticationType.email,
                );
                context.read<AuthenticationCubit>().authenticate();
              },
              buttonTitle: 'signIn'.translate(context),
              radius: 10,
              disabled: isDisabled,
              disabledColor: const Color.fromARGB(255, 104, 102, 106),
            );
          },
        ),
      ],
    );
  }

  Widget buildLoginWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            "welcomeback".translate(context),
            fontSize: context.font.extraLarge,
            color: context.color.textDefaultColor,
          ),
          const SizedBox(height: 8),
          if (isPhoneAuthEnabled || isEmailAuthEnabled)
            ValueListenableBuilder(
              valueListenable: isLoginWithMobile,
              builder: (context, isMobileLogin, child) {
                return isMobileLogin ? mobileLogin() : emailLogin();
              },
            ),
          const SizedBox(height: 20),
          if (isPhoneAuthEnabled || isEmailAuthEnabled)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  "dontHaveAcc".translate(context),
                  color: context.color.textColorDark.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Routes.signup);
                  },
                  child: CustomText(
                    "signUp".translate(context),
                    color: context.color.territoryColor,
                    showUnderline: true,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          ...googleAndAppleLogin(),
        ],
      ),
    );
  }

  List<Widget> googleAndAppleLogin() {
    return [
      if (isPhoneAuthEnabled || isEmailAuthEnabled)
        if (isGoogleAuthEnabled || (isAppleAuthEnabled && Platform.isIOS))
          Align(
            alignment: Alignment.center,
            child: CustomText(
              "orSignInWith".translate(context),
              color: context.color.textDefaultColor,
            ),
          ),
      const SizedBox(height: 20),
      if (isGoogleAuthEnabled) ...[
        UiUtils.buildButton(
          context,
          prefixWidget: Padding(
            padding: EdgeInsetsDirectional.only(end: 10.0),
            child: CustomImage(
              src: AppAssets.social.google,
              size: Size.square(22),
            ),
          ),
          showElevation: false,
          buttonColor: context.color.secondaryColor,
          textColor: context.color.textDefaultColor,
          onPressed: () {
            context.read<AuthenticationCubit>().setData(
              payload: GoogleLoginPayload(),
              type: AuthenticationType.google,
            );
            context.read<AuthenticationCubit>().authenticate();
          },
          radius: 8,
          height: 46,
          buttonTitle: "continueWithGoogle".translate(context),
        ),
        const SizedBox(height: 12),
      ],
      if (isAppleAuthEnabled && Platform.isIOS) ...[
        UiUtils.buildButton(
          context,
          prefixWidget: Padding(
            padding: EdgeInsetsDirectional.only(end: 10.0),
            child: CustomImage(
              src: AppAssets.social.apple,
              size: Size.square(22),
            ),
          ),
          showElevation: false,
          buttonColor: context.color.secondaryColor,
          textColor: context.color.textDefaultColor,
          onPressed: () {
            context.read<AuthenticationCubit>().setData(
              payload: AppleLoginPayload(),
              type: AuthenticationType.apple,
            );
            context.read<AuthenticationCubit>().authenticate();
          },
          height: 46,
          radius: 8,
          buttonTitle: "continueWithApple".translate(context),
        ),
        const SizedBox(height: 12),
      ],
      if (isPhoneAuthEnabled && isEmailAuthEnabled)
        ValueListenableBuilder(
          valueListenable: isLoginWithMobile,
          builder: (context, isMobileField, child) {
            return UiUtils.buildButton(
              context,
              onPressed: () {
                isLoginWithMobile.value = !isLoginWithMobile.value;
                _phoneInputController.clear();
                _emailController.clear();
                _phonePasswordController.clear();
                _passwordController.clear();
              },
              prefixWidget: Padding(
                padding: EdgeInsetsDirectional.only(end: 10.0),
                child: Icon(
                  isMobileField ? AppIcons.envelopeSimple : AppIcons.phoneFill,
                ),
              ),
              showElevation: false,
              buttonColor: context.color.secondaryColor,
              textColor: context.color.textDefaultColor,
              height: 46,
              radius: 8,
              buttonTitle:
                  (isMobileField ? 'continueWithEmail' : 'continueWithMobile')
                      .translate(context),
            );
          },
        ),
    ];
  }
}
