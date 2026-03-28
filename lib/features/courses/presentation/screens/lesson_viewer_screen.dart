import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
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
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
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

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.lesson.title),
            elevation: 0,
          ),
          body: Column(
            children: [
              player, // The Video Player
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('وصف الدرس', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        verticalSpace(8),
                        const Text('مشاهدة ممتعة! لا تتردد في ترك سؤالك في التعليقات بالأسفل.', style: TextStyle(color: Colors.grey)),
                        verticalSpace(24),
                        const Divider(),
                        Text('التعليقات والأسئلة', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        verticalSpace(16),
                        _buildCommentInput(),
                        verticalSpace(20),
                        _buildCommentsList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),
        horizontalSpace(10),
        IconButton(
          onPressed: _sendComment,
          icon: const Icon(Icons.send, color: Colors.blue),
        ),
      ],
    );
  }

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      final uId = CacheHelper.getData(key: 'uId');
      final userName = CacheHelper.getData(key: 'userName') ?? 'طالب';
      
      final comment = CommentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uId,
        userName: userName,
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
        if (comments.isEmpty) return const Center(child: Text('لا توجد تعليقات بعد. كن أول من يسأل!'));
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  verticalSpace(4),
                  Text(comment.content),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
