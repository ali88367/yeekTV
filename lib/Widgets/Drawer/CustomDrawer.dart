import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      width: Get.width,
      backgroundColor: Colors.white,
      clipBehavior: Clip.none,

      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button (top right)
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(32, 32, 250, .2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.w,
                        color: Color.fromRGBO(32, 32, 250, 1)
                      )
                    ),
                    child: Icon(Icons.close, color: Color.fromRGBO(32, 32, 250, 1), size: 14.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Search Bar
              Container(
                height: 48.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.grey.shade200,
                  //     spreadRadius: 1,
                  //     blurRadius: 4,
                  //   ),
                  // ],
                ),
                child: Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.only(left: 12.w, bottom: 8.h),
                      hintText: 'Search...',
                      hintStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: Colors.blue.shade100,
                        )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),

                          borderSide: BorderSide(
                              color: Colors.blue.shade100
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),

                          borderSide: BorderSide(
                              color: Colors.blue.shade100
                          )
                      ),

                      prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 10.h,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 10.h),

              // Menu Items
              ...[
                'Discover',
                'Channel Guide',
                'Subscriptions',
                'Profile',
                'Notifications',
                'Login',
                'Sign Up',
              ].map(
                    (text) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Help & Support Text
              Center(
                child: Text(
                  'Help & Support',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black54),
                ),
              ),
              SizedBox(height: 20.h),

              // Start Listening Button
              SizedBox(
                width: double.infinity,
                height: 42.h,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Start Listening',
                    style: TextStyle(fontSize: 15.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
