import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yeektv/Controller/homepageController.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:yeektv/VideoPlayerScreen.dart';

import 'Widgets/Drawer/CustomDrawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  final homepageController HomePageController = Get.put(homepageController());

  bool _showQuestions = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      HomePageController.isScrolled.value = _scrollController.offset > 20;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper for social icons
  Widget _socialIcon(String asset) {
    return Image.asset(
      asset,
      width: 46.w,
      height: 46.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable background + content
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                height: Get.height * 2.7,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/back1.PNG'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 95.h),
                    Image.asset('assets/newLogo.png'),
                    SizedBox(height: 25.h),
            
                    // ------------------- Animated Text Section -------------------
                    Container(
                      height: 170.h,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: Obx(
                              () => HomePageController.showBroadcast.value == true
                              ? Center(
                            child: ZoomIn(
                              config: BaseAnimationConfig(
                                delay: const Duration(seconds: 1),
                                duration: const Duration(seconds: 2),
                                child: Stack(
                                  children: [
                                    Text(
                                      '& Broadcasting',
                                      style: TextStyle(
                                        fontSize: 50.sp,
                                        fontFamily: 'evang',
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 3
                                          ..color = Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '& Broadcasting',
                                      style: TextStyle(
                                        fontSize: 50.sp,
                                        fontFamily: 'evang',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                              : Column(
                            children: [
                              SlideInLeft(
                                config: BaseAnimationConfig(
                                  delay: const Duration(seconds: 3),
                                  duration: const Duration(milliseconds: 1500),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Text(
                                            'WE ARE TAKING IT BACK TO THE',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 2
                                                ..color = Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'WE ARE TAKING IT BACK TO THE',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SlideInRight(
                                config: BaseAnimationConfig(
                                  delay: const Duration(seconds: 6),
                                  duration: const Duration(milliseconds: 1500),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Text(
                                            'ESSENCE OF ORIGINALITY',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 2
                                                ..color = Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'ESSENCE OF ORIGINALITY',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SlideInRight(
                                config: BaseAnimationConfig(
                                  delay: const Duration(seconds: 9),
                                  duration: const Duration(milliseconds: 1500),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          Text(
                                            'IN CREATING ... ',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 2
                                                ..color = Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'IN CREATING ... ',
                                            style: TextStyle(
                                              height: 1,
                                              fontSize: 30.sp,
                                              fontFamily: 'evang',
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Custom Fade-In Sequence
                                      DefaultTextStyle(
                                        style: TextStyle(
                                          fontSize: 30.sp,
                                          fontFamily: 'evang',
                                          color: Colors.white,
                                        ),
                                        child: AnimatedTextSequence(
                                          texts: ['', ' ART', ' MUSIC'],
                                          onFinish: () {
                                            HomePageController.showBroadcast.value = true;
                                            Future.delayed(const Duration(seconds: 5)).then(
                                                  (_) => HomePageController.showBroadcast.value = false,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            
                    SizedBox(height: 20.h),
            
                    // ------------------- Plan Section -------------------
                    Column(
                      children: [
                        Center(
                          child: Container(
                            height: 38.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1.25),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Center(
                                child: Text(
                                  "Choose your plan",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Container(
                          height: 350.h,
                          width: 250.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
            
                    Image.asset(
                      height: 70.h,
                      'assets/singlefront.png',
                    ),
                    const Spacer(),
                    Stack(
                      children: [
                        Text(
                          'YEEK TV',
                          style: TextStyle(
                            fontSize: 50.sp,
                            height: 1,
                            fontFamily: 'evang',
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Colors.black,
                          ),
                        ),
                        Text(
                          'YEEK TV',
                          style: TextStyle(
                            fontSize: 50.sp,
                            height: 1,
                            fontFamily: 'evang',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            
                    SizedBox(height: 20.h),
                    // Social icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialIcon('assets/fb.png'),
                        SizedBox(width: 24.w),
                        _socialIcon('assets/insta.png'),
                        SizedBox(width: 24.w),
                        _socialIcon('assets/youtube.png'),
                        SizedBox(width: 24.w),
                        _socialIcon('assets/twitter.png'),
                      ],
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
            
            // ------------------- Sticky Header -------------------
            Positioned(
              child: Obx(() => Container(
                color: HomePageController.isScrolled.value ? Colors.white : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.to(CustomDrawer()),
                        child: Icon(
                          Icons.menu,
                          color: HomePageController.isScrolled.value ? Colors.black : Colors.white,
                          size: 55.r,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(const VideoPlayerScreen()),
                        child: Container(
                          height: 38.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 1.25),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Center(
                              child: Text(
                                "Start Listening",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
            ),
            
            // ------------------- Floating "Got Questions?" Widget -------------------
            if (_showQuestions)
              Positioned(
                bottom: 18.h,
                right: 20.w,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 180.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 10.h),
                            Text(
                              "Got Questions?",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "Chat with an expert.",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            // Action button
                            InkWell(
                              borderRadius: BorderRadius.circular(30.r),
                              onTap: () {
                                // Get.snackbar("Chat", "Opening support chat…");
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Center(
                                  child: Text(
                                    "Let’s get started",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Close button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _showQuestions = false),
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(Icons.close, size: 15.r, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).addTail(),
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------
// Custom Outlined Text Widget
// -------------------------------------------------
class _OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double height;

  const _OutlinedText({
    Key? key,
    required this.text,
    required this.fontSize,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outline
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            height: height,
            fontFamily: 'evang',
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = Colors.black,
          ),
        ),
        // Fill
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            height: height,
            fontFamily: 'evang',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
// Animated Text Sequence (Fade In: ART → MUSIC)
// -------------------------------------------------
class AnimatedTextSequence extends StatefulWidget {
  final List<String> texts;
  final VoidCallback onFinish;

  const AnimatedTextSequence({
    Key? key,
    required this.texts,
    required this.onFinish,
  }) : super(key: key);

  @override
  State<AnimatedTextSequence> createState() => _AnimatedTextSequenceState();
}

class _AnimatedTextSequenceState extends State<AnimatedTextSequence>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startNext();
  }

  void _startNext() {
    if (_index >= widget.texts.length) {
      widget.onFinish();
      return;
    }

    _controller.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _index++);
          _startNext();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.texts.length) return const SizedBox();

    return FadeTransition(
      opacity: _controller,
      child: _OutlinedText(
        text: widget.texts[_index],
        fontSize: 30.sp,
        height: _index == 2 ? 0.8 : 1.0, // MUSIC has tighter line height
      ),
    );
  }
}

// -------------------------------------------------
// Extension: Adds speech-bubble tail
// -------------------------------------------------
extension QuestionsTail on Widget {
  Widget addTail() {
    return Stack(
      children: [
        this,
        Positioned(
          left: -12.w,
          bottom: 28.h,
          child: CustomPaint(
            size: Size(24.w, 24.h),
            painter: _SpeechBubbleTailPainter(),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------
// Custom Painter for Tail
// -------------------------------------------------
class _SpeechBubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.6, 0)
      ..lineTo(size.width * 0.6, size.height)
      ..close();

    canvas.drawPath(path, paint);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}