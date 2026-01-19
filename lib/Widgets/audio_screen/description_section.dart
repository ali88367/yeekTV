import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../Controller/audio_player_controller.dart';

class DescriptionSection extends StatelessWidget {
  final RxBool isExpanded;
  final AudioPlayerController audioController;

  const DescriptionSection({
    Key? key,
    required this.isExpanded,
    required this.audioController,
  }) : super(key: key);

  String _filterDescription(String description) {
    if (description.isEmpty) return description;

    // Split description into lines
    final lines = description.split('\n');

    // Filter out lines containing "youtube" or "provided by youtube" (case-insensitive)
    final filteredLines = lines.where((line) {
      final lowerLine = line.toLowerCase().trim();
      return !lowerLine.contains('youtube') &&
          !lowerLine.contains('provided by youtube');
    }).toList();

    // Join filtered lines back together
    return filteredLines.join('\n').trim();
  }

  @override
  Widget build(BuildContext context) {
    final rawDescription =
        audioController.currentTrack.value?.description ??
        'Live radio streaming with synchronized playback across all listeners. '
            'Enjoy curated playlists and real-time track updates.';

    // Filter out YouTube-related lines
    final description = _filterDescription(rawDescription);
    final hasMoreDescription = description.length > 200;

    return Obx(
      () => Padding(
        padding: EdgeInsets.only(top: 16.h, left: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description.isEmpty ? "No description added" : description,
              style: TextStyle(
                fontFamily: 'YeekBold',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: isExpanded.value ? null : 7,
              overflow: isExpanded.value
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
            ),
            if (hasMoreDescription)
              GestureDetector(
                onTap: () {
                  isExpanded.value = !isExpanded.value;
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    isExpanded.value ? "Show less" : "...more",
                    style: TextStyle(
                      fontFamily: 'YeekBold',
                      fontSize: 14.sp,
                      color: const Color(0xFFEFBF04),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}
