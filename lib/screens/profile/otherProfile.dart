import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:yeektv/Controller/audio_player_controller.dart';
import 'package:yeektv/Widgets/YeekItalicText.dart';
import 'package:yeektv/Widgets/audio_player_widget.dart';
import 'package:yeektv/Widgets/audio_screen/audio_screen_header.dart';
import 'package:yeektv/Widgets/audio_screen/bottom_control_bar.dart';
import 'package:yeektv/Widgets/audio_screen/channel_info_box.dart';
import 'package:yeektv/Widgets/audio_screen/collapsed_comments_section.dart';
import 'package:yeektv/Widgets/comments_section.dart';
import 'package:yeektv/Widgets/tabbar/TabBarScreen.dart';

class OtherProfile extends StatefulWidget {
  const OtherProfile({Key? key}) : super(key: key);

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AudioPlayerController audioController;
  late AnimationController _animationController;
  late List<AnimationController> _ringControllers;
  late List<Animation<double>> _ringAnimations;
  final RxBool showChat = false.obs;
  final RxBool isLiked = false.obs;
  final RxBool isDisliked = false.obs;
  final RxInt likeCount = 21.obs;
  final RxInt dislikeCount = 10.obs;
  final RxBool isSubscribed = false.obs;
  final RxString subscriptionPreference = 'All'.obs;
  final RxInt viewerCount = 406.obs;
  final RxBool isExpanded = false.obs;
  final RxBool isDescExpanded = false.obs;
  final RxBool showComments = false.obs;
  final RxBool showSubscriptionMenu = false.obs;

  late AnimationController _particleAnimationController;
  late AnimationController _bellAnimationController;
  late Animation<double> _bellRotationAnimation;
  final RxBool showParticles = false.obs;

  bool _isProcessingOrientation = false;
  Orientation? _lastOrientation;
  bool _isNavigatingToFullscreen = false;

  @override
  void initState() {
    super.initState();
    audioController = Get.put(AudioPlayerController());

    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _handleOrientation();
        }
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3, milliseconds: 500),
    )..repeat();

    _ringControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 2400),
        vsync: this,
      );
    });

    _ringAnimations = _ringControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    }).toList();

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bellAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bellRotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _bellAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _startRingAnimations();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    if (_isProcessingOrientation) {
      return;
    }

    _isProcessingOrientation = true;
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) {
        _isProcessingOrientation = false;
        return;
      }

      _handleOrientation();
      _isProcessingOrientation = false;
    });
  }

  void _handleOrientation() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final orientation = size.width > size.height
        ? Orientation.landscape
        : Orientation.portrait;

    if (_lastOrientation == orientation) return;
    _lastOrientation = orientation;

    if (orientation == Orientation.landscape) {
      _openFullscreenIfNeeded();
    }
  }

  void _openFullscreenIfNeeded() {
    if (!mounted) return;
    if (_isNavigatingToFullscreen) return;
    if (audioController.isFullscreenOpen.value) return;

    final track = audioController.currentTrack.value;
    if (track == null) return;

    _isNavigatingToFullscreen = true;
    audioController.isFullscreenOpen.value = true;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FullscreenAudioPlayer(
              track: track,
              controller: audioController,
              onExit: () {
                audioController.isFullscreenOpen.value = false;
                _isNavigatingToFullscreen = false;
              },
            ),
            fullscreenDialog: true,
          ),
        )
        .then((_) {
          audioController.isFullscreenOpen.value = false;
          _isNavigatingToFullscreen = false;
        });
  }

  void _startRingAnimations() {
    for (int i = 0; i < _ringControllers.length; i++) {
      final delay = Duration(milliseconds: i * 480);
      Future.delayed(delay, () {
        if (mounted) {
          _ringControllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _animationController.dispose();
    for (var controller in _ringControllers) {
      controller.dispose();
    }
    _particleAnimationController.dispose();
    _bellAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f0f),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            SafeArea(child: _buildMobileLayout()),

            // Bottom Control Bar - Fixed at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomControlBar(
                audioController: audioController,
                isLiked: isLiked,
                isDisliked: isDisliked,
                likeCount: likeCount,
                dislikeCount: dislikeCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 150.h,
        ), // ⭐ Bottom padding for BottomControlBar
        child: Column(
          children: [
            // Header
            AudioScreenHeader(
              ringAnimations: _ringAnimations,
              audioController: audioController,
              viewerCount: viewerCount,
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color.fromRGBO(239, 191, 4, 1),
                        width: 3.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40.sp,
                      backgroundImage: const AssetImage(
                        'assets/WhatsApp Image 2025-12-24 at 9.23.12 PM.png',
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          YeekItalicText(
                            'TheDrumMajor',
                            fontSize: 23.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -6,
                            child: Text(
                              '.',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      YeekItalicText(
                        'KLC',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(
                        width: Get.width * 0.55,
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 10.h,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Transform.translate(
                    offset: const Offset(-5, -10),
                    child: Image.asset(
                      'assets/dust.png',
                      width: 55.w,
                      height: 55.h,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: Get.width * 0.65,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            YeekItalicText(
                              '50k',
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            YeekItalicText(
                              'Subscribers',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            YeekItalicText(
                              '0',
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            YeekItalicText(
                              'Posts',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.95,
                  child: Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 10.h,
                  ),
                ),
                SizedBox(height: 10.h),
                YeekItalicText(
                  'Official Music Videos',
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 2.h),
                YeekItalicText(
                  'Live Performance &',
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 2.h),
                YeekItalicText(
                  'Interviews',
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    YeekItalicText(
                      'klc.com and ',
                      fontSize: 29.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        YeekItalicText(
                          '4 more Links',
                          fontSize: 29.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        Container(
                          width: 175.w,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100.w,
                  height: 30.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.yellow[700]!, width: 3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Subscribe',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                SizedBox(
                  width: 100.w,
                  height: 30.h,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                    label: Text(
                      'Store',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(78, 78, 78, 0.57),
                      padding: EdgeInsets.symmetric(vertical: 0),
                      side: BorderSide(color: Colors.yellow[700]!, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: Get.width * 0.95,
              child: Divider(color: Colors.grey, thickness: 1, height: 10.h),
            ),
            SizedBox(width: Get.width * 0.95, child: TabBarScreen()),
          ],
        ),
      ),
    );
  }
}
