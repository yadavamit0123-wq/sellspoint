import 'package:eClassify/data/cubits/profile_setting_cubit.dart';
import 'package:eClassify/data/helper/widgets.dart';
import 'package:eClassify/data/model/company_page.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

/// HTML company / legal page loaded via [ProfileSettingCubit].
class CompanyPageScreen extends StatefulWidget {
  const CompanyPageScreen({required this.page, super.key});

  final CompanyPage page;

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments;
    if (args is! CompanyPage) {
      return BlurredRouter(builder: (_) => const Scaffold());
    }
    return BlurredRouter(
      builder: (_) => CompanyPageScreen(page: args),
    );
  }

  @override
  State<CompanyPageScreen> createState() => _CompanyPageScreenState();
}

class _CompanyPageScreenState extends State<CompanyPageScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      context.read<ProfileSettingCubit>().fetchProfileSetting(
            context,
            widget.page.apiType,
            forceRefresh: true,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.page.titleKey.translate(context);
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(context, title: title, showBackButton: true),
      body: BlocBuilder<ProfileSettingCubit, ProfileSettingState>(
        builder: (context, state) {
          if (state is ProfileSettingFetchProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.territoryColor,
              ),
            );
          }
          if (state is ProfileSettingFetchSuccess) {
            return _htmlContent(state, context);
          }
          if (state is ProfileSettingFetchFailure) {
            return Widgets.noDataFound(state.errmsg);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _htmlContent(ProfileSettingFetchSuccess state, BuildContext context) {
    if (state.data.trim().isEmpty) {
      return Widgets.noDataFound('nodatafound'.translate(context));
    }
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: HtmlWidget(
        state.data,
        onTapUrl: (url) =>
            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        customStylesBuilder: (element) {
          if (element.localName == 'p') {
            return {'color': context.color.textColorDark.toString()};
          }
          return null;
        },
      ),
    );
  }
}
