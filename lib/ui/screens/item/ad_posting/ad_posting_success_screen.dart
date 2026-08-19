import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/lottie_utility.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AdPostingSuccessScreen extends StatefulWidget {
  const AdPostingSuccessScreen({
    required this.item,
    required this.isEdited,
    this.isUploadInProgress = false,
    super.key,
  });

  final ItemModel item;
  final bool isEdited;
  final bool isUploadInProgress;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => AdPostingSuccessScreen(
        item: args['item'] as ItemModel,
        isEdited: args['isEdited'] as bool? ?? false,
        isUploadInProgress: args['isUploadInProgress'] as bool? ?? false,
      ),
    );
  }

  @override
  State<AdPostingSuccessScreen> createState() => _AdPostingSuccessScreenState();
}

class _AdPostingSuccessScreenState extends State<AdPostingSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _buttonController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this)
      ..addListener(() {
        if (_lottieController.value > 0.5 && _buttonController.value == 0) {
          _buttonController.forward();
        }
      });
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Padding(
          padding: Constant.appContentPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                LottieAssets.success,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                  _lottieController.forward();
                },
                delegates: LottieUtility.getSuccessDelegates(
                  color: context.colorScheme.primary,
                ),
              ),
              32.vGap,
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!widget.isEdited)
                        Text(
                          'congratulations'.translate(context),
                          textAlign: TextAlign.center,
                          style: context.headlineSmall.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      8.vGap,
                      Text(
                        (widget.isEdited
                                ? 'updatedSuccess'
                                : 'submittedSuccess')
                            .translate(context),
                        textAlign: TextAlign.center,
                        style: context.titleMedium,
                      ),
                      if (widget.isUploadInProgress) ...[
                        16.vGap,
                        Text(
                          'videoUploadBackground'.translate(context),
                          textAlign: TextAlign.center,
                          style: context.bodyMedium.copyWith(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                      32.vGap,
                      FilledButton(
                        style: FilledButton.styleFrom(
                          fixedSize: Size.fromHeight(48),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.adDetailsScreen,
                            (route) => route.isFirst,
                            arguments: {
                              'item_id': widget.item.id,
                              'is_my_ad': true,
                            },
                          );
                        },
                        child: Text('previewAd'.translate(context)),
                      ),
                      24.vGap,
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: context.colorScheme.primary,
                          textStyle: context.titleMedium.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: context.colorScheme.primary,
                          ),
                          overlayColor: Colors.transparent,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntilWithResult((route) => route.isFirst, true);
                        },
                        child: Text('backToHome'.translate(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
