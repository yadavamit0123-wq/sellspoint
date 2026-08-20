import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/lottie_utility.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SellerVerificationCompleteScreen extends StatefulWidget {
  const SellerVerificationCompleteScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return SellerVerificationCompleteScreen();
      },
    );
  }

  @override
  _SellerVerificationCompleteScreenState createState() =>
      _SellerVerificationCompleteScreenState();
}

class _SellerVerificationCompleteScreenState
    extends State<SellerVerificationCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool isBack = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust duration as needed
    );

    _slideAnimation =
        Tween<Offset>(
          begin: Offset(0, 1.5), // Off-screen initially
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              LottieAssets.success,
              repeat: false,
              delegates: LottieUtility.getSuccessDelegates(
                color: context.colorScheme.primary,
              ),
            ),
            SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomText(
                      'userVerificationCompleted'.translate(context),
                      fontSize: context.font.extraLarge,
                      fontWeight: FontWeight.w600,
                      color: context.color.territoryColor,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomText(
                      'sellerDocApproveLbl'.translate(context),
                      textAlign: TextAlign.center,
                      fontSize: context.font.larger,
                      color: context.color.textDefaultColor,
                    ),
                  ),
                  SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).popUntilWithResult((route) => route.isFirst, true);
                    },
                    child: Container(
                      height: 46,
                      alignment: AlignmentDirectional.center,
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.color.territoryColor,
                      ),
                      child: CustomText(
                        "backToProfile".translate(context),
                        color: context.color.secondaryColor,
                        textAlign: TextAlign.center,
                        fontSize: context.font.larger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
