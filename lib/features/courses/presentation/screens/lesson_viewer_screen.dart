import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/helpers/gemini_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

class LessonViewerScreen extends StatefulWidget {
  final LessonEntity lesson;
  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  YoutubePlayerController? _youtubeController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeContent();
    context.read<CoursesCubit>().getLessonComments(widget.lesson.id);
  }

  void _initializeContent() {
    if (widget.lesson.videoUrl != null && widget.lesson.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _showAiTutor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AiChatBottomSheet(lessonTitle: widget.lesson.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.lesson.title), elevation: 0),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAiTutor,
            backgroundColor: Colors.purple,
            child: const Icon(Icons.psychology, color: Colors.white, size: 35),
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('وصف الدرس', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      verticalSpace(8),
                      const Text('مشاهدة ممتعة! اضغط على أيقونة الذكاء الاصطناعي لسؤالي عن أي شيء يصعب عليك. 🤖'),
                      verticalSpace(24),
                      const Divider(),
                      _buildCommentsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التعليقات', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        verticalSpace(16),
        _buildCommentInput(),
        verticalSpace(20),
        _buildCommentsList(),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'اكتب سؤالك هنا...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        IconButton(onPressed: _sendComment, icon: const Icon(Icons.send, color: Colors.blue)),
      ],
    );
  }

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      final uId = CacheHelper.getData(key: 'uId');
      final comment = CommentEntity(
        id: DateTime.now().toString(),
        userId: uId!,
        userName: CacheHelper.getData(key: 'userName') ?? 'طالب',
        lessonId: widget.lesson.id,
        content: _commentController.text,
        timestamp: DateTime.now(),
      );
      context.read<CoursesCubit>().addComment(comment);
      _commentController.clear();
    }
  }

  Widget _buildCommentsList() {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        final comments = context.read<CoursesCubit>().lessonComments;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              title: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(comment.content),
            );
          },
        );
      },
    );
  }
}

class AiChatBottomSheet extends StatefulWidget {
  final String lessonTitle;
  const AiChatBottomSheet({super.key, required this.lessonTitle});

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage});
      _isLoading = true;
    });
    _controller.clear();

    final response = await GeminiHelper.getAiResponse(userMessage, widget.lessonTitle);

    setState(() {
      _messages.add({'role': 'ai', 'content': response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          verticalSpace(15),
          Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.psychology, color: Colors.white)),
              horizontalSpace(10),
              Text('سبورة الذكي 🤖', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg['role'] == 'user';
                return FadeInUp(
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isUser ? ColorsManager.mainBlue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(msg['content']!, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(color: Colors.purple),
          verticalSpace(10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'اسأل سبورة الذكي...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              horizontalSpace(10),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
