import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/item/job_application/apply_job_application_cubit.dart';
import 'package:eClassify/data/cubits/item/job_application/fetch_job_application_cubit.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/item/job_application.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobApplicationFormScreen extends StatefulWidget {
  const JobApplicationFormScreen({super.key, required this.item});

  final ItemModel item;

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (_) => BlocProvider(
        create: (_) => ApplyJobApplicationCubit(),
        child: JobApplicationFormScreen(
          item: settings.arguments as ItemModel,
        ),
      ),
    );
  }

  @override
  State<JobApplicationFormScreen> createState() =>
      _JobApplicationFormScreenState();
}

class _JobApplicationFormScreenState extends State<JobApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  File? _resumeFile;

  @override
  void initState() {
    super.initState();
    final user = HiveUtils.getUserDetails();
    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _mobileController.text = user.mobile ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _resumeFile = File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplyJobApplicationCubit, ApplyJobApplicationState>(
      listener: (context, state) {
        if (state is ApplyJobApplicationSuccess) {
          final data = state.data;
          if (data is Map<String, dynamic>) {
            try {
              context.read<FetchJobApplicationCubit>().addJobApplication(
                    JobApplication.fromJson(data),
                  );
            } catch (_) {}
          }
          HelperUtils.showSnackBarMessage(context, state.successMessage);
          Navigator.pop(context);
        }
        if (state is ApplyJobApplicationFail) {
          HelperUtils.showSnackBarMessage(context, state.error.toString());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: 'jobApplicationForm'.translate(context),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(context, 'fullName'),
                  CustomTextFormField(
                    controller: _nameController,
                    validator: CustomTextFieldValidator.nullCheck,
                    hintText: 'provideFullNameHere'.translate(context),
                    fillColor: context.color.secondaryColor,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel(context, 'mobileNumberLbl'),
                  CustomTextFormField(
                    controller: _mobileController,
                    validator: CustomTextFieldValidator.phoneNumber,
                    keyboard: TextInputType.phone,
                    hintText: 'mobileNumberLbl'.translate(context),
                    fillColor: context.color.secondaryColor,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel(context, 'emailAddress'),
                  CustomTextFormField(
                    controller: _emailController,
                    validator: CustomTextFieldValidator.email,
                    keyboard: TextInputType.emailAddress,
                    hintText: 'emailAddressHere'.translate(context),
                    fillColor: context.color.secondaryColor,
                  ),
                  const SizedBox(height: 14),
                  _fieldLabel(context, 'attachResumeIfAny'),
                  DottedBorder(
                    color: context.color.textLightColor,
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: InkWell(
                      onTap: _pickResume,
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: Center(
                          child: CustomText(
                            _resumeFile != null
                                ? _resumeFile!.path.split('/').last
                                : 'uploadFile'.translate(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state is ApplyJobApplicationInProgress)
                    Center(child: UiUtils.progress())
                  else
                    UiUtils.buildButton(
                      context,
                      width: context.screenWidth,
                      height: 44,
                      radius: 8,
                      onPressed: _submit,
                      buttonTitle: 'applyNow'.translate(context),
                      buttonColor: context.color.territoryColor,
                      textColor: context.color.secondaryColor,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fieldLabel(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomText(
        key.translate(context),
        color: context.color.textDefaultColor,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final user = HiveUtils.getUserDetails();
    final data = <String, dynamic>{
      Api.itemId: widget.item.id,
      'full_name': _nameController.text.trim(),
      Api.email: _emailController.text.trim(),
      Api.mobile: _mobileController.text.trim(),
      Api.phoneCode: user.countryCode?.replaceAll('+', '') ??
          AppConfig.defaultPhoneCode.replaceAll('+', ''),
      Api.regionCode: AppConfig.defaultCountryCode,
    };
    context.read<ApplyJobApplicationCubit>().applyJobApplication(
          data,
          _resumeFile,
        );
  }
}
