import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../domain/entities/course_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

class LessonExpansionTile extends StatelessWidget {
  final LessonEntity lesson;
  final int index;
  final bool isEnrolled;
  final String courseId;

  const LessonExpansionTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.isEnrolled,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        bool isCompleted = context.read<CoursesCubit>().completedLessonsIds.contains(lesson.id);
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : ColorsManager.mainBlue.withOpacity(0.1),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.green)
                  : Text('${index + 1}',
                      style: const TextStyle(color: ColorsManager.mainBlue)),
            ),
            title: Text(lesson.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted ? TextDecoration.lineThrough : null)),
            subtitle: Text(isCompleted ? 'مكتمل ✅' : 'اضغط لفتح المحتوى'),
            children: [
              if (isEnrolled) ...[
                if (lesson.videoUrl != null)
                  _buildContentItem(context, Icons.play_circle, 'مشاهدة الفيديو', Colors.red, () {
                    Navigator.pushNamed(context, Routes.lessonViewerScreen,
                        arguments: lesson);
                  }),
                if (lesson.pdfUrl != null)
                  _buildContentItem(context, Icons.picture_as_pdf, 'تحميل المذكرة',
                      Colors.orange, () {
                    Navigator.pushNamed(context, Routes.lessonViewerScreen,
                        arguments: lesson);
                  }),
                if (lesson.quiz != null)
                  _buildContentItem(context, Icons.quiz, 'دخول الاختبار', Colors.green, () {
                    if (isCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('لقد أتممت هذا الاختبار بالفعل ولا يمكن إعادته ⛔'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, Routes.quizScreen, arguments: {
                        'quiz': lesson.quiz,
                        'courseId': courseId,
                        'lessonId': lesson.id,
                      });
                    }
                  }),
                ListTile(
                  title: const Text('تحديد كدرس مكتمل',
                      style: TextStyle(fontSize: 13, color: Colors.blue)),
                  trailing: Switch(
                    value: isCompleted,
                    onChanged: (val) {
                      final uId = CacheHelper.getData(key: 'uId');
                      if (uId != null) {
                        context
                            .read<CoursesCubit>()
                            .toggleLessonStatus(uId, courseId, lesson.id, val);
                      }
                    },
                  ),
                ),
              ] else
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('🔒 يجب الاشتراك أولاً لفتح هذا الدرس',
                      style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentItem(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}
