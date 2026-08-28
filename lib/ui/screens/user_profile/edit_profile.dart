import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/auth/authentication_cubit.dart';
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/phone_input.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/color_mappers/svg_color_mapper.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/image_picker.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  final String from;
  final bool? navigateToHome;
  final bool? popToCurrent;

  const UserProfileScreen({
    super.key,
    required this.from,
    this.navigateToHome,
    this.popToCurrent,
  });

  @override
  State<UserProfileScreen> createState() => UserProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return MaterialPageRoute(
      builder: (_) => UserProfileScreen(
        from: arguments['from'] as String,
        popToCurrent: arguments['popToCurrent'] as bool?,
        navigateToHome: arguments['navigateToHome'] as bool?,
      ),
    );
  }
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final PhoneInputController phoneController = PhoneInputController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  File? fileUserimg;
  bool isNotificationsEnabled = true;
  bool isPersonalDetailShow = true;
  PickImage profileImagePicker = PickImage();
  bool isFromLogin = false;

  @override
  void initState() {
    super.initState();
    isFromLogin = widget.from == 'login';

    nameController.text = (HiveUtils.getUserDetails().name) ?? "";
    emailController.text = HiveUtils.getUserDetails().email ?? "";
    addressController.text = HiveUtils.getUserDetails().address ?? "";

    if (isFromLogin) {
      isNotificationsEnabled = true;
      isPersonalDetailShow = true;
    } else {
      isNotificationsEnabled = HiveUtils.getUserDetails().notification == 1
          ? true
          : false;
      isPersonalDetailShow =
          HiveUtils.getUserDetails().isPersonalDetailShow == 1 ? true : false;
    }

    final user = context.read<UserDetailsCubit>().state.user;
    phoneController.phoneNumber = user?.mobile;
    phoneController.phoneCode = user?.countryCode;
    phoneController.regionCode = user?.regionCode;

    final details = HiveUtils.getUserDetails();
    referralCodeController.text =
        details.referId ?? details.referralCode ?? '';

    profileImagePicker.listener((files) {
      if (files != null && files.isNotEmpty) {
        setState(() {
          fileUserimg = files.first; // Assign picked image to fileUserimg
        });
      }
    });
  }

  @override
  void dispose() {
    profileImagePicker.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isFromLogin,
          title: CustomText('editprofile'.translate(context)),
        ),
        body: BlocListener<UserProfileCubit, UserProfileState>(
          listener: (context, state) {
            log('$state');
            if (state is UserProfileLoading) {
              LoadingOverlay.show(context);
            }

            if (state is UserProfileSuccess) {
              LoadingOverlay.hide();
              context.read<UserDetailsCubit>().copy(state.user);
              if (state.message != null) {
                HelperUtils.showSnackBarMessage(context, state.message!);
              }
              if (isFromLogin) {
                Future.delayed(Duration.zero, () {
                  if (widget.popToCurrent ?? false) {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.main,
                      (route) => false,
                      arguments: {"from": "profile_screen"},
                    );
                  }
                });
              } else {
                Navigator.pop(context);
              }
            }

            if (state is UserProfileFailure) {
              LoadingOverlay.hide();
              final msg = switch (state.error) {
                DioException() => 'noInternetErrorMsg'.translate(context),
                ApiException() => state.error.toString(),
                _ => 'defaultErrorMsg',
              };
              HelperUtils.showSnackBarMessage(
                context,
                msg,
                type: MessageType.error,
              );
            }
          },
          child: Padding(
            padding: Constant.appContentPadding,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: buildProfilePicture(),
                    ),
                    buildTextField(
                      context,
                      title: "fullName",
                      controller: nameController,
                      validator: CustomTextFieldValidator.nullCheck,
                    ),
                    buildTextField(
                      context,
                      readOnly: [
                        AuthenticationType.email.name,
                        AuthenticationType.google.name,
                        AuthenticationType.apple.name,
                      ].contains(HiveUtils.getUserDetails().type),
                      title: "emailAddress",
                      controller: emailController,
                      validator: CustomTextFieldValidator.email,
                    ),
                    Row(
                      spacing: 2,
                      children: [
                        CustomText('phoneNumber'.translate(context)),
                        CustomText('*', color: Colors.red),
                      ],
                    ),
                    PhoneInput(
                      controller: phoneController,
                      hintKey: 'mobileNoLbl',
                      readOnly:
                          HiveUtils.getUserDetails().type ==
                          AuthenticationType.phone.name,
                    ),
                    buildTextField(
                      context,
                      title: "addressLbl",
                      controller: addressController,
                      maxline: 5,
                      textInputAction: TextInputAction.newline,
                    ),
                    buildTextField(
                      context,
                      title: "referralCode",
                      controller: referralCodeController,
                      readOnly: (HiveUtils.getUserDetails().byReferId ?? '')
                          .isNotEmpty,
                    ),
                    CustomText("notification".translate(context)),
                    buildEnableDisableSwitch(isNotificationsEnabled, (cgvalue) {
                      isNotificationsEnabled = cgvalue;
                      setState(() {});
                    }),
                    CustomText("showContactInfo".translate(context)),
                    buildEnableDisableSwitch(isPersonalDetailShow, (cgvalue) {
                      isPersonalDetailShow = cgvalue;
                      setState(() {});
                    }),
                    updateProfileBtnWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEnableDisableSwitch(bool value, Function(bool) onChangeFunction) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: context.color.secondaryColor,
      ),
      height: 60,
      width: double.infinity,
      padding: const EdgeInsetsDirectional.only(start: 16.0),
      child: Row(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            (value ? "enabled" : "disabled").translate(context),
            fontSize: context.font.large,
            color: context.color.textDefaultColor,
          ),
          CupertinoSwitch(
            activeTrackColor: context.color.territoryColor,
            value: value,
            onChanged: onChangeFunction,
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    CustomTextFieldValidator? validator,
    bool? readOnly,
    int? maxline,
    TextInputAction? textInputAction,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 2,
          children: [
            CustomText(
              title.translate(context),
              color: context.color.textDefaultColor,
            ),
            if (validator != null) CustomText('*', color: Colors.red),
          ],
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          // formaters: [FilteringTextInputFormatter.deny(RegExp(","))],
          fillColor: context.color.secondaryColor,
          action: textInputAction,
          maxLine: maxline,
        ),
      ],
    );
  }

  Widget getProfileImage() {
    if (fileUserimg != null) {
      return Image.file(fileUserimg!, fit: BoxFit.cover);
    } else {
      if (isFromLogin) {
        if (HiveUtils.getUserDetails().profile != null &&
            HiveUtils.getUserDetails().profile!.trim().isNotEmpty) {
          return CustomImage(src: HiveUtils.getUserDetails().profile!);
        }

        return CustomImage(
          src: AppAssets.profile.defaultPerson,
          svgColorMapper: SvgColorMapper(),
          fit: BoxFit.none,
        );
      } else if ((HiveUtils.getUserDetails().profile ?? "").trim().isEmpty) {
        return CustomImage(
          src: AppAssets.profile.defaultPerson,
          svgColorMapper: SvgColorMapper(),
          fit: BoxFit.none,
        );
      } else {
        return CustomImage(src: HiveUtils.getUserDetails().profile!);
      }
    }
  }

  Widget buildProfilePicture() {
    return Stack(
      children: [
        Container(
          height: 124,
          width: 124,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.color.territoryColor, width: 2),
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.color.territoryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            width: 106,
            height: 106,
            child: getProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: InkWell(
            onTap: showPicker,
            child: Container(
              height: 37,
              width: 37,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.color.buttonColor,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
                color: context.color.territoryColor,
              ),
              child: Icon(
                AppIcons.pencilSimpleLine,
                size: 20,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> validateData() async {
    bool isPhoneValid = await phoneController.validateAsync();
    bool isFormValid = _formKey.currentState!.validate();
    if (isFormValid && isPhoneValid) {
      if (isFromLogin) {
        HiveUtils.setUserIsAuthenticated(true);
      }
      if (context.read<UserProfileCubit>().state is UserProfileLoading) {
        return;
      }
      context.read<UserProfileCubit>().updateUserProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        profileImagePath: fileUserimg?.path,
        address: addressController.text,
        mobile: phoneController.phoneNumber,
        notification: isNotificationsEnabled == true ? "1" : "0",
        phoneCode: phoneController.phoneCode,
        regionCode: phoneController.regionCode,
        personalDetail: isPersonalDetailShow == true ? 1 : 0,
        referralCode: referralCodeController.text.trim(),
      );
    }
  }

  void showPicker() {
    UiUtils.imagePickerBottomSheet(
      context,
      isRemovalWidget: fileUserimg != null && isFromLogin,
      callback: (bool isRemoved, ImageSource? source) async {
        if (isRemoved) {
          setState(() {
            fileUserimg = null;
          });
        } else if (source != null) {
          await profileImagePicker.pick(
            context: context,
            source: source,
            pickMultiple: false,
          );
        }
      },
    );
  }

  Widget updateProfileBtnWidget() {
    return UiUtils.buildButton(
      context,
      outerPadding: EdgeInsetsDirectional.only(top: 15),
      onPressed: validateData,
      height: 48,
      buttonTitle: "updateProfile".translate(context),
    );
  }
}
