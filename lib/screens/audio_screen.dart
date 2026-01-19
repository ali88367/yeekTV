import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Controller/audio_player_controller.dart';
import '../Widgets/audio_player_widget.dart';
import '../Widgets/comments_section.dart';
import '../Widgets/audio_screen/audio_screen_header.dart';
import '../Widgets/audio_screen/channel_info_box.dart';
import '../Widgets/audio_screen/collapsed_comments_section.dart';
import '../Widgets/audio_screen/bottom_control_bar.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({Key? key}) : super(key: key);

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen>
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
  final RxString subscriptionPreference = 'All'.obs; // All, Personalized, None
  final RxInt viewerCount = 406.obs;
  final RxBool isExpanded = false.obs;
  final RxBool isDescExpanded = false.obs;
  final RxBool showComments = false.obs;
  final RxBool showSubscriptionMenu = false.obs;

  // Animation controllers for subscribe button
  late AnimationController _particleAnimationController;
  late AnimationController _bellAnimationController;
  late Animation<double> _bellRotationAnimation;
  final RxBool showParticles = false.obs;

  // Orientation tracking for automatic fullscreen
  bool _isProcessingOrientation = false;
  Orientation? _lastOrientation;
  bool _isNavigatingToFullscreen = false; // Prevent duplicate navigation

  @override
  void initState() {
    super.initState();
    audioController = Get.put(AudioPlayerController());

    // Add orientation observer
    WidgetsBinding.instance.addObserver(this);

    // Allow landscape while on AudioScreen so iOS actually rotates and triggers
    // metrics/orientation updates (required for auto-fullscreen).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Check initial orientation after a delay to ensure MediaQuery is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _handleOrientation();
        }
      });
    });

    // Initialize animation controller for circular progress
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3, milliseconds: 500),
    )..repeat(); // Continuously repeat the animation

    // Initialize ring animation controllers (3 rings)
    _ringControllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 2400),
        vsync: this,
      );
    });

    // Create animations with curve
    _ringAnimations = _ringControllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    }).toList();

    // Initialize particle animation controller
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Initialize bell animation controller
    _bellAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Bell rotation animation
    _bellRotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _bellAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start ring animations with staggered delays
    _startRingAnimations();
  }

  /// Handle orientation changes - backup method
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    // Debounce to prevent rapid-fire calls
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
      final delay = Duration(milliseconds: i * 480); // 0, 480, 960
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

    // Restore to portrait-only when leaving AudioScreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _animationController.dispose();
    // Dispose ring controllers
    for (var controller in _ringControllers) {
      controller.dispose();
    }
    // Dispose subscribe animation controllers
    _particleAnimationController.dispose();
    _bellAnimationController.dispose();
    // Don't dispose controller here as it's managed globally
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
      child: Column(
        children: [
          // Header
          AudioScreenHeader(
            ringAnimations: _ringAnimations,
            audioController: audioController,
            viewerCount: viewerCount,
          ),
          SizedBox(height: 10.h),
          Obx(
            () => Text(
              '"${audioController.getCurrentChannelName().toUpperCase()}"',
              style: TextStyle(
                fontFamily: 'YeekBold',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10.h),
          // Audio Player Section
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(0.r),
              border: Border.all(color: const Color(0xFF3f3f3f), width: 2),
            ),
            child: const AudioPlayerWidget(),
          ),

          SizedBox(height: 10.h),

          // Channel Info Box
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(0.r),
              border: Border.all(color: const Color(0xFF3f3f3f), width: 2),
            ),
            child: ChannelInfoBox(
              audioController: audioController,
              animationController: _animationController,
              isSubscribed: isSubscribed,
              subscriptionPreference: subscriptionPreference,
              showParticles: showParticles,
              particleAnimationController: _particleAnimationController,
              bellAnimationController: _bellAnimationController,
              bellRotationAnimation: _bellRotationAnimation,
              isLiked: isLiked,
              isDisliked: isDisliked,
              likeCount: likeCount,
              dislikeCount: dislikeCount,
              viewerCount: viewerCount,
              isExpanded: isExpanded,
              isDescExpanded: isDescExpanded,
            ),
          ),

          SizedBox(height: 10.h),

          // Comments Section - Collapsed/Expanded
          Obx(
            () => showComments.value
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 300.h,
                    child: Stack(
                      children: [
                        // Comments Section
                        const CommentsSection(),

                        // Close Button (X) - Top Right
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: GestureDetector(
                            onTap: () {
                              showComments.value = false;
                            },
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 28.w,
                          child: GestureDetector(
                            onTap: () {
                              showComments.value = false;
                            },
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : CollapsedCommentsSection(
                    onTap: () {
                      showComments.value = true;
                    },
                  ),
          ),

          SizedBox(height: 120.h), // Extra padding for bottom control bar
        ],
      ),
    );
  }
}
