import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'HomePage.dart';
import 'colors.dart';
import 'Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize animations
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));

    // Navigate to login screen
    Get.off(() => const Homepage());
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.BackgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Animation
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Y',
                          style: GoogleFonts.inter(
                            fontSize: 60.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 30.h),

              // App Name Animation
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'YeekTV',
                          style: GoogleFonts.inter(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWhite,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Stream. Watch. Enjoy.',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 50.h),

              // Loading Animation
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 30.w,
                          height: 30.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryRed,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Loading...',
                              textStyle: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: AppColors.textMuted,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
