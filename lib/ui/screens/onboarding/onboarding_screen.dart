import 'package:eClassify/app/routes.dart';
import 'package:eClassify/ui/screens/onboarding/widgets/language_selector.dart';
import 'package:eClassify/ui/screens/onboarding/widgets/onboarding_page_view.dart';
import 'package:eClassify/ui/screens/onboarding/widgets/page_indicator.dart';
import 'package:eClassify/ui/screens/widgets/skip_button_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const OnboardingScreen(),
    );
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.color.backgroundColor,
        leading: LanguageSelector(),
        leadingWidth: 100,
        actions: [
          SkipButtonWidget(
            onTap: () {
              HiveUtils.setUserIsNotNew();
              HiveUtils.setUserSkip();
              Navigator.pushReplacementNamed(
                context,
                Routes.login,
                arguments: {"from": "login", "isSkipped": true},
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .65,
                ),
                child: Padding(
                  padding: Constant.appContentPadding,
                  child: OnboardingPageView(controller: _controller),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: Constant.appContentPadding.copyWith(top: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: ListenableBuilder(
                              listenable: _controller,
                              builder: (context, child) {
                                int index;
                                if (_controller.hasClients) {
                                  index = _controller.page?.round() ?? 0;
                                } else {
                                  index = 0;
                                }
                                final data = kOnboardingList[index];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      (data['title'] as String).translate(
                                        context,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: context.headlineSmall.copyWith(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (data['description'] as String)
                                            .translate(context),
                                        textAlign: TextAlign.center,
                                        maxLines: 3,
                                        style: context.titleMedium.withColor(
                                          context.mutedColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: Constant.bottomPadding,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PageIndicator(
                                  controller: _controller,
                                  count: kOnboardingList.length,
                                ),
                                FloatingActionButton(
                                  backgroundColor: context.color.territoryColor,
                                  foregroundColor:
                                      context.color.backgroundColor,
                                  shape: CircleBorder(),
                                  elevation: 0,
                                  onPressed: () {
                                    final isLast =
                                        _controller.page?.round() ==
                                        kOnboardingList.length - 1;
                                    if (isLast) {
                                      HiveUtils.setUserIsNotNew();
                                      HiveUtils.setUserSkip();

                                      Navigator.pushReplacementNamed(
                                        context,
                                        Routes.login,
                                        arguments: {
                                          "from": "login",
                                          "isSkipped": true,
                                        },
                                      );
                                    } else {
                                      _controller.nextPage(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.decelerate,
                                      );
                                    }
                                  },
                                  child: Icon(AppIcons.arrowRight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
