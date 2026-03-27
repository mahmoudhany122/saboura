import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';

class CourseDetailsHeader extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.title, style: TextStyles.font24BlackBold),
          verticalSpace(8),
          Text(course.description, style: TextStyles.font14GrayRegular),
          verticalSpace(15),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              horizontalSpace(5),
              Text(course.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              horizontalSpace(20),
              const Icon(Icons.people_outline, color: ColorsManager.mainBlue, size: 20),
              horizontalSpace(5),
              Text('${course.enrollmentCount} طالب مشترك', style: TextStyles.font13GrayRegular),
            ],
          ),
        ],
      ),
    );
  }
}
