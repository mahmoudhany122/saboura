import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getTeacherCourses(uId);
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = CacheHelper.getData(key: 'userName') ?? 'المعلم';

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المعلم'),
        actions: [
          IconButton(
            onPressed: _loadCourses,
            icon: const Icon(Icons.refresh),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.addCourseScreen),
        backgroundColor: ColorsManager.mainBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة كورس', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoursesLoaded) {
            return _buildDashboardContent(userName, state.courses);
          } else if (state is CoursesError) {
            return Center(child: Text(state.error));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboardContent(String userName, List<CourseEntity> courses) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          FadeInDown(
            child: Text(
              'مرحباً أستاذ $userName 👋',
              style: TextStyles.font24BlackBold,
            ),
          ),
          SizedBox(height: 10.h),
          Text('لديك ${courses.length} كورسات منشورة.', style: TextStyles.font14GrayRegular),
          SizedBox(height: 30.h),
          Text('إدارة كورساتك', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
          SizedBox(height: 15.h),
          Expanded(
            child: courses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _buildCourseItem(courses[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80.w, color: ColorsManager.lightGray),
          SizedBox(height: 20.h),
          const Text('لا يوجد كورسات مضافة بعد'),
        ],
      ),
    );
  }

  Widget _buildCourseItem(CourseEntity course) {
    return GestureDetector(
      onTap: () {
        // Navigate to edit/add lessons for this specific course
        Navigator.pushNamed(
          context, 
          Routes.addLessonsScreen, 
          arguments: {
            'id': course.id,
            'title': course.title,
            'modules': course.modules,
            'isEditing': true,
          }
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                  ? DecorationImage(image: NetworkImage(course.imageUrl), fit: BoxFit.cover)
                  : null,
              ),
              child: course.imageUrl.isEmpty ? const Icon(Icons.book, color: ColorsManager.mainBlue) : null,
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
                      Icon(Icons.people_outline, size: 14, color: ColorsManager.gray),
                      SizedBox(width: 4.w),
                      Text('${course.enrollmentCount} طالب مسجل', style: TextStyles.font13GrayRegular),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
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
