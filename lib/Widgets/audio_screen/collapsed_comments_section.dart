import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollapsedCommentsSection extends StatelessWidget {
  final VoidCallback onTap;

  const CollapsedCommentsSection({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.grey[800], // Grey container
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF3f3f3f), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comments Title with Count
            Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '1.2k',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFaaaaaa),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Profile Image + Text Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Small circular profile image
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[700],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/WhatsApp Image 2025-12-24 at 9.23.12 PM.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20.sp,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Text
                Expanded(
                  child: Text(
                    'this is best radio',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
