import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../../../core/routing/routes.dart';

class LessonFormDialog extends StatefulWidget {
  final Function(String title, String? videoUrl, String? pdfUrl, QuizEntity? quiz)
      onSave;
  final Future<void> Function(StateSetter, Function(String)) onPickPdf;
  final bool isUploading;

  const LessonFormDialog({
    super.key,
    required this.onSave,
    required this.onPickPdf,
    required this.isUploading,
  });

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  String lessonTitle = '';
  String? videoUrl;
  String? pdfUrl;
  QuizEntity? quiz;

  @override
  Widget build(BuildContext context) {
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
              onTap: () => _showInputDialog('رابط الفيديو', (v) => setState(() => videoUrl = v)),
            ),
            _buildSubOption(
              icon: Icons.picture_as_pdf,
              label: pdfUrl != null ? '✅ تم رفع ملف PDF' : 'رفع ملف PDF',
              color: Colors.orange,
              onTap: () => widget.onPickPdf(setState, (url) => setState(() => pdfUrl = url)),
            ),
            _buildSubOption(
              icon: Icons.quiz,
              label: quiz != null ? '✅ تم بناء الاختبار' : 'إضافة اختبار',
              color: Colors.green,
              onTap: () async {
                final result = await Navigator.pushNamed(context, Routes.addQuizScreen);
                if (result != null && result is QuizEntity) {
                  setState(() => quiz = result);
                }
              },
            ),
            if (widget.isUploading) ...[
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
          onPressed: widget.isUploading
              ? null
              : () {
                  if (lessonTitle.isNotEmpty) {
                    widget.onSave(lessonTitle, videoUrl, pdfUrl, quiz);
                    Navigator.pop(context);
                  }
                },
          child: const Text('حفظ الدرس'),
        ),
      ],
    );
  }

  Widget _buildSubOption(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      onTap: onTap,
      trailing: const Icon(Icons.add, size: 18),
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () {
                if (value.isNotEmpty) {
                  onSave(value);
                  Navigator.pop(context);
                }
              },
              child: const Text('تم')),
        ],
      ),
    );
  }
}
