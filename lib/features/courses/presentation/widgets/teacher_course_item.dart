import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';

class TeacherCourseItem extends StatelessWidget {
  final CourseEntity course;

  const TeacherCourseItem({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.addLessonsScreen,
          arguments: {
            'id': course.id,
            'title': course.title,
            'modules': course.modules,
            'isEditing': true,
          },
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: ColorsManager.moreLightGray,
                borderRadius: BorderRadius.circular(12),
                image: course.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(course.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course.imageUrl.isEmpty
                  ? const Icon(Icons.book, color: ColorsManager.mainBlue)
                  : null,
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: TextStyles.font15DarkBlueMedium),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 14, color: ColorsManager.gray),
                      SizedBox(width: 4.w),
                      Text('${course.enrollmentCount} طالب مسجل',
                          style: TextStyles.font13GrayRegular),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text('${course.rating} تقييم', style: TextStyles.font13GrayRegular),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 20, color: ColorsManager.mainBlue),
          ],
        ),
      ),
    );
  }
}
