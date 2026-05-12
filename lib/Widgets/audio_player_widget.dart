import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../Controller/audio_player_controller.dart';
import '../models/track.dart';
import '../utils/s3_url_fix.dart';
import 'animated_track_thumbnail.dart';
import 'waveform_widget.dart';

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({Key? key}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  bool _showFullscreenIcon = false;
  Timer? _hideIconTimer;

  void _onThumbnailTap() {
    setState(() {
      _showFullscreenIcon = true;
    });

    // Cancel previous timer if exists
    _hideIconTimer?.cancel();

    // Hide icon after 5 seconds
    _hideIconTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showFullscreenIcon = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideIconTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AudioPlayerController>();

    return Obx(() {
      final track = controller.currentTrack.value;
      if (track == null) {
        return Container(
          width: Get.width * 0.93,
          height: 210.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.r),
            color: Colors.black,
          ),
          child: Text(
            'Loading radio channel...',
            style: TextStyle(
              fontFamily: 'YeekBold',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: _onThumbnailTap,
        child: Container(
          width: Get.width * 0.93,
          height: 350.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(0.r)),
          child: Stack(
            children: [
              // Background Image - fills the container
              ClipRRect(
                borderRadius: BorderRadius.circular(0.r),
                child: AnimatedTrackThumbnail(
                  imageUrl: fixS3UrlFormat(track.thumbnail),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  borderRadius: BorderRadius.circular(0.r),
                ),
              ),
              // Main Content Column
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Track Title

                      // Track Info Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Track Meta Info with padding left
                          // Padding(
                          //   padding: EdgeInsets.only(left: 13.w),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       if (track.artist.isNotEmpty)
                          //         Text(
                          //           track.artist.toUpperCase(),
                          //           style: TextStyle(
                          //             fontFamily: 'YeekBold',
                          //             fontSize: 15.sp,
                          //             fontWeight: FontWeight.w700,
                          //             color: Colors.white,
                          //           ),
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //         ),
                          //       if (track.album.isNotEmpty) ...[
                          //         SizedBox(height: 2.h),
                          //         Text(
                          //           track.album.toUpperCase(),
                          //           style: TextStyle(
                          //             fontFamily: 'YeekBold',
                          //             fontSize: 15.sp,
                          //             fontWeight: FontWeight.w700,
                          //             color: Colors.white,
                          //           ),
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //         ),
                          //       ],
                          //       if (track.year > 0) ...[
                          //         SizedBox(height: 2.h),
                          //         Text(
                          //           track.year.toString().toUpperCase(),
                          //           style: TextStyle(
                          //             fontFamily: 'YeekBold',
                          //             fontSize: 15.sp,
                          //             fontWeight: FontWeight.w700,
                          //             color: Colors.white,
                          //           ),
                          //           maxLines: 1,
                          //           overflow: TextOverflow.ellipsis,
                          //         ),
                          //       ],
                          //     ],
                          //   ),
                          // ),

                          // Play/Pause Button (below, no padding left)
                          SizedBox(height: 126.h),
                          Obx(
                            () => GestureDetector(
                              onTap: () {
                                if (!controller.userHasUnmuted.value) {
                                  controller.unmute();
                                }
                                controller.togglePlayPause();
                              },
                              child: Container(
                                width: 72.w,
                                height: 72.h,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(150, 123, 17, 0.6),
                                  border: Border.all(
                                    color: Color(0xFFEFBF04),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 36.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Spacer for thumbnail box position
                      // SizedBox(height: 200.h),
                      // SizedBox(height: 25.h),
                      SizedBox(height: 66.h),
                      // Waveform
                      Obx(
                        () => WaveformWidget(
                          mp3Url: fixS3UrlFormat(track.mp3Url),
                          isPlaying: controller.isPlaying.value,
                          currentTime: controller.currentTime.value,
                          // just_audio can report duration=0 for streams; fallback to track.duration
                          duration: (controller.duration.value > 0)
                              ? controller.duration.value
                              : track.duration.toDouble(),
                        ),
                      ),
                      SizedBox(height: 26.h),

                      // Controls Row
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     // Volume Control
                      //     Obx(
                      //       () => GestureDetector(
                      //         onTap: () {
                      //           // Show volume slider dialog
                      //           // _showVolumeDialog(context, controller);
                      //         },
                      //         child: Icon(
                      //           controller.volume.value > 0.5
                      //               ? Icons.volume_up
                      //               : controller.volume.value > 0
                      //               ? Icons.volume_down
                      //               : Icons.volume_off,
                      //           color: Colors.white,
                      //           size: 24.sp,
                      //         ),
                      //       ),
                      //     ),

                      //     // Like Button
                      //     GestureDetector(
                      //       onTap: () {
                      //         // Toggle like
                      //       },
                      //       child: Icon(
                      //         Icons.favorite_border,
                      //         color: Colors.white,
                      //         size: 24.sp,
                      //       ),
                      //     ),

                      //     // Previous Channel
                      //     GestureDetector(
                      //       onTap: () => controller.previousChannel(),
                      //       child: Icon(
                      //         Icons.skip_previous,
                      //         color: Colors.white,
                      //         size: 24.sp,
                      //       ),
                      //     ),

                      //     // Next Channel
                      //     GestureDetector(
                      //       onTap: () => controller.nextChannel(),
                      //       child: Icon(
                      //         Icons.skip_next,
                      //         color: Colors.white,
                      //         size: 24.sp,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

              // Fullscreen Icon (bottom right of entire section) - appears on tap
              if (_showFullscreenIcon)
                Positioned(
                  bottom: 0.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      _openFullscreen(context, track, controller);
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24.sp, // Increased by 50% (from 16.sp to 24.sp)
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  void _openFullscreen(
    BuildContext context,
    Track track,
    AudioPlayerController controller,
  ) {
    // Prevent duplicate fullscreen opens (shared across manual + rotation)
    if (controller.isFullscreenOpen.value) return;
    controller.isFullscreenOpen.value = true;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => FullscreenAudioPlayer(
              track: track,
              controller: controller,
              onExit: () {
                controller.isFullscreenOpen.value = false;
              },
            ),
            fullscreenDialog: true,
          ),
        )
        .then((_) {
          controller.isFullscreenOpen.value = false;
        });
  }
}

// Fullscreen Audio Player Widget
class FullscreenAudioPlayer extends StatefulWidget {
  final Track track;
  final AudioPlayerController controller;
  final VoidCallback? onExit;

  const FullscreenAudioPlayer({
    Key? key,
    required this.track,
    required this.controller,
    this.onExit,
  }) : super(key: key);

  @override
  State<FullscreenAudioPlayer> createState() => _FullscreenAudioPlayerState();
}

class _FullscreenAudioPlayerState extends State<FullscreenAudioPlayer>
    with WidgetsBindingObserver {
  bool _isLandscape = false;
  bool _isExiting = false;
  bool _hasBeenLandscape = false;
  final RxBool isLiked = false.obs;
  final RxBool isDisliked = false.obs;
  final RxInt likeCount = 21.obs;
  final RxInt dislikeCount = 10.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // IMPORTANT:
    // Don't lock the whole app to portrait when exiting fullscreen, because
    // AudioScreen needs to receive landscape rotations to auto-open fullscreen.
    //
    // Allow portrait + landscape here. We will auto-exit when user rotates back
    // to portrait (after we've been in landscape at least once).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Check initial orientation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrientation();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Restore to allow both portrait + landscape for AudioScreen auto-fullscreen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Ensure shared fullscreen state is cleared
    widget.controller.isFullscreenOpen.value = false;

    // Notify parent that fullscreen exited
    widget.onExit?.call();

    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted || _isExiting) return;
    _checkOrientation();
  }

  void _checkOrientation() {
    if (!mounted || _isExiting) return;

    // Use a small delay to ensure orientation is stable
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || _isExiting) return;

      final orientation = MediaQuery.of(context).orientation;
      final isLandscapeNow = orientation == Orientation.landscape;

      if (isLandscapeNow) {
        _hasBeenLandscape = true;
      }

      if (isLandscapeNow != _isLandscape) {
        setState(() {
          _isLandscape = isLandscapeNow;
        });

        // If rotated to portrait, exit fullscreen automatically
        // Only exit if we've actually been in landscape at least once
        // (prevents immediate exit if fullscreen is opened while still portrait).
        if (!isLandscapeNow && _hasBeenLandscape) {
          _exitFullscreen();
        }
      }
    });
  }

  /// Exit fullscreen smoothly
  void _exitFullscreen() {
    if (_isExiting) return;
    _isExiting = true;

    // Clear shared fullscreen state immediately (prevents any double-open)
    widget.controller.isFullscreenOpen.value = false;

    // Exit fullscreen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Full Background Image
            Positioned.fill(
              child: AnimatedTrackThumbnail(
                imageUrl: fixS3UrlFormat(widget.track.thumbnail),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.zero,
              ),
            ),
            // Dark overlay for better text visibility
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),

            // Track Info Column (Top Left)
            Positioned(
              top: 20.h,
              left: 0.w,
              child: Container(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.95),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "\"${widget.track.title.toUpperCase()}\"",
                      style: TextStyle(
                        fontFamily: 'YeekBold',
                        fontSize:
                            8.sp, // Reduced by 40% (14.sp * 0.6 = 8.4 ≈ 8.sp)
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    // Artist
                    if (widget.track.artist.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          widget.track.artist.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'YeekBold',
                            fontSize: 7
                                .sp, // Reduced by 40% (12.sp * 0.6 = 7.2 ≈ 7.sp)
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (widget.track.artist.isNotEmpty) SizedBox(height: 4.h),
                    // Album
                    if (widget.track.album.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          widget.track.album.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'YeekBold',
                            fontSize: 7
                                .sp, // Reduced by 40% (12.sp * 0.6 = 7.2 ≈ 7.sp)
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (widget.track.album.isNotEmpty) SizedBox(height: 4.h),
                    // Year
                    if (widget.track.year > 0)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          widget.track.year.toString().toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'YeekBold',
                            fontSize: 7
                                .sp, // Reduced by 40% (12.sp * 0.6 = 7.2 ≈ 7.sp)
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    SizedBox(height: 12.h),

                    // Play/Pause Button
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          if (!widget.controller.userHasUnmuted.value) {
                            widget.controller.unmute();
                          }
                          widget.controller.togglePlayPause();
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(150, 123, 17, 0.6),
                            border: Border.all(
                              color: Color(0xFFEFBF04),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            widget.controller.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: _buildLikeDislikeButtons(),
            ),

            // Waveform at Bottom Center
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 0,
              child: Center(
                child: Container(
                  width: screenWidth * 0.7,
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Obx(
                    () => WaveformWidget(
                      mp3Url: fixS3UrlFormat(widget.track.mp3Url),
                      isPlaying: widget.controller.isPlaying.value,
                      currentTime: widget.controller.currentTime.value,
                      // just_audio can report duration=0 for streams; fallback to track.duration
                      duration: (widget.controller.duration.value > 0)
                          ? widget.controller.duration.value
                          : widget.track.duration.toDouble(),
                      isFullscreen:
                          true, // Fullscreen mode for increased bar heights
                    ),
                  ),
                ),
              ),
            ),

            // Fullscreen Icon (Bottom Right)
            Positioned(
              bottom: 0.h,
              right: -10.w,
              child: GestureDetector(
                onTap: () => _exitFullscreen(),
                child: Container(
                  padding: EdgeInsets.all(8.w),

                  child: Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeDislikeButtons() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),

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
                    size: 12.sp,
                    color: isLiked.value
                        ? const Color(0xFFEFBF04)
                        : Colors.white,
                  ),
                  // SizedBox(width: 4.w),
                  // Text(
                  //   '${likeCount.value}',
                  //   style: TextStyle(
                  //     fontSize: 8.sp,
                  //     fontWeight: FontWeight.w700,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1.w,
              height: 18.h,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
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
                    size: 12.sp,
                    color: isDisliked.value
                        ? const Color(0xFFEFBF04)
                        : Colors.white,
                  ),
                  // SizedBox(width: 4.w),
                  // Text(
                  //   '${dislikeCount.value}',
                  //   style: TextStyle(
                  //     fontSize: 8.sp,
                  //     fontWeight: FontWeight.w700,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
