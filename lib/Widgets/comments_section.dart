import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({Key? key}) : super(key: key);

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final RxList<Map<String, dynamic>> chatMessages = <Map<String, dynamic>>[
    {
      'username': 'Mark Love23',
      'message': 'This song is amazing!',
      'badge1': 'SUBSCRIBER',
      'badge2': '1h ago',
      'likes': 4,
      'replies': [],
      'avatarColor': Colors.red,
      'isLiked': false,
    },
    {
      'username': 'DJ Retro',
      'message': 'Welcome everyone! Thanks for tuning in!',
      'badge1': 'SUBSCRIBER',
      'badge2': 'HOST',
      'likes': 12,
      'replies': [],
      'avatarColor': Colors.blue,
      'isHost': true,
      'showVerified': true,
      'isLiked': false,
    },
  ].obs;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      chatMessages.insert(0, {
        'username': 'You',
        'message': _commentController.text.trim(),
        'badge1': '',
        'badge2': 'Just now',
        'likes': 0,
        'replies': [],
        'avatarColor': Colors.green,
        'isLiked': false,
      });
      _commentController.clear();
      chatMessages.refresh();
    }
  }

  void _toggleLike(int index) {
    final message = chatMessages[index];
    message['isLiked'] = !(message['isLiked'] ?? false);
    message['likes'] = (message['likes'] ?? 0) + (message['isLiked'] ? 1 : -1);
    chatMessages.refresh();
  }

  void _showTipModal() {
    Get.dialog(
      const TipModalDialog(),
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
    );
  }

  Widget _buildTipButton() {
    return GestureDetector(
      onTap: _showTipModal,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.black,
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tip',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3f3f3f), width: 2)),
        color: Colors.black,
      ),
      child: Container(
        decoration: BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.black],
          ),
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: const Color(0xFF3f3f3f), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Input Field (Expanded to take available space)
            Expanded(
              child: TextField(
                controller: _commentController,
                style: TextStyle(
                  fontSize:
                      16.sp, // 16px minimum for iOS Safari (prevents zoom)
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: 'Chat...',
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),

            // Heart Icon (Inside input)
            GestureDetector(
              onTap: () {
                // Handle heart action
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),

            // Send Icon (Inside input)
            GestureDetector(
              onTap: _addComment,
              child: Container(
                width: 46.w,
                height: 46.h,

                child: Image.asset(
                  'assets/send icon.png',
                  width: 36.w,
                  height: 36.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Tip Button (Inside input, right edge)
            Padding(
              padding: EdgeInsets.only(right: 8.w, left: 4.w),
              child: _buildTipButton(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFF3f3f3f), width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF3f3f3f), width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    fontFamily: 'YeekBold',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${chatMessages.length}',
                  style: TextStyle(
                    fontFamily: 'YeekBold',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFaaaaaa),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: Obx(
              () => chatMessages.isEmpty
                  ? Center(
                      child: Text(
                        'No comments yet',
                        style: TextStyle(
                          fontFamily: 'YeekBold',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFaaaaaa),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      padding: EdgeInsets.all(12.w),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = chatMessages[index];
                        return _buildMessageItem(message, index);
                      },
                    ),
            ),
          ),

          // Input Section
          _buildCommentInputSection(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20.r,
            backgroundColor: message['avatarColor'] ?? Colors.grey,
            child: Text(
              (message['username'] as String? ?? 'U')[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  message['username'] ?? 'User',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Message text
                Text(
                  message['message'] ?? '',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),

                // Like button
                GestureDetector(
                  onTap: () => _toggleLike(index),
                  child: Row(
                    children: [
                      Icon(
                        message['isLiked'] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: message['isLiked'] == true
                            ? Colors.red
                            : const Color(0xFF888888),
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${message['likes'] ?? 0}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Tip Modal Dialog
class TipModalDialog extends StatefulWidget {
  const TipModalDialog({Key? key}) : super(key: key);

  @override
  State<TipModalDialog> createState() => _TipModalDialogState();
}

class _TipModalDialogState extends State<TipModalDialog> {
  final Rxn<int> selectedTip = Rxn<int>();
  final TextEditingController _customTipController = TextEditingController();
  final TextEditingController _tipMessageController = TextEditingController();
  final RxString customTipText = ''.obs;

  final List<int> tipAmounts = [5, 10, 20, 50, 100, 200];

  @override
  void dispose() {
    _customTipController.dispose();
    _tipMessageController.dispose();
    super.dispose();
  }

  void _handleSendTip() {
    final amount = selectedTip.value != null
        ? selectedTip.value!.toDouble()
        : (double.tryParse(_customTipController.text) ?? 0);

    if (amount > 0) {
      // Handle tip sending logic
      print('Sending tip: \$${amount.toStringAsFixed(2)}');
      print('Message: ${_tipMessageController.text}');

      // Close dialog
      Get.back();

      // Reset
      selectedTip.value = null;
      customTipText.value = '';
      if (mounted) {
        _customTipController.clear();
        _tipMessageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a1a),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Body
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B), // Red
            Color(0xFFFF8E53), // Orange
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Send a Tip',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip Amount Grid
          _buildTipAmountGrid(),

          SizedBox(height: 20.h),

          // Custom Amount Input
          _buildCustomInput(),

          SizedBox(height: 16.h),

          // Message Input
          _buildMessageInput(),

          SizedBox(height: 20.h),

          // Send Button
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTipAmountGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 2.5,
      ),
      itemCount: tipAmounts.length,
      itemBuilder: (context, index) {
        final amount = tipAmounts[index];
        return Obx(() {
          final isSelected = selectedTip.value == amount;
          return GestureDetector(
            onTap: () {
              selectedTip.value = amount;
              _customTipController.clear();
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3a1a1a)
                    : const Color(0xFF2a2a2a),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF444444),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B6B).withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '\$$amount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildCustomInput() {
    return Obx(
      () => TextField(
        controller: _customTipController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'Custom amount',
          hintStyle: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFaaaaaa),
          ),
          filled: true,
          fillColor: const Color(0xFF2a2a2a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: customTipText.value.isNotEmpty
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF444444),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: customTipText.value.isNotEmpty
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF444444),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        onChanged: (value) {
          customTipText.value = value;
          if (value.isNotEmpty) {
            selectedTip.value = null;
          }
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      controller: _tipMessageController,
      maxLines: 3,
      maxLength: 150,
      style: TextStyle(fontSize: 16.sp, color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Add a message (optional)',
        hintStyle: TextStyle(fontSize: 16.sp, color: const Color(0xFFaaaaaa)),
        filled: true,
        fillColor: const Color(0xFF2a2a2a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF444444), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF444444), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        contentPadding: EdgeInsets.all(16.w),
        counterStyle: TextStyle(
          color: const Color(0xFFaaaaaa),
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final amount = selectedTip.value != null
          ? selectedTip.value!.toDouble()
          : (double.tryParse(_customTipController.text) ?? 0);
      final isEnabled = amount > 0;

      return GestureDetector(
        onTap: isEnabled ? _handleSendTip : null,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  )
                : null,
            color: isEnabled ? null : const Color(0xFF555555),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              'Send \$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    });
  }
}
