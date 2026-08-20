import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/item/job_application/apply_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/job_application.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/phone_input.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/file_picker_utility.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

class JobApplicationForm extends StatefulWidget {
  final ItemModel item;

  const JobApplicationForm({Key? key, required this.item}) : super(key: key);

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) =>
          JobApplicationForm(item: routeSettings.arguments as ItemModel),
    );
  }
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  //Text Controllers
  final TextEditingController nameController = TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController(text: '');
  final PhoneInputController phoneController = PhoneInputController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? pickedFile;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    final userDetails = HiveUtils.getUserDetails();
    nameController.text = userDetails.name ?? '';
    emailController.text = userDetails.email ?? '';
    phoneController.phoneNumber = userDetails.mobile ?? '';
    phoneController.phoneCode = userDetails.countryCode?.replaceAll('+', '');
    phoneController.regionCode =
        userDetails.regionCode ?? AppConfig.defaultCountryCode;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplyJobApplicationCubit(),
      child: BlocConsumer<ApplyJobApplicationCubit, ApplyJobApplicationState>(
        listener: (context, state) {
          if (state is ApplyJobApplicationSuccess) {
            dynamic data = state.data;
            context.read<FetchJobApplicationCubit>().addJobApplication(
              JobApplication(
                itemId: data['item_id'] is String
                    ? int.parse(data['item_id'])
                    : data['item_id'],
                userId: data['user_id'],
                recruiterId: data['recruiter_id'],
                fullName: data['full_name'],
                email: data['email'],
                mobile: data['mobile'],
                resume: data['resume'],
                createdAt: data['created_at'],
                id: data['id'],
              ),
            );
            HelperUtils.showSnackBarMessage(context, state.successMessage);
            Navigator.of(context).pop();
          }
          if (state is ApplyJobApplicationFail) {
            HelperUtils.showSnackBarMessage(context, state.error);
          }
        },
        builder: (context, state) {
          return PopScope(
            canPop: isBack,
            onPopInvokedWithResult: (didPop, result) {
              setState(() {
                isBack = state is! ApplyJobApplicationInProgress;
              });
            },
            child: Scaffold(
              appBar: UiUtils.buildAppBar(
                context,
                showBackButton: true,
                title: "jobApplicationForm".translate(context),
              ),
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildTextField(
                        context,
                        title: "fullName",
                        hintText: "provideFullNameHere".translate(context),
                        controller: nameController,
                        validator: CustomTextFieldValidator.nullCheck,
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        "mobileNumberLbl".translate(context),
                        color: context.color.textDefaultColor,
                      ),
                      SizedBox(height: 10),
                      PhoneInput(controller: phoneController),
                      buildTextField(
                        context,
                        title: "emailAddress",
                        hintText: "emailAddressHere".translate(context),
                        controller: emailController,
                        validator: CustomTextFieldValidator.email,
                      ),
                      _JobAttachment(
                        pickedFile: pickedFile,
                        onFilePicked: (file) {
                          setState(() {
                            pickedFile = file;
                          });
                        },
                      ),
                      SizedBox(height: 25),
                      state is ApplyJobApplicationInProgress
                          ? Center(
                              child: CircularProgressIndicator(
                                color: context.color.territoryColor,
                                strokeWidth: 2,
                              ),
                            )
                          : UiUtils.buildButton(
                              context,
                              onPressed: () async {
                                if (state is ApplyJobApplicationInProgress)
                                  return;
                                bool isPhoneValid = await phoneController.validateAsync();
                                bool isFormValid = _formKey.currentState!.validate();
                                if (isFormValid && isPhoneValid) {
                                  Map<String, dynamic> data = {};
                                  data['item_id'] = widget.item.id;
                                  data['full_name'] = nameController.text;
                                  data['email'] = emailController.text;
                                  data['mobile'] = phoneController.phoneNumber;
                                  data['phone_code'] =
                                      phoneController.phoneCode;
                                  data[Api.regionCode] =
                                      phoneController.regionCode;

                                  context
                                      .read<ApplyJobApplicationCubit>()
                                      .applyJobApplication(data, pickedFile);
                                }
                              },
                              buttonTitle: "enquireNow".translate(context),
                              radius: 8,
                              fontSize: 12,
                              width: context.screenWidth,
                              textColor: context.color.buttonColor,
                              buttonColor: context.color.territoryColor,
                              height: 40,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    CustomTextFieldValidator? validator,
    bool? readOnly,
    required String hintText,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CustomText(
          title.translate(context),
          color: context.color.textDefaultColor,
        ),
        CustomTextFormField(
          controller: controller,
          isReadOnly: readOnly,
          validator: validator,
          hintText: hintText,
          fillColor: context.color.secondaryColor,
        ),
      ],
    );
  }
}

class _JobAttachment extends StatelessWidget {
  final File? pickedFile;
  final Function(File?) onFilePicked;

  const _JobAttachment({
    Key? key,
    required this.pickedFile,
    required this.onFilePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        CustomText(
          "attachResumeIfAny".translate(context),
          color: context.color.textDefaultColor,
        ),
        SizedBox(height: 10),
        DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: context.color.textLightColor,
            radius: const Radius.circular(12),
          ),
          child: GestureDetector(
            onTap: () async {
              List<File>? result = await FilePickerUtility.pick(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx'],
              );

              if (result != null && result.isNotEmpty) {
                onFilePicked(result.first);
              }
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: AlignmentDirectional.center,
              height: 48,
              child: CustomText(
                "uploadFile".translate(context),
                color: context.color.textDefaultColor,
                fontSize: context.font.large,
              ),
            ),
          ),
        ),
        if (pickedFile != null)
          TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(
                context.color.territoryColor.withValues(alpha: 0.2),
              ),
            ),
            onPressed: () => OpenFile.open(pickedFile!.path),
            child: Text(pickedFile!.path.split('/').last.toCapitalized()),
          ),
      ],
    );
  }
}
