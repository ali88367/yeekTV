import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/audio_player_controller.dart';

class StatsSection extends StatelessWidget {
  final RxBool isExpanded;
  final RxInt viewerCount;
  final RxInt likeCount;
  final AudioPlayerController audioController;

  const StatsSection({
    Key? key,
    required this.isExpanded,
    required this.viewerCount,
    required this.likeCount,
    required this.audioController,
  }) : super(key: key);

  Widget _buildStatBox(BuildContext context, String value, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      padding: EdgeInsets.symmetric(vertical: 9.h),
      decoration: BoxDecoration(
        color: const Color(0xFF212121),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'YeekBold',
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.33,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'YeekBold',
              fontSize: 12.sp,
              color: const Color(0xFFcccccc),
              height: 1.29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLine() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.only(left: 5.w, bottom: 8.h),
        child: Row(
          mainAxisAlignment: isExpanded.value
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                "${viewerCount.value} watching",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFaaaaaa),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              " • ",
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFFaaaaaa)),
            ),
            Flexible(
              child: Text(
                "Started 4h ago",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFaaaaaa),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isExpanded.value) ...[
              Text(
                " • ",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFaaaaaa),
                ),
              ),
              GestureDetector(
                onTap: () {
                  isExpanded.value = true;
                },
                child: Text(
                  "...more",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFEFBF04),
                  ),
                ),
              ),
            ] else
              Padding(
                padding: EdgeInsets.only(left: 50.w),
                child: GestureDetector(
                  onTap: () {
                    isExpanded.value = false;
                  },
                  child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedStats(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatBox(context, likeCount.value.toString(), "Likes"),
          _buildStatBox(context, viewerCount.value.toString(), "Viewers"),
          Obx(
            () => _buildStatBox(
              context,
              audioController.currentTrack.value?.year.toString() ?? "1988",
              "Year",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatsLine(),
        Obx(() => isExpanded.value ? _buildExpandedStats(context) : SizedBox()),
      ],
    );
  }
}
