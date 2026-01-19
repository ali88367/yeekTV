import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/audio_player_controller.dart';
import '../../HomePage.dart';
import 'animated_sign_logo.dart';

class AudioScreenHeader extends StatelessWidget {
  final List<Animation<double>> ringAnimations;
  final AudioPlayerController audioController;
  final RxInt viewerCount;

  const AudioScreenHeader({
    Key? key,
    required this.ringAnimations,
    required this.audioController,
    required this.viewerCount,
  }) : super(key: key);

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: Color(0xFF3f3f3f), width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Channel Info
            Obx(
              () => ListTile(
                leading: const Icon(Icons.radio, color: Color(0xFFEFBF04)),
                title: Text(
                  audioController.getCurrentChannelName(),
                  style: TextStyle(
                    fontFamily: 'YeekBold',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(color: Color(0xFF3f3f3f)),
            // Viewer Count
            Obx(
              () => ListTile(
                leading: const Icon(Icons.visibility, color: Colors.red),
                title: Text(
                  'Viewers: ${viewerCount.value}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Divider(color: Color(0xFF3f3f3f)),
            // Settings or other options can be added here
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation here
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                fontFamily: 'YeekBold',
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEFBF04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0f0f0f),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF3f3f3f), width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home Icon (Left)
          GestureDetector(
            onTap: () {
              // Navigate to home page
              Get.offAll(const Homepage());
            },
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Image.asset(
                'assets/home.png',
                width: 24.w,
                height: 24.h,
                color: Colors.white,
              ),
            ),
          ),

          // Sign Logo with Animation (Center)
          Expanded(
            child: Center(
              child: AnimatedSignLogo(ringAnimations: ringAnimations),
            ),
          ),

          // Three Dots Menu (Right) - Horizontal
          GestureDetector(
            onTap: () {
              // Show menu options
              _showMenuDialog(context);
            },
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(Icons.more_horiz, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}
