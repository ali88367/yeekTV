import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;

class VideoController extends GetxController {
  late vp.VideoPlayerController videoController;
  RxBool isPlaying = false.obs;
  RxBool isMuted = false.obs;
  RxBool isChatVisible = true.obs; // Track chat visibility
  final TextEditingController commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    videoController = vp.VideoPlayerController.network(
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    )..initialize().then((_) {
      update();
    });

    videoController.addListener(() {
      if (videoController.value.isPlaying != isPlaying.value) {
        isPlaying.value = videoController.value.isPlaying;
      }
      // if (videoController.value.volume == 0 !== isMuted.value) {
      //   isMuted.value = videoController.value.volume == 0;
      // }
    });
  }

  void togglePlayPause() {
    if (videoController.value.isPlaying) {
      videoController.pause();
    } else {
      videoController.play();
    }
  }

  void toggleMute() {
    if (isMuted.value) {
      videoController.setVolume(1.0);
    } else {
      videoController.setVolume(0.0);
    }
    isMuted.value = !isMuted.value;
  }

  void toggleFullscreen() {
    if (videoController.value.isInitialized) {
      // Enter fullscreen
      Get.to(() => FullscreenVideoPlayer());
    }
  }

  void toggleChat() {
    isChatVisible.value = !isChatVisible.value;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void onClose() {
    videoController.dispose();
    commentController.dispose();
    super.onClose();
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  final controller = Get.find<VideoController>();

  @override
  void initState() {
    super.initState();
    // Force landscape + hide system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore portrait + show system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.videoController.value.aspectRatio,
              child: vp.VideoPlayer(controller.videoController),
            ),
          ),
          // Exit Fullscreen Button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),
          // Optional: Play/Pause & Progress in Fullscreen
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GetBuilder<VideoController>(
              builder: (ctrl) {
                return Column(
                  children: [
                    vp.VideoProgressIndicator(
                      ctrl.videoController,
                      allowScrubbing: true,
                      colors: const vp.VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => IconButton(
                          icon: Icon(
                            ctrl.isPlaying.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: ctrl.togglePlayPause,
                        )),
                        const SizedBox(width: 16),
                        Obx(() => IconButton(
                          icon: Icon(
                            ctrl.isMuted.value
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: ctrl.toggleMute,
                        )),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VideoController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),

                  // Hide Chat Button
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.toggleChat,
                    icon: Icon(
                      controller.isChatVisible.value
                          ? Icons.chat_bubble
                          : Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      controller.isChatVisible.value ? 'Hide Chat' : 'Show Chat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wall.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              SizedBox(height: 15.h),

              // Video Player with Controls
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  children: [
                    Container(
                      height: 140.h,
                      color: Colors.black,
                      child: GetBuilder<VideoController>(
                        builder: (ctrl) {
                          return ctrl.videoController.value.isInitialized
                              ? vp.VideoPlayer(ctrl.videoController)
                              : const Center(
                            child: CircularProgressIndicator(
                                color: Colors.red),
                          );
                        },
                      ),
                    ),

                    // Video Controls Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Play/Pause
                                Obx(() => GestureDetector(
                                  onTap: controller.togglePlayPause,
                                  child: Icon(
                                    controller.isPlaying.value
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                )),

                                const SizedBox(width: 8),

                                // Progress Text
                                GetBuilder<VideoController>(
                                  builder: (ctrl) {
                                    return Text(
                                      ctrl.videoController.value.isInitialized
                                          ? '${ctrl.formatDuration(ctrl.videoController.value.position)} / ${ctrl.formatDuration(ctrl.videoController.value.duration)}'
                                          : '0:00 / 0:00',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                                const Spacer(),

                                // Mute/Unmute Button
                                Obx(() => GestureDetector(
                                  onTap: controller.toggleMute,
                                  child: Icon(
                                    controller.isMuted.value
                                        ? Icons.volume_off
                                        : Icons.volume_up,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )),

                                const SizedBox(width: 12),

                                // Fullscreen Button
                                GestureDetector(
                                  onTap: controller.toggleFullscreen,
                                  child: const Icon(Icons.fullscreen,
                                      color: Colors.white, size: 20),
                                ),

                                const SizedBox(width: 12),
                                const Icon(Icons.more_vert_sharp,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Progress Bar
                            GetBuilder<VideoController>(
                              builder: (ctrl) {
                                if (ctrl.videoController.value.isInitialized) {
                                  return vp.VideoProgressIndicator(
                                    ctrl.videoController,
                                    allowScrubbing: true,
                                    colors: const vp.VideoProgressColors(
                                      playedColor: Colors.red,
                                      bufferedColor: Colors.grey,
                                      backgroundColor: Colors.white24,
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // Video Info Card
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("80's & 90's Pop Hits",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500)),
                      SizedBox(height: 1.5.h),
                      Text('1,247 watching now',
                          style: TextStyle(color: Colors.black, fontSize: 9.sp)),
                      SizedBox(height: 1.5.h),
                      Text('Started streaming on Dec 2, 2025',
                          style:
                          TextStyle(color: Colors.grey[600], fontSize: 10.sp)),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 15.sp,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 18.sp)),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('DJ Retro',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(width: 4.w),
                                Icon(Icons.check, size: 16.sp),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Text('12.5K subscribers',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 9.sp)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.snackbar('Subscribed!',
                                'You are now subscribed to DJ Retro',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(18)),
                              child: Text('Subscribe',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          _buildActionChip(Icons.remove_red_eye_outlined, '425'),
                          const SizedBox(width: 8),
                          _buildActionChip(Icons.share, '187'),
                        ],
                      ),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 6.h),

              // Live Chat Section - Conditionally Shown
              Obx(() => controller.isChatVisible.value
                  ? Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Chat Header
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Live Chat',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.eye_fill,
                                          color: Colors.red, size: 13.sp),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '1.2kP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Colors.grey, height: 1),

                      // Chat Messages
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildChatMessage(
                              'MusicLover23',
                              'This song is amazing!',
                              'SUBSCRIBER',
                              '1w ago',
                              '15',
                            ),
                            const SizedBox(height: 16),
                            _buildChatMessage(
                              'DJ Retro',
                              'Wooo I\'m so sexy omg! Thanks for tuning in to 80\'s & 90\'s Pop Hits',
                              'SUBSCRIBER',
                              'VERIFIED',
                              '12',
                              isCreator: true,
                              showHostBadge: true,
                            ),
                            const SizedBox(height: 16),
                            _buildChatMessage(
                              'RetroFan88',
                              'Love this playlist! Takes me back',
                              '',
                              '2d ago',
                              '8',
                            ),
                            const SizedBox(height: 16),
                            _buildChatMessage(
                              'NostalgiaKing',
                              'Best stream ever!',
                              'SUBSCRIBER',
                              '3d ago',
                              '23',
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: Color(0xFF2A2A2A), height: 1),

                      // Comment Input
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.defaultDialog(
                                    title: 'Add Comment',
                                    content: TextField(
                                      controller:
                                      controller.commentController,
                                      decoration: const InputDecoration(
                                        hintText: 'Write your comment...',
                                      ),
                                    ),
                                    textConfirm: 'Send',
                                    onConfirm: () {
                                      Get.back();
                                      Get.snackbar(
                                        'Comment Sent',
                                        'Your comment has been posted',
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Add a comment...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Get.snackbar(
                                  'Comment Sent',
                                  'Your comment has been posted',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : const SizedBox.shrink()), // Hide chat entirely
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildActionChip(IconData icon, String count) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
    decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Icon(icon, color: Colors.white, size: 16),
      const SizedBox(width: 6),
      Text(count,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
  );

  Widget _buildChatMessage(
      String username,
      String message,
      String badge1,
      String badge2,
      String replyCount, {
        bool isCreator = false,
        bool showHostBadge = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCreator ? Colors.blue : Colors.red,
              child: Text(
                username[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (badge1.isNotEmpty)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badge1 == 'SUBSCRIBER'
                                ? Colors.red
                                : Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isCreator && badge2.isNotEmpty)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (showHostBadge)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (!isCreator && badge2.isNotEmpty)
                        Text(
                          badge2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        replyCount,
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Get.snackbar(
                            'Reply',
                            'Reply to $username',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'REPLY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}