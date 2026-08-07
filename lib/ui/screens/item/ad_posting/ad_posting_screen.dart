import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/item/ad_posting/ad_posting_in_app_screen.dart';
import 'package:eClassify/ui/screens/item/ad_posting/ad_posting_progress_header.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// 2.14 post-ad entry — wizard shell routes into breadcrumb category browse.
class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  static Route route(RouteSettings routeSettings) {
    if (AppConfig.enableAdPostingInAppWizardV214) {
      return AdPostingInAppScreen.route(routeSettings);
    }
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return BlurredRouter(
      builder: (_) => AdPostingScreen(arguments: args),
    );
  }

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen> {
  static const _listingAdType = 'listing';

  final PageController _pageController = PageController();
  String _selectedAdType = _listingAdType;
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _wizardEnabled => AppConfig.enableAdPostingWizardV214;

  void _onContinue() {
    if (_wizardEnabled && _pageIndex == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }
    _openCategoryStep();
  }

  void _openCategoryStep() {
    final extra = widget.arguments ?? <String, dynamic>{};
    if (_wizardEnabled) {
      Navigator.pushReplacementNamed(
        context,
        Routes.categoryBrowsing,
        arguments: {
          ...extra,
          'leafDestination': 'adPosting',
        },
      );
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      Routes.selectCategoryScreen,
      arguments: extra,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: 'adListing'.translate(context),
        onBackPress: () {
          if (_wizardEnabled && _pageIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
            );
            return;
          }
          Navigator.of(context).pop();
        },
      ),
      body: Column(
        children: [
          if (AdPostingProgressHeader.isEnabled)
            AdPostingProgressHeader(currentStep: 1),
          Expanded(
            child: _wizardEnabled ? _buildWizardBody(context) : _buildIntroBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardBody(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) => setState(() => _pageIndex = index),
      children: [
        _IntroStep(padding: _bodyPadding(context), child: _introContent(context)),
        _IntroStep(
          padding: _bodyPadding(context),
          child: _adTypeStep(context),
        ),
      ],
    );
  }

  Widget _buildIntroBody(BuildContext context) {
    return _IntroStep(
      padding: _bodyPadding(context),
      child: _introContent(context),
    );
  }

  EdgeInsets _bodyPadding(BuildContext context) {
    return const EdgeInsets.all(20);
  }

  Widget _introContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'postAdTitle'.translate(context),
          fontWeight: FontWeight.w700,
          fontSize: context.font.larger,
          color: context.color.textDefaultColor,
        ),
        const SizedBox(height: 12),
        CustomText(
          'postAdSubtitle'.translate(context),
          color: context.color.textLightColor,
        ),
        const SizedBox(height: 24),
        _StepRow(
          index: 1,
          label: 'selectTheCategory'.translate(context),
        ),
        _StepRow(
          index: 2,
          label: 'postAdStepDetails'.translate(context),
        ),
        _StepRow(
          index: 3,
          label: 'selectLocation'.translate(context),
        ),
        _StepRow(
          index: 4,
          label: 'uploadPictures'.translate(context),
        ),
        const Spacer(),
        _continueButton(context),
      ],
    );
  }

  Widget _adTypeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'adListing'.translate(context),
          fontWeight: FontWeight.w700,
          fontSize: context.font.larger,
          color: context.color.textDefaultColor,
        ),
        const SizedBox(height: 8),
        CustomText(
          'selectTheCategory'.translate(context),
          color: context.color.textLightColor,
        ),
        const SizedBox(height: 20),
        _AdTypeTile(
          title: 'adListing'.translate(context),
          subtitle: 'postAdSubtitle'.translate(context),
          selected: _selectedAdType == _listingAdType,
          onTap: () => setState(() => _selectedAdType = _listingAdType),
        ),
        const Spacer(),
        _continueButton(context),
      ],
    );
  }

  Widget _continueButton(BuildContext context) {
    return UiUtils.buildButton(
      context,
      width: context.screenWidth,
      height: 48,
      radius: 10,
      buttonTitle: 'continue'.translate(context),
      buttonColor: context.color.territoryColor,
      textColor: context.color.secondaryColor,
      onPressed: _onContinue,
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

class _AdTypeTile extends StatelessWidget {
  const _AdTypeTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? context.color.territoryColor.withValues(alpha: 0.08)
          : context.color.secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? context.color.territoryColor
                  : context.color.textLightColor.withValues(alpha: 0.15),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                color: selected
                    ? context.color.territoryColor
                    : context.color.textDefaultColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontWeight: FontWeight.w600,
                      color: context.color.textDefaultColor,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      color: context.color.textLightColor,
                      fontSize: context.font.small,
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: context.color.territoryColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: context.color.territoryColor,
            child: CustomText(
              '$index',
              color: context.color.secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: context.font.small,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomText(
              label,
              fontWeight: FontWeight.w500,
              color: context.color.textDefaultColor,
            ),
          ),
        ],
      ),
    );
  }
}
