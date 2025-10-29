import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yeektv/Controller/homepageController.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:yeektv/VideoPlayerScreen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final ScrollController _scrollController = ScrollController();
  final homepageController HomePageController = Get.put(homepageController());
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
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/back3.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child:Column(
                children: [
                  SizedBox(height: 45.h),
                  Image.asset('assets/newLogo.png'),
                  SizedBox(height: 30.h),

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
                                delay: Duration(seconds: 6),
                                duration: Duration(
                                  milliseconds: 1500,
                                ),
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
                                delay: Duration(seconds: 9),
                                duration: Duration(
                                  milliseconds: 1500,
                                ),
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
                                        HomePageController
                                            .showBroadcast
                                            .value =
                                        true;
                                        Future.delayed(
                                          Duration(seconds: 5),
                                        ).then((_) {
                                          HomePageController
                                              .showBroadcast
                                              .value =
                                          false;
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
                  Column(
                    children: [
                      Center(
                        child: Container(
                          height: 38.h,
                          width: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 1.25,
                            ),
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
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h,),
                      Container(
                        height: 350.h,
                        width: 250.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.grey[300]
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/singlefront.png',
                    fit: BoxFit.contain,
                  ),



                ],
              ),
            ),
          ),
          Positioned(
            child: Obx(
                  () => Container(
                color: HomePageController.isScrolled.value == true
                    ? Colors.white
                    : Colors.transparent,

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.menu,
                        color:
                        HomePageController.isScrolled.value == true
                            ? Colors.black
                            : Colors.white,
                        size: 55.r,
                      ),
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
          ),
        ],
      ),
    );
  }
}
