import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_painters.dart';

class ChannelAvatar extends StatelessWidget {
  final AnimationController animationController;

  const ChannelAvatar({Key? key, required this.animationController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Avatar size
    final avatarSize = 90.w;
    final borderSize = 106.w; // avatar + 6px border (90 + 6)

    return Container(
      margin: EdgeInsets.only(left: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with animated border
          Container(
            width: avatarSize,
            height: avatarSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Avatar image
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/WhatsApp Image 2025-12-24 at 9.23.12 PM.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.radio,
                          color: Colors.white,
                          size: 30.sp,
                        );
                      },
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: animationController,
                  builder: (context, child) {
                    return SizedBox(
                      width: borderSize,
                      height: borderSize,
                      child: CustomPaint(
                        painter: CircularProgressPainter(
                          progress: animationController.value,
                          color: const Color(0xFFEFBF04),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          // DJ KLC Text
          Text(
            '"DJ KLC"',
            style: TextStyle(
              fontFamily: 'YeekBold',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
