import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yeektv/Controller/homepageController.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';

import 'VideoPlayerScreen.dart';
import 'Widgets/Drawer/CustomDrawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  final homepageController HomePageController = Get.put(homepageController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      HomePageController.isScrolled.value = _scrollController.offset > 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ✅ Add Scaffold key for drawer control
      endDrawer: const CustomDrawer(), // ✅ Drawer opens from right
      body: Stack(
        children: [
          // Main scrollable background content
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: const AssetImage('assets/back.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.8), // Equivalent to background-position: 0 20%
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 85.h),
                  Image.asset('assets/newLogo.png'),
                  SizedBox(height: 5.h),

                  Container(
                    height: 170.h,
                    margin: EdgeInsets.only(bottom: 90.h),
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.w),
                      child: Obx(
                            () => HomePageController.showBroadcast.value == true
                            ? Padding(
                          padding:  EdgeInsets.only(top: 30.0.h),
                          child: ZoomIn(
                            config: BaseAnimationConfig(
                              delay: Duration(seconds: 1),
                              duration: Duration(seconds: 2),
                              child: Text(
                                '& broadcasting',
                                style: TextStyle(
                                  fontSize: 50.sp,
                                  fontFamily: 'evang',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                            : Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SlideInLeft(
                              config: BaseAnimationConfig(
                                delay: Duration(seconds: 3),
                                duration: Duration(
                                  milliseconds: 1500,
                                ),
                                child: Row(
                                  children: [
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
                              ),
                            ),
                            SlideInRight(
                              config: BaseAnimationConfig(
                                delay: const Duration(seconds: 6),
                                duration: const Duration(milliseconds: 1500),
                                child: Row(
                                  children: [
                                    Text(
                                      'ESSENCE OF ORIGINALITY',
                                      style: TextStyle(
                                        fontSize: 30.sp,
                                        height: 1,
                                        fontFamily: 'evang',
                                        color: Colors.white,
                                      ),
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
                                    Text(
                                      'IN CREATING ... ',
                                      style: TextStyle(
                                        fontSize: 30.sp,
                                        height: 1,
                                        fontFamily: 'evang',
                                        color: Colors.white,
                                      ),
                                    ),
                                    AnimatedTextKit(
                                      isRepeatingAnimation: false,
                                      onFinished: () {
                                        HomePageController.showBroadcast.value = true;
                                        Future.delayed(const Duration(seconds: 5)).then((_) {
                                          HomePageController.showBroadcast.value = false;
                                        });
                                      },
                                      animatedTexts: [
                                        FadeAnimatedText(
                                          '',
                                          textStyle: TextStyle(
                                            fontSize: 30.sp,
                                            height: 1,
                                            fontFamily: 'evang',
                                            color: Colors.white,
                                          ),
                                        ),
                                        FadeAnimatedText(
                                          ' ART',
                                          textStyle: TextStyle(
                                            fontSize: 30.sp,
                                            height: 1,
                                            fontFamily: 'evang',
                                            color: Colors.white,
                                          ),
                                        ),
                                        FadeAnimatedText(
                                          ' MUSIC',
                                          textStyle: TextStyle(
                                            height: 0.8,
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Plan Selection Section
                  Column(
                    children: [
                      Center(
                        child: Container(
                          height: 30.h,
                          width: 140.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1.25,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              "Choose your plan",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.sp,
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

                  // ✅ Added 200 pixels of space below the column
                  SizedBox(height: 200.h),

                  // Bottom image
                  Image.asset(
                    'assets/singlefront.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),

          // Fixed Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(
                  () => Container(
                color: HomePageController.isScrolled.value
                    ? Colors.white
                    : Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 12.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Open drawer using key
                    InkWell(
                      onTap: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      child: Icon(
                        Icons.menu,
                        color: HomePageController.isScrolled.value
                            ? Colors.black
                            : Colors.white,
                        size: 55.r,
                      ),),
                    GestureDetector(
                      onTap: (){
                        Get.to(VideoPlayerScreen());
                      },
                      child: Container(
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1.25,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w,
                          ),
                          child: Center(
                            child: Text(
                              "Start Listening",
                              style: TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}