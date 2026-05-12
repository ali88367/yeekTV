import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Tab change pe rebuild
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _getCurrentTabContent() {
    switch (_tabController.index) {
      case 0:
        return GridViewWidget();
      case 1:
        return GridViewWidget();
      case 2:
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'No items for sale yet.',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'YeekItalic',
              ),
            ),
          ),
        );
      case 3:
        return MessagingSection(); // ⭐ New messaging section
      default:
        return GridViewWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          width: double.infinity,
          color: Color(0xFF0f0f0f),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: ImageIcon(
                  AssetImage('assets/g.png'),
                  size: 28.sp,
                  color: _tabController.index == 0
                      ? Color.fromRGBO(239, 191, 4, 1) // gold
                      : Colors.white, // unselected
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.play_arrow,
                  size: 40.sp,
                  color: _tabController.index == 1
                      ? Color.fromRGBO(239, 191, 4, 1)
                      : Colors.white,
                ),
              ),
              Tab(
                icon: ImageIcon(
                  AssetImage('assets/at.png'),
                  size: 28.sp,
                  color: _tabController.index == 2
                      ? Color.fromRGBO(239, 191, 4, 1)
                      : Colors.white,
                ),
              ),
              Tab(
                icon: ImageIcon(
                  AssetImage('assets/message.png'),
                  size: 28.sp,
                  color: _tabController.index == 3
                      ? Color.fromRGBO(239, 191, 4, 1)
                      : Colors.white,
                ),
              ),
            ],
            indicator: BoxDecoration(), // no indicator
            labelPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
            ), // only icons ke beech space
            indicatorPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
          ),
        ),

        // Dynamic Content
        _getCurrentTabContent(),
      ],
    );
  }
}

class GridViewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
        childAspectRatio: 0.6,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        int row = index ~/ 3;
        int col = index % 3;

        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF0f0f0f),
            border: Border(
              top: row == 0
                  ? BorderSide(color: Colors.grey.shade700, width: 1)
                  : BorderSide.none,
              left: col == 0
                  ? BorderSide(color: Colors.grey.shade700, width: 1)
                  : BorderSide.none,
              right: BorderSide(color: Colors.grey.shade700, width: 1),
              bottom: BorderSide(color: Colors.grey.shade700, width: 1),
            ),
          ),
          child: Center(
            child: Text(
              '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ⭐ Messaging Section Widget
class MessagingSection extends StatefulWidget {
  @override
  _MessagingSectionState createState() => _MessagingSectionState();
}

class _MessagingSectionState extends State<MessagingSection> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [
    Message(
      username: 'TheDrumMajor',
      text: 'Hey! Thanks for reaching out!',
      isUser: false,
      avatarColor: Colors.yellow,
    ),
    Message(
      username: 'You',
      text: 'Love your content! Keep it up!',
      isUser: true,
      avatarColor: Color.fromRGBO(239, 191, 4, 1),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          Message(
            username: 'You',
            text: _messageController.text,
            isUser: true,
            avatarColor: Color.fromRGBO(239, 191, 4, 1),
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.h,
      color: Color(0xFF0f0f0f),
      child: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Input
          Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Color(0xFF1a1a1a),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade800, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(21, 21, 21, 1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Color.fromRGBO(35, 35, 35, 1),
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          // Avatar for other user
          if (!message.isUser) ...[
            CircleAvatar(radius: 16.sp, backgroundColor: message.avatarColor),
            SizedBox(width: 8.w),
          ],

          // Message Box (username + message)
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: message.isUser ? Color(0xFF3f3512) : Color(0xFF2a2a2a),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: message.isUser ? Color(0xFFf2c316) : Color(0xFF2a2a2a),
                  width: 2.h,
                ),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    if (!message.isUser)
                      TextSpan(
                        text: '${message.username}: ',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    TextSpan(
                      text: message.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Avatar for self
          if (message.isUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.sp,
              backgroundColor: message.avatarColor,
              child: Text(
                'Y',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Message Model
class Message {
  final String username;
  final String text;
  final bool isUser;
  final Color avatarColor;

  Message({
    required this.username,
    required this.text,
    required this.isUser,
    required this.avatarColor,
  });
}
