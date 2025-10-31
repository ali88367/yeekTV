import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yeektv/auth/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
          () => Get.to(LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/singleback.png'),
            fit: BoxFit.cover,

          ),
        ),
        child: Center(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 0.w),
            child: Image.asset('assets/newLogo.png'),
          ),
        ),
      ),
    );
  }
}