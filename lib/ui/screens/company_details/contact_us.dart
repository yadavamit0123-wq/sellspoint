import 'package:eClassify/data/cubits/system/user_query_cubit.dart';
import 'package:eClassify/data/model/company_details.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => UserQueryCubit(),
        child: const ContactUs(),
      ),
    );
  }
}

class _ContactUsState extends State<ContactUs> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyDetails = Constant.systemSettings.companyDetails;
    final contactUsContent = companyDetails.pages.getPageFromType(
      CompanyPage.contactUs,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(CompanyPage.contactUs.name.translate(context)),
      ),
      body: SingleChildScrollView(
        padding: Constant.appContentPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (contactUsContent.isNotNullAndNotEmpty)
                HtmlWidget(contactUsContent!),
              16.vGap,
              Text(
                'contactUsTitle'.translate(context),
                style: context.titleLarge,
              ),
              8.vGap,
              Text(
                'contactUsSubTitle'.translate(context),
                style: context.bodyMedium,
              ),
              8.vGap,
              _ContactChips(
                contact: companyDetails.companyContactNumbers,
                email: companyDetails.companyEmail,
              ),
              16.vGap,
              if (HiveUtils.isUserAuthenticated()) ...[
                CustomTextFormField(
                  controller: _subjectController,
                  hintText: 'subject'.translate(context),
                  validator: CustomTextFieldValidator.nullCheck,
                ),
                12.vGap,
                CustomTextFormField(
                  controller: _messageController,
                  hintText: 'message'.translate(context),
                  minLine: 5,
                  maxLine: 100,
                  validator: CustomTextFieldValidator.nullCheck,
                ),
                16.vGap,
                BlocConsumer<UserQueryCubit, UserQueryState>(
                  listener: (context, state) {
                    if (state is UserQuerySuccess) {
                      HelperUtils.showSnackBarMessage(
                        context,
                        'success'.translate(context),
                        type: MessageType.success,
                      );
                      _subjectController.clear();
                      _messageController.clear();
                    } else if (state is UserQueryFailure) {
                      HelperUtils.showSnackBarMessage(
                        context,
                        state.message,
                        type: MessageType.error,
                      );
                      _subjectController.clear();
                      _messageController.clear();
                    }
                  },
                  builder: (context, state) {
                    return FilledButton(
                      style: FilledButton.styleFrom(
                        fixedSize: Size.fromHeight(40),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final user = HiveUtils.isUserAuthenticated()
                              ? HiveUtils.getUserDetails()
                              : null;
                          context.read<UserQueryCubit>().sendUserQuery(
                            name: user?.name ?? 'Guest',
                            email: user?.email ?? '',
                            subject: _subjectController.text,
                            message: _messageController.text,
                          );
                        }
                      },
                      child: state is UserQueryLoading
                          ? LoadingIndicator(
                              color: context.colorScheme.onPrimary,
                            )
                          : Text('submit'.translate(context)),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactChips extends StatelessWidget {
  const _ContactChips({required this.contact, required this.email});

  final List<String> contact;
  final String email;

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card.filled(
        color: context.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            spacing: 8,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(icon, color: context.colorScheme.primary),
                ),
              ),
              Text(label, style: context.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _chip(
            context,
            AppIcons.phone,
            'call'.translate(context),
            onTap: () {
              if (contact.length == 1) {
                launchUrlString('tel:${contact.first}');
              } else {
                UiUtils.showBottomSheet(
                  context,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: contact
                          .map(
                            (c) => ListTile(
                              title: Text(c),
                              onTap: () => launchUrlString('tel:$c'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: _chip(
            context,
            AppIcons.envelopeSimple,
            'email'.translate(context),
            onTap: () {
              launchUrlString('mailto:$email');
            },
          ),
        ),
      ],
    );
  }
}
