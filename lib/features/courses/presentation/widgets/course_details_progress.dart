import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../domain/entities/course_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

class CourseDetailsProgress extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsProgress({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        final completedIds = context.read<CoursesCubit>().completedLessonsIds;
        int totalLessons = 0;
        if (course.modules.isNotEmpty) {
          totalLessons = course.modules[0].lessons.length;
        }
        double progress = totalLessons > 0 ? (completedIds.length / totalLessons) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تقدمك في التعلم', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toInt()}%',
                    style: const TextStyle(
                        color: ColorsManager.mainBlue, fontWeight: FontWeight.bold)),
              ],
            ),
            verticalSpace(10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: ColorsManager.lighterGray,
              color: ColorsManager.mainBlue,
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        );
      },
    );
  }
}
