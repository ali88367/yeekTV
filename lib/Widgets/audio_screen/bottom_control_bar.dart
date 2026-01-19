import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/audio_player_controller.dart';

class BottomControlBar extends StatelessWidget {
  final AudioPlayerController audioController;
  final RxBool isLiked;
  final RxBool isDisliked;
  final RxInt likeCount;
  final RxInt dislikeCount;

  const BottomControlBar({
    Key? key,
    required this.audioController,
    required this.isLiked,
    required this.isDisliked,
    required this.likeCount,
    required this.dislikeCount,
  }) : super(key: key);

  String _formatTime(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(color: const Color(0xFF3f3f3f), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, top: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Progress Bar with Times
            Container(
              width: 100.w,
              margin: EdgeInsets.only(top: 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Progress Bar
                  Obx(() {
                    final currentTime = audioController.currentTime.value;
                    final duration = audioController.duration.value > 0
                        ? audioController.duration.value
                        : (audioController.currentTrack.value?.duration
                                  .toDouble() ??
                              0);
                    final progress = duration > 0
                        ? (currentTime / duration).clamp(0.0, 1.0)
                        : 0.0;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Filled portion
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFBF04),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                              // White thumb dot (non-interactive) - centered on progress bar
                              Positioned(
                                left: (progress * constraints.maxWidth - 7.w)
                                    .clamp(0.0, constraints.maxWidth - 14.w),
                                top: -5.h,
                                child: Container(
                                  width: 14.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.6),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  SizedBox(height: 8.h),
                  // Times Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current Time
                      Obx(() {
                        return Text(
                          _formatTime(audioController.currentTime.value),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEFBF04),
                          ),
                        );
                      }),
                      // Total Duration
                      Obx(() {
                        final duration = audioController.duration.value > 0
                            ? audioController.duration.value
                            : (audioController.currentTrack.value?.duration
                                      .toDouble() ??
                                  0);
                        return Text(
                          _formatTime(duration),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Center: Control Icons
            Container(
              width: 110.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Backward Icon
                  Flexible(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => audioController.previousChannel(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                        child: Icon(
                          Icons.skip_previous,
                          color: const Color(0xFFEFBF04),
                          size: 25.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 22.w),
                  // Play/Pause Icon
                  Container(
                    height: 100.h,
                    child: Obx(() {
                      return GestureDetector(
                        onTap: () {
                          if (!audioController.userHasUnmuted.value) {
                            audioController.unmute();
                          }
                          audioController.togglePlayPause();
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            audioController.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: const Color(0xFFEFBF04),
                            size: 32.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 2.w),
                  // Forward Icon
                  Flexible(
                    child: GestureDetector(
                      onTap: () => audioController.nextChannel(),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                        child: Icon(
                          Icons.skip_next,
                          color: const Color(0xFFEFBF04),
                          size: 25.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right Side: Volume Icon, Volume Progress Bar and Heart
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Volume Icon
                  Obx(() {
                    final volume = audioController.volume.value;
                    IconData volumeIcon;
                    if (volume == 0) {
                      volumeIcon = Icons.volume_off;
                    } else if (volume < 0.5) {
                      volumeIcon = Icons.volume_down;
                    } else {
                      volumeIcon = Icons.volume_up;
                    }
                    return GestureDetector(
                      onTap: () {
                        if (volume > 0) {
                          audioController.setVolume(0);
                        } else {
                          audioController.setVolume(0.8);
                          audioController.unmute();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          volumeIcon,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 2.w),
                  // Volume Progress Bar
                  Obx(() {
                    final volume = audioController.volume.value;
                    final barWidth = 40.w;
                    return GestureDetector(
                      onTapDown: (details) {
                        final newVolume = (details.localPosition.dx / barWidth)
                            .clamp(0.0, 1.0);
                        audioController.setVolume(newVolume);
                        audioController.unmute();
                      },
                      onHorizontalDragUpdate: (details) {
                        final newVolume = (details.localPosition.dx / barWidth)
                            .clamp(0.0, 1.0);
                        audioController.setVolume(newVolume);
                        audioController.unmute();
                      },
                      child: Container(
                        width: barWidth,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(1.5.r),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            FractionallySizedBox(
                              widthFactor: volume,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFBF04),
                                  borderRadius: BorderRadius.circular(1.5.r),
                                ),
                              ),
                            ),
                            // White thumb dot (interactive) - centered on progress bar
                            Positioned(
                              left: (volume * barWidth - 7.w).clamp(
                                0.0,
                                barWidth - 14.w,
                              ),
                              top: -5.h,
                              child: Container(
                                width: 14.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 2.w),
                  // Heart Icon
                  Obx(() {
                    return GestureDetector(
                      onTap: () {
                        isLiked.value = !isLiked.value;
                        if (isLiked.value) {
                          likeCount.value++;
                          if (isDisliked.value) {
                            isDisliked.value = false;
                            dislikeCount.value--;
                          }
                        } else {
                          likeCount.value--;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        child: Icon(
                          isLiked.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: const Color(0xFFEFBF04),
                          size: 22.sp,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
