import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SubscriptionMenu {
  static void show(
    BuildContext context, {
    required RxString subscriptionPreference,
    required RxBool isSubscribed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  _SubscriptionMenuItem(
                    title: 'All',
                    icon: Icons.notifications,
                    subscriptionPreference: subscriptionPreference,
                    onTap: () {
                      subscriptionPreference.value = 'All';
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 8.h),
                  _SubscriptionMenuItem(
                    title: 'Personalized',
                    icon: Icons.notifications_active,
                    subscriptionPreference: subscriptionPreference,
                    onTap: () {
                      subscriptionPreference.value = 'Personalized';
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 8.h),
                  _SubscriptionMenuItem(
                    title: 'None',
                    icon: Icons.notifications_off,
                    subscriptionPreference: subscriptionPreference,
                    onTap: () {
                      subscriptionPreference.value = 'None';
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 16.h),
                  Divider(color: Colors.white.withOpacity(0.2)),
                  SizedBox(height: 8.h),
                  _SubscriptionMenuItem(
                    title: 'Unsubscribe',
                    icon: Icons.close,
                    subscriptionPreference: subscriptionPreference,
                    onTap: () {
                      isSubscribed.value = false;
                      subscriptionPreference.value = 'All';
                      Navigator.pop(context);
                    },
                    isDestructive: true,
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

class _SubscriptionMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final RxString subscriptionPreference;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SubscriptionMenuItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.subscriptionPreference,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = subscriptionPreference.value == title && !isDestructive;
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEFBF04).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : (selected ? const Color(0xFFEFBF04) : Colors.white),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? Colors.red
                        : (selected ? const Color(0xFFEFBF04) : Colors.white),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check, color: const Color(0xFFEFBF04), size: 20.sp),
            ],
          ),
        ),
      );
    });
  }
}
