import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/reset_password_cubit.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.phoneNumber,
    required this.phoneCode,
    required this.jwtToken,
    super.key,
  });

  final String phoneNumber;
  final String phoneCode;
  final String jwtToken;

  static Route route(RouteSettings settings) {
    final args = settings.arguments;
    if (args is! Map) {
      return BlurredRouter(builder: (_) => const Scaffold());
    }
    return BlurredRouter(
      builder: (_) => BlocProvider(
        create: (_) => ResetPasswordCubit(),
        child: ResetPasswordScreen(
          phoneNumber: args['phoneNumber']?.toString() ?? '',
          phoneCode: args['phoneCode']?.toString() ?? '',
          jwtToken: args['jwtToken']?.toString() ?? '',
        ),
      ),
    );
  }

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
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
        appBar: UiUtils.buildAppBar(
          context,
          showBackButton: false,
          title: 'resetPassword'.translate(context),
        ),
        body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
          listener: (context, state) {
            if (state is ResetPasswordSuccess) {
              HelperUtils.showSnackBarMessage(
                context,
                'passwordResetSuccessfully'.translate(context),
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
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: MessageType.error,
              );
            }
          },
          builder: (context, state) {
            final loading = state is ResetPasswordInProgress;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'createNewPasswordForYourAccount'.translate(context),
                      fontSize: context.font.normal,
                      color: context.color.textLightColor,
                    ),
                    const SizedBox(height: 32),
                    CustomTextFormField(
                      controller: _newPasswordController,
                      hintText: 'newPassword'.translate(context),
                      obscureText: _obscureNew,
                      validator: CustomTextFieldValidator.password,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _confirmPasswordController,
                      hintText: 'confirmPassword'.translate(context),
                      obscureText: _obscureConfirm,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'confirmPasswordRequired'.translate(context);
                        }
                        if (v != _newPasswordController.text) {
                          return 'passwordsDoNotMatch'.translate(context);
                        }
                        return null;
                      },
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 32),
                    UiUtils.buildButton(
                      context,
                      buttonTitle: 'resetPassword'.translate(context),
                      radius: 8,
                      disabled: loading,
                      onPressed: _submit,
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
