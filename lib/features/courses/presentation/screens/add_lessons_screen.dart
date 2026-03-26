import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

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
    // Load existing lessons if we are in editing mode
    if (widget.courseData['modules'] != null && (widget.courseData['modules'] as List).isNotEmpty) {
      final existingLessons = (widget.courseData['modules'] as List<ModuleEntity>)[0].lessons;
      _lessons.addAll(existingLessons);
    }
  }

  Future<void> _pickAndUploadPDF(StateSetter setLocalState, Function(String) onUploaded) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setLocalState(() => _isUploading = true);
        
        final file = File(result.files.single.path!);
        final fileName = 'pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf';
        
        final url = await context.read<CoursesCubit>().uploadFile(file, fileName);
        
        setLocalState(() => _isUploading = false);
        
        if (url != null) {
          onUploaded(url);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفع ملف PDF بنجاح!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setLocalState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الرفع: $e')),
      );
    }
  }

  void _addFullLesson() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String lessonTitle = '';
        String? videoUrl;
        String? pdfUrl;
        QuizEntity? quiz;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('إضافة درس جديد', textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'عنوان الدرس'),
                      onChanged: (v) => lessonTitle = v,
                    ),
                    verticalSpace(20),
                    _buildSubOption(
                      icon: Icons.play_circle,
                      label: videoUrl != null ? '✅ تم إضافة الفيديو' : 'إضافة فيديو (رابط)',
                      color: Colors.red,
                      onTap: () => _showInputDialog('رابط الفيديو', (v) => setLocalState(() => videoUrl = v)),
                    ),
                    _buildSubOption(
                      icon: Icons.picture_as_pdf,
                      label: pdfUrl != null ? '✅ تم رفع ملف PDF' : 'رفع ملف PDF',
                      color: Colors.orange,
                      onTap: () => _pickAndUploadPDF(setLocalState, (url) => setLocalState(() => pdfUrl = url)),
                    ),
                    _buildSubOption(
                      icon: Icons.quiz,
                      label: quiz != null ? '✅ تم بناء الاختبار' : 'إضافة اختبار',
                      color: Colors.green,
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, Routes.addQuizScreen);
                        if (result != null && result is QuizEntity) setLocalState(() => quiz = result);
                      },
                    ),
                    if (_isUploading) ...[
                      verticalSpace(10),
                      const LinearProgressIndicator(),
                      const Text('جاري الرفع...', style: TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: _isUploading ? null : () {
                    if (lessonTitle.isNotEmpty) {
                      setState(() {
                        _lessons.add(LessonEntity(
                          id: DateTime.now().toString(),
                          title: lessonTitle,
                          videoUrl: videoUrl,
                          pdfUrl: pdfUrl,
                          quiz: quiz,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ الدرس'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showInputDialog(String title, Function(String) onSave) {
    String value = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(onChanged: (v) => value = v),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () { if(value.isNotEmpty) { onSave(value); Navigator.pop(context); } }, child: const Text('تم')),
        ],
      ),
    );
  }

  Widget _buildSubOption({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      onTap: onTap,
      trailing: const Icon(Icons.add, size: 18),
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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات بنجاح!'), backgroundColor: Colors.green));
            Navigator.popUntil(context, (route) => route.isFirst);
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
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: ExpansionTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => setState(() => _lessons.removeAt(index)),
          ),
          children: [
            if (lesson.videoUrl != null) ListTile(leading: const Icon(Icons.play_circle, color: Colors.red), title: const Text('فيديو الدرس')),
            if (lesson.pdfUrl != null) ListTile(leading: const Icon(Icons.picture_as_pdf, color: Colors.orange), title: const Text('ملف PDF')),
            if (lesson.quiz != null) ListTile(leading: const Icon(Icons.quiz, color: Colors.green), title: const Text('اختبار')),
          ],
        ),
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
            onPressed: _isSavingFinal ? null : _saveAll,
            style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 56.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: _isSavingFinal ? const CircularProgressIndicator() : const Text('حفظ كافة التعديلات نهائياً'),
          ),
        ],
      ),
    );
  }

  void _saveAll() async {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId == null) return;

    setState(() => _isSavingFinal = true);

    final course = CourseEntity(
      id: widget.courseData['id'],
      title: widget.courseData['title'],
      description: widget.courseData['description'],
      imageUrl: widget.courseData['imageUrl'] ?? '',
      teacherId: uId,
      modules: [ModuleEntity(id: 'm1', title: 'المنهج الدراسي', lessons: _lessons)],
    );
    
    context.read<CoursesCubit>().addCourse(course);
  }
}
