import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'custom_painters.dart';

class SubscribeButton extends StatelessWidget {
  final RxBool isSubscribed;
  final RxBool showParticles;
  final AnimationController particleAnimationController;
  final AnimationController bellAnimationController;
  final Animation<double> bellRotationAnimation;
  final VoidCallback onTap;

  const SubscribeButton({
    Key? key,
    required this.isSubscribed,
    required this.showParticles,
    required this.particleAnimationController,
    required this.bellAnimationController,
    required this.bellRotationAnimation,
    required this.onTap,
  }) : super(key: key);

  Widget _buildParticleAnimation() {
    return AnimatedBuilder(
      animation: particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            progress: particleAnimationController.value,
            buttonWidth: 150.w,
            buttonHeight: 30.h,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!isSubscribed.value) {
        // Subscribe button (not subscribed)
        return GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: 150.w,
              height: 30.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFEFBF04),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Center(
                      child: Text(
                        "Subscribe",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  // Particle animation overlay
                  Obx(
                    () => showParticles.value
                        ? _buildParticleAnimation()
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Subscribed state with bell and down arrow inside one button
        return GestureDetector(
          onTap: onTap,
          child: AnimatedBuilder(
            animation: bellRotationAnimation,
            builder: (context, child) {
              return Container(
                height: 30.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFBF04),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFEFBF04), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFEFBF04),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bell icon
                      Transform.rotate(
                        angle: bellRotationAnimation.value,
                        child: Icon(
                          Icons.notifications,
                          color: Colors.black,
                          size: 18.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      // Down arrow icon
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}
