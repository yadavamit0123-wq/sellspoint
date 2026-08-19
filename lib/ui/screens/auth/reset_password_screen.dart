import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/reset_password_cubit.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String phoneCode;
  final String regionCode;
  final String jwtToken;

  const ResetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.phoneCode,
    required this.regionCode,
    required this.jwtToken,
  });

  static MaterialPageRoute route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return ResetPasswordScreen(
          phoneNumber: args['phoneNumber'] as String,
          phoneCode: args['phoneCode'] as String,
          regionCode: args['regionCode'] as String,
          jwtToken: args['jwtToken'] as String,
        );
      },
    );
  }

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isNewPasswordObscure = true;
  bool isConfirmPasswordObscure = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<ResetPasswordCubit>().resetPassword(
      phoneNumber: widget.phoneNumber,
      countryCode: widget.phoneCode,
      newPassword: _newPasswordController.text.trim(),
      jwtToken: widget.jwtToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordInProgress) {
              LoadingOverlay.show(context);
            }

            if (state is ResetPasswordSuccess) {
              LoadingOverlay.hide();

              HelperUtils.showSnackBarMessage(
                context,
                "passwordResetSuccessfully".translate(context),
                type: MessageType.success,
              );

              HiveUtils.setUserIsAuthenticated(true);

              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.main,
                (route) => false,
                arguments: {'from': 'login'},
              );
            }

            if (state is ResetPasswordFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
            }
          },
          builder: (context, resetPasswordState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: MediaQuery.of(context).padding.top + 40,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "resetPassword".translate(context),
                      fontSize: context.font.extraLarge,
                      fontWeight: FontWeight.w600,
                      color: context.color.textDefaultColor,
                    ),
                    const SizedBox(height: 12),
                    CustomText(
                      "createNewPasswordForYourAccount".translate(context),
                      fontSize: context.font.normal,
                      color: context.color.textLightColor,
                    ),
                    const SizedBox(height: 40),
                    CustomTextFormField(
                      hintText: "newPassword".translate(context),
                      controller: _newPasswordController,
                      validatorFunction: _validatePassword,
                      obscureText: isNewPasswordObscure,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            isNewPasswordObscure = !isNewPasswordObscure;
                          });
                        },
                        icon: Icon(
                          !isNewPasswordObscure
                              ? AppIcons.eye
                              : AppIcons.eyeSlash,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      hintText: "confirmPassword".translate(context),
                      controller: _confirmPasswordController,
                      validatorFunction: _validateConfirmPassword,
                      obscureText: isConfirmPasswordObscure,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordObscure =
                                !isConfirmPasswordObscure;
                          });
                        },
                        icon: Icon(
                          !isConfirmPasswordObscure
                              ? AppIcons.eye
                              : AppIcons.eyeSlash,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    UiUtils.buildButton(
                      context,
                      buttonTitle: "resetPassword".translate(context),
                      radius: 8,
                      onPressed: _resetPassword,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
