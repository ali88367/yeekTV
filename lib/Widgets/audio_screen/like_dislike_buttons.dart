import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LikeDislikeButtons extends StatelessWidget {
  final RxBool isLiked;
  final RxBool isDisliked;
  final RxInt likeCount;
  final RxInt dislikeCount;

  const LikeDislikeButtons({
    Key? key,
    required this.isLiked,
    required this.isDisliked,
    required this.likeCount,
    required this.dislikeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Like Button
            GestureDetector(
              onTap: () {
                if (isLiked.value) {
                  isLiked.value = false;
                  likeCount.value--;
                } else {
                  isLiked.value = true;
                  likeCount.value++;
                  if (isDisliked.value) {
                    isDisliked.value = false;
                    dislikeCount.value--;
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 18.sp,
                    color: isLiked.value
                        ? const Color(0xFFEFBF04)
                        : Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${likeCount.value}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1.5,
              height: 18.h,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              color: const Color(0xFF3f3f3f).withOpacity(0.6),
            ),

            // Dislike Button
            GestureDetector(
              onTap: () {
                if (isDisliked.value) {
                  isDisliked.value = false;
                  dislikeCount.value--;
                } else {
                  isDisliked.value = true;
                  dislikeCount.value++;
                  if (isLiked.value) {
                    isLiked.value = false;
                    likeCount.value--;
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.thumb_down,
                    size: 18.sp,
                    color: isDisliked.value
                        ? const Color(0xFFEFBF04)
                        : Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${dislikeCount.value}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
