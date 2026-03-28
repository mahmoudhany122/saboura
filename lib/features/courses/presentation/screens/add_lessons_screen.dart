import 'dart:io';
import 'dart:developer';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../widgets/lesson_form_dialog.dart';

class AddLessonsScreen extends StatefulWidget {
  final Map<String, dynamic> courseData;
  const AddLessonsScreen({super.key, required this.courseData});

  @override
  State<AddLessonsScreen> createState() => _AddLessonsScreenState();
}

class _AddLessonsScreenState extends State<AddLessonsScreen> {
  final List<LessonEntity> _lessons = [];
  bool _isUploading = false;
  bool _isSavingFinal = false;

  @override
  void initState() {
    super.initState();
    if (widget.courseData['modules'] != null &&
        (widget.courseData['modules'] as List).isNotEmpty) {
      final existingLessons =
          (widget.courseData['modules'] as List<ModuleEntity>)[0].lessons;
      _lessons.addAll(existingLessons);
    }
  }

  Future<void> _pickAndUploadPDF(
      StateSetter setLocalState, Function(String) onUploaded) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setLocalState(() => _isUploading = true);
        setState(() => _isUploading = true);

        final file = File(result.files.single.path!);
        final fileName = 'pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf';

        final url = await context.read<CoursesCubit>().uploadFile(file, fileName);

        setLocalState(() => _isUploading = false);
        setState(() => _isUploading = false);

        if (url != null) {
          onUploaded(url);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع ملف PDF بنجاح!'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      log("Upload Error: $e");
      setLocalState(() => _isUploading = false);
      setState(() => _isUploading = false);
    }
  }

  void _addFullLesson() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LessonFormDialog(
          isUploading: _isUploading,
          onPickPdf: _pickAndUploadPDF,
          onSave: (title, videoUrl, pdfUrl, quiz) {
            setState(() {
              _lessons.add(LessonEntity(
                id: DateTime.now().toString(),
                title: title,
                videoUrl: videoUrl,
                pdfUrl: pdfUrl,
                quiz: quiz,
              ));
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(title: Text('محتوى: ${widget.courseData['title']}')),
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is CourseAddedSuccess) {
            setState(() => _isSavingFinal = false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('تم حفظ الكورس بنجاح! 🚀'),
                backgroundColor: Colors.green));
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (state is CoursesError) {
            setState(() => _isSavingFinal = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('حدث خطأ: ${state.error}'), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: _lessons.isEmpty
                  ? const Center(child: Text('ابدأ بإضافة درسك الأول'))
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) => _buildLessonCard(index),
                    ),
            ),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(int index) {
    final lesson = _lessons[index];
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => setState(() => _lessons.removeAt(index)),
        ),
        children: [
          if (lesson.videoUrl != null) const ListTile(leading: Icon(Icons.play_circle, color: Colors.red), title: Text('فيديو الدرس')),
          if (lesson.pdfUrl != null) const ListTile(leading: Icon(Icons.picture_as_pdf, color: Colors.orange), title: Text('ملف PDF')),
          if (lesson.quiz != null) const ListTile(leading: Icon(Icons.quiz, color: Colors.green), title: Text('اختبار')),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: _isSavingFinal ? null : _addFullLesson,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('إضافة درس جديد', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue, minimumSize: Size(double.infinity, 56.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
          verticalSpace(10),
          OutlinedButton(
            onPressed: (_isSavingFinal || _lessons.isEmpty) ? null : _saveAll,
            style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 56.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _isSavingFinal
                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : const Text('حفظ كافة التعديلات نهائياً'),
          ),
        ],
      ),
    );
  }

  void _saveAll() async {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId == null) return;

    setState(() => _isSavingFinal = true);

    try {
      String imageUrl = widget.courseData['imageUrl'] ?? '';
      
      if (widget.courseData['imageFile'] != null && imageUrl.isEmpty) {
        final imageFile = widget.courseData['imageFile'] as File;
        final fileName = 'course_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await context.read<CoursesCubit>().uploadFile(imageFile, fileName);
        if (url != null) imageUrl = url;
      }

      final course = CourseEntity(
        id: widget.courseData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.courseData['title'],
        description: widget.courseData['description'],
        imageUrl: imageUrl,
        teacherId: uId,
        modules: [ModuleEntity(id: 'm1', title: 'المنهج الدراسي', lessons: _lessons)],
      );

      if (mounted) {
        context.read<CoursesCubit>().addCourse(course);
      }
    } catch (e) {
      log("Save Final Error: $e");
      if (mounted) {
        setState(() => _isSavingFinal = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
