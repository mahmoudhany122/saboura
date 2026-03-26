import 'dart:io';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../domain/entities/course_entity.dart';

class LessonViewerScreen extends StatefulWidget {
  final LessonEntity lesson;
  const LessonViewerScreen({super.key, required this.lesson});

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializeContent();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.lesson.videoUrl != null && widget.lesson.videoUrl!.isNotEmpty) {
      return _buildVideoPlayer();
    } else if (widget.lesson.pdfUrl != null && widget.lesson.pdfUrl!.isNotEmpty) {
      return _buildPdfViewer();
    } else {
      return const Center(child: Text('لا يوجد محتوى لعرضه في هذا الدرس'));
    }
  }

  Widget _buildVideoPlayer() {
    if (_youtubeController == null) return const Center(child: Text('رابط غير صالح'));
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _youtubeController!),
      builder: (context, player) => Column(children: [player, const SizedBox(height: 20), const Text('مشاهدة ممتعة يا بطل!')]),
    );
  }

  Widget _buildPdfViewer() {
    // Check if the URL is local (file path) or remote
    bool isNetwork = widget.lesson.pdfUrl!.startsWith('http');
    
    return Column(
      children: [
        Expanded(
          child: isNetwork 
            ? SfPdfViewer.network(widget.lesson.pdfUrl!)
            : SfPdfViewer.file(File(widget.lesson.pdfUrl!)),
        ),
      ],
    );
  }
}
