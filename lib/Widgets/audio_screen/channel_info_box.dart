import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/audio_player_controller.dart';
import 'channel_avatar.dart';
import 'subscribe_button.dart';
import 'subscription_menu.dart';
import 'like_dislike_buttons.dart';
import 'stats_section.dart';
import 'description_section.dart';

class ChannelInfoBox extends StatelessWidget {
  final AudioPlayerController audioController;
  final AnimationController animationController;
  final RxBool isSubscribed;
  final RxString subscriptionPreference;
  final RxBool showParticles;
  final AnimationController particleAnimationController;
  final AnimationController bellAnimationController;
  final Animation<double> bellRotationAnimation;
  final RxBool isLiked;
  final RxBool isDisliked;
  final RxInt likeCount;
  final RxInt dislikeCount;
  final RxInt viewerCount;
  final RxBool isExpanded;
  final RxBool isDescExpanded;

  const ChannelInfoBox({
    Key? key,
    required this.audioController,
    required this.animationController,
    required this.isSubscribed,
    required this.subscriptionPreference,
    required this.showParticles,
    required this.particleAnimationController,
    required this.bellAnimationController,
    required this.bellRotationAnimation,
    required this.isLiked,
    required this.isDisliked,
    required this.likeCount,
    required this.dislikeCount,
    required this.viewerCount,
    required this.isExpanded,
    required this.isDescExpanded,
  }) : super(key: key);

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Track Title, Artist, Album, Year Column
        Obx(() {
          final track = audioController.currentTrack.value;
          if (track == null) return SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "\"${track.title.toUpperCase()}\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'YeekBold',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (track.artist.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    track.artist.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'YeekBold',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (track.album.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    track.album.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'YeekBold',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (track.year > 0) ...[
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    track.year.toString().toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'YeekBold',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          );
        }),
        SizedBox(height: 12.h),

        // Subscribe Actions Column - Below title
        _buildSubscribeActionsColumn(),
      ],
    );
  }

  Widget _buildSubscribeActionsColumn() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Channel Avatar
        ChannelAvatar(animationController: animationController),

        // Subscribe Buttons Wrapper - Right aligned
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Subscribe Button
              SubscribeButton(
                isSubscribed: isSubscribed,
                showParticles: showParticles,
                particleAnimationController: particleAnimationController,
                bellAnimationController: bellAnimationController,
                bellRotationAnimation: bellRotationAnimation,
                onTap: () {
                  if (!isSubscribed.value) {
                    // Trigger particle animation
                    showParticles.value = true;
                    particleAnimationController.forward(from: 0).then((_) {
                      particleAnimationController.reset();
                      showParticles.value = false;
                      Future.delayed(const Duration(milliseconds: 200), () {
                        isSubscribed.value = true;
                      });
                    });
                  } else {
                    // Show subscription menu
                    SubscriptionMenu.show(
                      Get.context!,
                      subscriptionPreference: subscriptionPreference,
                      isSubscribed: isSubscribed,
                    );
                  }
                },
              ),
              SizedBox(height: 8.h),

              // Subscriber Count - Smaller font
              Text(
                '12.4K subscribers',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFaaaaaa),
                ),
                textAlign: TextAlign.end,
              ),
              SizedBox(height: 8.h),

              // Like/Dislike Buttons
              LikeDislikeButtons(
                isLiked: isLiked,
                isDisliked: isDisliked,
                likeCount: likeCount,
                dislikeCount: dislikeCount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section
        _buildTitleSection(),
        SizedBox(height: 8.h),

        // Stats Line
        StatsSection(
          isExpanded: isExpanded,
          viewerCount: viewerCount,
          likeCount: likeCount,
          audioController: audioController,
        ),

        // Description (if expanded)
        Obx(
          () => isExpanded.value
              ? DescriptionSection(
                  isExpanded: isDescExpanded,
                  audioController: audioController,
                )
              : SizedBox(),
        ),
      ],
    );
  }
}
