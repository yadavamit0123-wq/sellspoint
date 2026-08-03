import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _bottomLogosController;

  // Animations
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _bottomLogoScaleAnimation;

  // Animation delays
  bool _showAppName = false;
  bool _showTagline = false;
  bool _showBottomLogos = false;

  @override
  void initState() {
    super.initState();

    // Logo slide-in animation setup
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(-5.0, 0.0), // Left se aayega
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    // Bottom logos scale animation setup
    _bottomLogosController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bottomLogoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bottomLogosController,
      curve: Curves.elasticOut,
    ));

    // Start animations sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Step 1: Logo slide-in (0-1.2s)
    _logoController.forward();

    // Step 2: App name appear (1.2s delay)
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _showAppName = true;
    });

    // Step 3: Tagline appear (after app name - 1.8s total)
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _showTagline = true;
    });

    // Step 4: Bottom logos appear (after tagline - 2.5s total)
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _showBottomLogos = true;
    });
    _bottomLogosController.forward();

    // Optional: Navigate to home screen after splash (4s total)
    await Future.delayed(const Duration(milliseconds: 1500));
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _bottomLogosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ===== LOGO ANIMATION =====
              SlideTransition(
                position: _logoSlideAnimation,
                child: FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      // Yahan apna logo image/SVG lagao
                      child: Image.asset(
                        'assets/images/logo.png', // Replace with your logo path
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Agar image nahi mili to placeholder
                          return Container(
                            color: Colors.blue,
                            child: const Icon(
                              Icons.apartment_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== APP NAME ANIMATION =====
              if (_showAppName)
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'eClassify', // Replace with your app name
                      textStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                      speed: const Duration(milliseconds: 150),
                    ),
                  ],
                  repeatForever: false,
                  totalRepeatCount: 1,
                  displayFullTextOnTap: true,
                ),

              const SizedBox(height: 15),

              // ===== TAGLINE ANIMATION =====
              if (_showTagline)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        '"Buy and Sell Anything"', // Replace with your tagline
                        textAlign: TextAlign.center,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        duration: const Duration(milliseconds: 800),
                      ),
                    ],
                    repeatForever: false,
                    totalRepeatCount: 1,
                  ),
                ),

              const Spacer(flex: 3),

              // ===== BOTTOM 3 CIRCULAR LOGOS =====
              if (_showBottomLogos)
                ScaleTransition(
                  scale: _bottomLogoScaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                            (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              // Yahan apne 3 company logos lagao
                              child: Image.asset(
                                'assets/images/company_logo_${index + 1}.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Placeholder if image not found
                                  return Icon(
                                    Icons.business,
                                    color: Colors.grey[400],
                                    size: 30,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
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
