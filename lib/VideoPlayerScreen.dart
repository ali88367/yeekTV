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
  RxBool isChatVisible = true.obs;
  RxList<dynamic> chatMessages = [
    {
      'username': 'Mark Love23',
      'message': 'This song is amazing!',
      'badge1': 'SUBSCRIBER',
      'badge2': '1h ago',
      'likes': 4,
      'replies': [],
      'avatarColor': Colors.red,
      'isLiked': false
    },
    {
      'username': 'DJ Retro',
      'message': 'Welcome everyone! Thanks for tuning in to 80\'s & 90\'s Pop Hits',
      'badge1': 'SUBSCRIBER',
      'badge2': 'HOST',
      'likes': 12,
      'replies': [],
      'avatarColor': Colors.blue,
      'isHost': true,
      'showVerified': true,
      'isLiked': false
    }
  ].obs;

  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  RxString replyToUsername = ''.obs;

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
      Get.to(() => FullscreenVideoPlayer());
    }
  }

  void toggleChat() {
    isChatVisible.value = !isChatVisible.value;
  }

  void toggleLikeMessage(int index) {
    chatMessages[index]['isLiked'] = !(chatMessages[index]['isLiked'] ?? false);
    chatMessages[index]['likes'] += chatMessages[index]['isLiked'] ? 1 : -1;
    chatMessages.refresh();
  }

  void addComment(String comment) {
    if (comment.trim().isNotEmpty) {
      chatMessages.insert(0, {
        'username': 'You',
        'message': comment,
        'badge1': '',
        'badge2': 'Just now',
        'likes': 0,
        'replies': [],
        'avatarColor': Colors.green,
        'isLiked': false
      });
      commentController.clear();
      chatMessages.refresh();
    }
  }

  void addReply(int parentIndex, String reply) {
    if (reply.trim().isNotEmpty) {
      chatMessages[parentIndex]['replies'].add({
        'username': 'You',
        'message': reply,
        'likes': 0,
        'isLiked': false
      });
      replyController.clear();
      replyToUsername.value = '';
      chatMessages.refresh();
    }
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
    replyController.dispose();
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
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
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),
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
                            ctrl.isPlaying.value ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: ctrl.togglePlayPause,
                        )),
                        const SizedBox(width: 16),
                        Obx(() => IconButton(
                          icon: Icon(
                            ctrl.isMuted.value ? Icons.volume_off : Icons.volume_up,
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Obx(() => ElevatedButton.icon(
                    onPressed: controller.toggleChat,
                    icon: Icon(
                      controller.isChatVisible.value ? Icons.chat_bubble : Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      controller.isChatVisible.value ? 'Hide Chat' : 'Show Chat',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2A2A),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          image: DecorationImage(image: AssetImage('assets/wall.jpg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(children: [
            SizedBox(height: 15.h),
            // Video Player
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(children: [
                Container(
                  height: 140.h,
                  color: Colors.black,
                  child: GetBuilder<VideoController>(
                    builder: (ctrl) => ctrl.videoController.value.isInitialized
                        ? vp.VideoPlayer(ctrl.videoController)
                        : const Center(child: CircularProgressIndicator(color: Colors.red)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(children: [
                      Row(children: [
                        Obx(() => GestureDetector(
                          onTap: controller.togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8)],
                            ),
                            child: Icon(
                              controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )),
                        const SizedBox(width: 8),
                        GetBuilder<VideoController>(
                          builder: (ctrl) => Text(
                            ctrl.videoController.value.isInitialized
                                ? '${ctrl.formatDuration(ctrl.videoController.value.position)} / ${ctrl.formatDuration(ctrl.videoController.value.duration)}'
                                : '0:00 / 0:00',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Spacer(),
                        Obx(() => GestureDetector(
                          onTap: controller.toggleMute,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.white, Colors.grey]),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.isMuted.value ? Icons.volume_off : Icons.volume_up,
                              color: Colors.black87,
                              size: 20,
                            ),
                          ),
                        )),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: controller.toggleFullscreen,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // GestureDetector(
                        //   onTap: () => Get.bottomSheet(
                        //     Container(
                        //       decoration: const BoxDecoration(
                        //         color: Color(0xFF2A2A2A),
                        //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        //       ),
                        //       child: Column(mainAxisSize: MainAxisSize.min, children: [
                        //         ListTile(
                        //           leading: const Icon(Icons.share, color: Colors.white),
                        //           title: const Text('Share', style: TextStyle(color: Colors.white)),
                        //           onTap: () {
                        //             Get.back();
                        //             Get.snackbar('Shared!', 'Video shared successfully');
                        //           },
                        //         ),
                        //         ListTile(
                        //           leading: const Icon(Icons.download, color: Colors.white),
                        //           title: const Text('Download', style: TextStyle(color: Colors.white)),
                        //           onTap: () {
                        //             Get.back();
                        //             Get.snackbar('Downloading...', 'Download started');
                        //           },
                        //         ),
                        //         ListTile(
                        //           leading: const Icon(Icons.flag, color: Colors.white),
                        //           title: const Text('Report', style: TextStyle(color: Colors.white)),
                        //           onTap: () {
                        //             Get.back();
                        //             Get.snackbar('Reported', 'Content reported');
                        //           },
                        //         ),
                        //       ]),
                        //     ),
                        //   ),
                        //   child: Container(
                        //     padding: const EdgeInsets.all(6),
                        //     decoration: BoxDecoration(
                        //       gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.purple.shade600]),
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: const Icon(Icons.more_vert_sharp, color: Colors.white, size: 20),
                        //   ),
                        // ),
                      ]),
                      const SizedBox(height: 4),
                      GetBuilder<VideoController>(
                        builder: (ctrl) => ctrl.videoController.value.isInitialized
                            ? vp.VideoProgressIndicator(
                          ctrl.videoController,
                          allowScrubbing: true,
                          colors: const vp.VideoProgressColors(
                            playedColor: Colors.red,
                            bufferedColor: Colors.grey,
                            backgroundColor: Colors.white24,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        )
                            : const SizedBox.shrink(),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
            SizedBox(height: 8.h),
            // Video Info Card
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("80's & 90's Pop Hits", style: TextStyle(color: Colors.black, fontSize: 15.sp, fontWeight: FontWeight.w500)),
                    SizedBox(height: 1.5.h),
                    Text('1,247 watching now', style: TextStyle(color: Colors.black, fontSize: 9.sp)),
                    SizedBox(height: 1.5.h),
                    Text('Started streaming on Dec 2, 2025', style: TextStyle(color: Colors.grey[600], fontSize: 10.sp)),
                    SizedBox(height: 6.h),
                    Row(children: [
                      CircleAvatar(radius: 15.sp, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white, size: 18.sp)),
                      SizedBox(width: 6.w),
                      Expanded(child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('DJ Retro', style: TextStyle(color: Colors.black, fontSize: 10.sp, fontWeight: FontWeight.w500)),
                          SizedBox(width: 4.w),
                          Icon(Icons.check, size: 16.sp, color: Colors.blue),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text('12.5K subscribers', style: TextStyle(color: Colors.grey, fontSize: 9.sp)),
                            ),
                          ),
                        ],
                      )),
                      GestureDetector(
                        onTap: () => Get.snackbar('Subscribed!', 'You are now subscribed to DJ Retro', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 2)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(18)),
                          child: Text('Subscribe', style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ]),
                    SizedBox(height: 6.h),
                    Row(children: [
                      _buildActionChip(Icons.remove_red_eye_outlined, '425'),
                      const SizedBox(width: 8),
                      _buildActionChip(Icons.share, '187'),
                    ]),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            // Live Chat with Reply
            Obx(() => controller.isChatVisible.value
                ? Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.grey[100]!]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.grey[50]!]),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)])),
                      const SizedBox(width: 8),
                      const Text('Live Chat', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        Icon(CupertinoIcons.eye_fill, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        const Text('1.2K', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ]),
                ),
                Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.grey.shade300, Colors.transparent]))),
                // Messages
                Expanded(child: Container(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.grey[50]!, Colors.white])),
                  child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.chatMessages.length,
                    itemBuilder: (context, index) => _buildStyledChatMessage(controller, index),
                  )),
                )),
                Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.grey.shade300, Colors.transparent]))),
                // Input
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.grey[50]!]),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(
                      controller: controller.commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey[300]!)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (value) => controller.addComment(value),
                    )),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => controller.addComment(controller.commentController.text),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ),
              ]),
            ))
                : const SizedBox.shrink()),
          ]),
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String count) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
    decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Icon(icon, color: Colors.white, size: 16),
      const SizedBox(width: 6),
      Text(count, style: const TextStyle(color: Colors.white, fontSize: 12)),
    ]),
  );

  // FULLY COMPLETE CHAT MESSAGE WITH REPLY
  Widget _buildStyledChatMessage(VideoController controller, int index) {
    final message = controller.chatMessages[index];
    final isLiked = message['isLiked'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [(message['avatarColor'] as Color).withOpacity(0.8), message['avatarColor'] as Color]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: (message['avatarColor'] as Color).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Center(
              child: Text(message['username'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, runSpacing: 4, children: [
              Text(message['username'], style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
              if (message['badge1'] != '') ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600]),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Text(message['badge1'], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ],
              if (message['showVerified'] == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: const Text('Check', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
              if (message['isHost'] == true) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.purple.shade600]),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))],
                  ),
                  child: Text(message['badge2'], style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ],
            ]),
            const SizedBox(height: 4),
            Text(message['message'], style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
          ])),
        ]),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            GestureDetector(
              onTap: () => controller.toggleLikeMessage(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: isLiked
                      ? LinearGradient(colors: [Colors.red.shade400, Colors.red.shade600])
                      : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade200]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(Icons.favorite, color: isLiked ? Colors.white : Colors.grey[700], size: 16),
                  const SizedBox(width: 4),
                  Text('${message['likes']}', style: TextStyle(color: isLiked ? Colors.white : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                controller.replyToUsername.value = message['username'];
                controller.replyController.text = '@${message['username']} ';
                Get.bottomSheet(
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Reply to ${message['username']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller.replyController,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          autofocus: true,
                        ),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text('Cancel'))),
                          ElevatedButton(
                            onPressed: () {
                              controller.addReply(index, controller.replyController.text);
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Reply', style: TextStyle(color: Colors.white)),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                  isScrollControlled: true,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue.shade400, Colors.blue.shade600]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.reply, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('${message['replies'].length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ),
          ]),
          Text(
            message['isHost'] == true ? 'Just now' : message['badge2'],
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ]),
        // Render Replies
        if (message['replies'].isNotEmpty) ...[
          const SizedBox(height: 8),
          ...message['replies'].map<Widget>((reply) {
            final replyLiked = reply['isLiked'] ?? false;
            return Container(
              margin: const EdgeInsets.only(left: 32, top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('Y', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(reply['username'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(reply['message'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      reply['isLiked'] = !replyLiked;
                      reply['likes'] = (reply['likes'] ?? 0) + (replyLiked ? -1 : 1);
                      controller.chatMessages.refresh();
                    },
                    child: Row(children: [
                      Icon(Icons.favorite, size: 14, color: replyLiked ? Colors.red : Colors.grey),
                      const SizedBox(width: 4),
                      Text('${reply['likes'] ?? 0}', style: const TextStyle(fontSize: 11)),
                    ]),
                  ),
                ])),
              ]),
            );
          }).toList(),
        ],
      ]),
    );
  }
}