import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/reel_upload_status_banner.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/main_activity.dart';
import 'package:eClassify/utils/ad_posting_success_navigation.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessItemScreen extends StatefulWidget {
  final ItemModel model;
  final bool isEdit;
  final bool reelUploadQueued;

  const SuccessItemScreen({
    super.key,
    required this.model,
    required this.isEdit,
    this.reelUploadQueued = false,
  });

  static Route route(RouteSettings settings) {
    Map? arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SuccessItemScreen(
          model: arguments!['model'],
          isEdit: arguments['isEdit'],
          reelUploadQueued: arguments['reel_upload_queued'] == true,
        );
      },
    );
  }

  @override
  _SuccessItemScreenState createState() => _SuccessItemScreenState();
}

class _SuccessItemScreenState extends State<SuccessItemScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSuccessShown = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _isLoading = false;
      _isSuccessShown = true;
    }

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust duration as needed
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.isEdit ? 0 : 1.5), // Off-screen initially
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Simulate loading time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
      // Show success animation after loading animation completes
      Future.delayed(const Duration(seconds: 0), () {
        if (mounted)
          setState(() {
            _isSuccessShown = true;
            Future.delayed(const Duration(seconds: 1), () {
              _slideController.forward();
            }); // Start slide animation
          });
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _handleBackButtonPressed() {
    if (_isSuccessShown && _slideController.isAnimating) {
      setState(() {
        isBack = false;
      });
      // Don't allow popping while the animation is playing
      return;
    } else {
      // Navigate back to the home screen
      _navigateBackToHome();
      return;
    }
  }

  void _navigateToMyAds() {
    if (!AppConfig.enableAdPostingSuccessStackCleanupV214) {
      _navigateBackToHome();
      return;
    }
    AdPostingSuccessNavigation.exitToMyAds(context);
  }

  void _navigateToReelsFeed() {
    if (!AppConfig.enableAdPostingSuccessStackCleanupV214) {
      _navigateBackToHome();
      return;
    }
    AdPostingSuccessNavigation.exitToReelsFeed(context);
  }

  void _navigateToAdDetailsScreen() {
    if (AppConfig.enableAdPostingSuccessStackCleanupV214) {
      AdPostingSuccessNavigation.exitToAdDetails(
        context,
        model: widget.model,
      );
      return;
    }
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushNamed(
      context,
      Routes.adDetailsScreen,
      arguments: {
        'model': widget.model,
      },
    );
  }

  void _navigateBackToHome() {
    if (AppConfig.enableAdPostingSuccessStackCleanupV214) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          AdPostingSuccessNavigation.exitToHome(context);
        }
      });
      return;
    }
    if (mounted)
      Future.delayed(
        Duration(milliseconds: 500),
        () {
          if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
          MainActivity.globalKey.currentState?.onItemTapped(0);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isBack,
      onPopInvokedWithResult: (didPop, result) async {
        // Handle back button press
        _handleBackButtonPressed();
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? Lottie.asset(
                  "assets/lottie/${Constant.loadingSuccessLottieFile}") // Replace with your loading animation
              : _isSuccessShown
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            "assets/lottie/${Constant.successItemLottieFile}",
                            repeat: false),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              SizedBox(height: 50),
                              if (!widget.isEdit)
                                CustomText(
                                  'congratulations'.translate(context),
                                  fontSize: context.font.extraLarge,
                                  fontWeight: FontWeight.w600,
                                  color: context.color.territoryColor,
                                ),
                              SizedBox(height: 18),
                              CustomText(
                                widget.isEdit
                                    ? 'updatedSuccess'.translate(context)
                                    : 'submittedSuccess'.translate(context),
                                color: context.color.textDefaultColor,
                                fontSize: context.font.larger,
                                textAlign: TextAlign.center,
                              ),
                              if (widget.reelUploadQueued &&
                                  AppConfig.enableReelUploadTrackerV214 &&
                                  !widget.isEdit &&
                                  widget.model.id != null)
                                ReelUploadStatusBanner(
                                  itemId: widget.model.id.toString(),
                                ),
                              if (widget.reelUploadQueued &&
                                  AppConfig
                                      .enableAdPostingSuccessReelUploadCtasV214 &&
                                  !widget.isEdit) ...[
                                const SizedBox(height: 24),
                                InkWell(
                                  onTap: _navigateToMyAds,
                                  child: Container(
                                    height: 48,
                                    alignment: AlignmentDirectional.center,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 65,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: context.color.territoryColor,
                                    ),
                                    child: CustomText(
                                      'adPostingSuccessViewMyAds'
                                          .translate(context),
                                      textAlign: TextAlign.center,
                                      fontSize: context.font.larger,
                                      color: context.color.secondaryColor,
                                    ),
                                  ),
                                ),
                                if (AppConfig.enableFiveTabNavV214)
                                  InkWell(
                                    onTap: _navigateToReelsFeed,
                                    child: Container(
                                      height: 48,
                                      alignment: AlignmentDirectional.center,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 65,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: context.color.territoryColor,
                                        ),
                                        color: context.color.secondaryColor,
                                      ),
                                      child: CustomText(
                                        'adPostingSuccessViewReels'
                                            .translate(context),
                                        textAlign: TextAlign.center,
                                        fontSize: context.font.larger,
                                        color: context.color.territoryColor,
                                      ),
                                    ),
                                  ),
                              ],
                              SizedBox(height: 60),
                              InkWell(
                                onTap: () {
                                  _navigateToAdDetailsScreen();
                                  //pageCntrlr.jumpToPage(3);
                                  /*  Navigator.pushReplacementNamed(
                                      context,
                                      Routes.main,
                                      arguments: {"from": "successItem"},
                                    ).then((_) {
                                      context
                                          .read<NavigationCubit>()
                                          .navigateToMyItems();
                                    });*/
                                  /*  Navigator.pushNamed(
                                      context,
                                      Routes.myItemScreen,
                                    );*/
                                },
                                child: Container(
                                    height: 48,
                                    alignment: AlignmentDirectional.center,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 65, vertical: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color:
                                                context.color.territoryColor),
                                        color: context.color.secondaryColor),
                                    child: CustomText(
                                      "previewAd".translate(context),
                                      textAlign: TextAlign.center,
                                      fontSize: context.font.larger,
                                      color: context.color.territoryColor,
                                    )),
                              ),
                              SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  _navigateBackToHome();
                                },
                                child: CustomText(
                                  'backToHome'.translate(context),
                                  textAlign: TextAlign.center,
                                  fontSize: context.font.larger,
                                  color: context.color.textDefaultColor,
                                  showUnderline: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox(), // Placeholder
        ),
      ),
    );
  }
}
