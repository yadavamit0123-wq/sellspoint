import 'package:country_picker/country_picker.dart';
import 'package:eClassify/app/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/repositories/auth_repository.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static BlurredRouter route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const ForgotPasswordScreen(),
    );
  }

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  final _formKey = GlobalKey<FormState>();

  TabController? _tabController;
  String? _countryCode;

  bool get _phoneResetEnabled =>
      AppConfig.enablePhoneForgotPassword &&
      Constant.mobileAuthentication == '1';

  @override
  void initState() {
    super.initState();
    _countryCode = Constant.defaultCountryCode;
    if (_phoneResetEnabled) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _showCountryCode() {
    showCountryPicker(
      context: context,
      showWorldWide: false,
      showPhoneCode: true,
      countryListTheme:
          CountryListThemeData(borderRadius: BorderRadius.circular(11)),
      onSelect: (Country value) {
        setState(() => _countryCode = value.phoneCode);
      },
    );
  }

  Future<void> _submitEmailReset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    try {
      Widgets.showLoader(context);
      await _auth.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      Widgets.hideLoder(context);
      if (!mounted) return;
      HelperUtils.showSnackBarMessage(
        context,
        'resetPasswordSuccess'.translate(context),
        type: MessageType.success,
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Routes.login, (route) => false);
    } on FirebaseAuthException catch (e) {
      Widgets.hideLoder(context);
      if (!mounted) return;
      if (e.code == 'user-not-found') {
        HelperUtils.showSnackBarMessage(
          context,
          'userNotFound'.translate(context),
          type: MessageType.error,
        );
      } else {
        HelperUtils.showSnackBarMessage(context, e.message ?? e.code,
            type: MessageType.error);
      }
    }
  }

  Future<void> _submitPhoneReset() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final mobile = _mobileController.text.trim();
    final code = _countryCode ?? Constant.defaultCountryCode;

    try {
      Widgets.showLoader(context);
      final exists = await _authRepository.checkUserExists(
        phoneNumber: mobile,
        countryCode: code,
        isFromForgotPassword: true,
      );
      Widgets.hideLoder(context);
      if (!mounted) return;

      if (!exists) {
        HelperUtils.showSnackBarMessage(
          context,
          'userDoesNotExist'.translate(context),
          type: MessageType.error,
        );
        return;
      }

      Navigator.pushNamed(
        context,
        Routes.forgotPasswordOtpVerification,
        arguments: {
          'phoneNumber': mobile,
          'phoneCode': '+$code',
        },
      );
    } catch (e) {
      Widgets.hideLoder(context);
      if (mounted) {
        HelperUtils.showSnackBarMessage(context, e.toString(),
            type: MessageType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.main,
                        arguments: {'from': 'login', 'isSkipped': true},
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    color: context.color.forthColor.withValues(alpha: 0.102),
                    elevation: 0,
                    height: 28,
                    minWidth: 64,
                    child: CustomText(
                      'skip'.translate(context),
                      color: context.color.forthColor,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                CustomText(
                  'forgotPassword'.translate(context),
                  fontSize: context.font.extraLarge,
                ),
                const SizedBox(height: 12),
                if (_phoneResetEnabled && _tabController != null) ...[
                  TabBar(
                    controller: _tabController,
                    labelColor: context.color.territoryColor,
                    unselectedLabelColor: context.color.textLightColor,
                    tabs: [
                      Tab(text: 'emailAddress'.translate(context)),
                      Tab(text: 'mobileNumberLbl'.translate(context)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _emailTab(context),
                        _phoneTab(context),
                      ],
                    ),
                  ),
                ] else ...[
                  CustomText(
                    'forgotSubHeadingTxt'.translate(context),
                    fontSize: context.font.small,
                    color: context.color.textLightColor,
                  ),
                  const SizedBox(height: 24),
                  _emailTab(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_phoneResetEnabled) ...[
          CustomText(
            'forgotHeadingTxt'.translate(context),
            fontSize: context.font.large,
          ),
          const SizedBox(height: 8),
          CustomText(
            'forgotSubHeadingTxt'.translate(context),
            fontSize: context.font.small,
            color: context.color.textLightColor,
          ),
          const SizedBox(height: 24),
        ],
        CustomTextFormField(
          controller: _emailController,
          keyboard: TextInputType.emailAddress,
          hintText: 'emailAddress'.translate(context),
          validator: CustomTextFieldValidator.email,
        ),
        const SizedBox(height: 25),
        ListenableBuilder(
          listenable: _emailController,
          builder: (context, child) {
            return UiUtils.buildButton(
              context,
              disabled: _emailController.text.isEmpty,
              disabledColor: const Color.fromARGB(255, 104, 102, 106),
              buttonTitle: 'submitBtnLbl'.translate(context),
              radius: 8,
              onPressed: _submitEmailReset,
            );
          },
        ),
      ],
    );
  }

  Widget _phoneTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'enterPhoneNumberToResetPassword'.translate(context),
          fontSize: context.font.small,
          color: context.color.textLightColor,
        ),
        const SizedBox(height: 24),
        CustomTextFormField(
          controller: _mobileController,
          keyboard: TextInputType.phone,
          validator: CustomTextFieldValidator.phoneNumber,
          fixedPrefix: SizedBox(
            width: 55,
            child: GestureDetector(
              onTap: _showCountryCode,
              child: Center(
                child: CustomText(
                  '+${_countryCode ?? Constant.defaultCountryCode}',
                  fontSize: context.font.large,
                ),
              ),
            ),
          ),
          hintText: 'mobileNumberLbl'.translate(context),
        ),
        const SizedBox(height: 25),
        ListenableBuilder(
          listenable: _mobileController,
          builder: (context, child) {
            return UiUtils.buildButton(
              context,
              disabled: _mobileController.text.isEmpty,
              disabledColor: const Color.fromARGB(255, 104, 102, 106),
              buttonTitle: 'continue'.translate(context),
              radius: 8,
              onPressed: _submitPhoneReset,
            );
          },
        ),
      ],
    );
  }
}
