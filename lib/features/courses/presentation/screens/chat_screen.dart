import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/message_entity.dart';

class ChatScreen extends StatefulWidget {
  final String otherId;
  final String otherName;

  const ChatScreen({super.key, required this.otherId, required this.otherName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getChatMessages(uId, widget.otherId);
    }
  }

  void _sendMessage() {
    if (_controller.text.isEmpty) return;
    final uId = CacheHelper.getData(key: 'uId');
    final uName = CacheHelper.getData(key: 'userName') ?? 'مستخدم';

    final message = MessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: uId!,
      senderName: uName,
      receiverId: widget.otherId,
      content: _controller.text,
      timestamp: DateTime.now(),
    );

    context.read<CoursesCubit>().sendMessage(message);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(widget.otherName),
        centerTitle: true,
        actions: [IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CoursesCubit, CoursesState>(
              builder: (context, state) {
                final messages = context.read<CoursesCubit>().chatMessages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(20.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == CacheHelper.getData(key: 'uId');
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputSection(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageEntity msg, bool isMe) {
    return FadeInRight(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isMe ? ColorsManager.mainBlue : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isMe ? 20 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 20),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14.sp)),
              verticalSpace(4),
              Text(DateFormat('hh:mm a').format(msg.timestamp), 
                style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10.sp)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
            ),
          ),
          horizontalSpace(10),
          CircleAvatar(
            backgroundColor: ColorsManager.mainBlue,
            child: IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }
}
