import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

class PersistentEnrollButton extends StatelessWidget {
  final CourseEntity course;

  const PersistentEnrollButton({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          bool isLoading = state is CoursesLoading;
          return ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    final uId = CacheHelper.getData(key: 'uId');
                    if (uId != null) {
                      context.read<CoursesCubit>().enrollInCourse(uId, course.id);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.mainBlue,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('اشترك في الكورس الآن - مجاناً',
                    style: TextStyles.font16WhiteSemiBold),
          );
        },
      ),
    );
  }
}
