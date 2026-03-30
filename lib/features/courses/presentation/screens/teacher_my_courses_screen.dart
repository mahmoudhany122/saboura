import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';
import '../widgets/teacher_course_item.dart';

class TeacherMyCoursesScreen extends StatefulWidget {
  const TeacherMyCoursesScreen({super.key});

  @override
  State<TeacherMyCoursesScreen> createState() => _TeacherMyCoursesScreenState();
}

class _TeacherMyCoursesScreenState extends State<TeacherMyCoursesScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('إدارة كورساتي'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _loadCourses, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          final courses = context.read<CoursesCubit>().teacherCourses;

          if (state is CoursesLoading && courses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80.w, color: Colors.grey[300]),
                  SizedBox(height: 16.h),
                  const Text('لم تقم بإضافة أي كورس بعد'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Column(
                    children: [
                      TeacherCourseItem(course: courses[index]),
                      _buildActionButtons(courses[index]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(CourseEntity course) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionItem(Icons.analytics_outlined, 'النتائج', Colors.blue, () {
            // Navigate to results
          }),
          _actionItem(Icons.comment_outlined, 'الأسئلة', Colors.orange, () {
            // Navigate to comments
          }),
          _actionItem(Icons.edit_note_outlined, 'تعديل', Colors.green, () {
            // Navigate to edit lessons
          }),
        ],
      ),
    );
  }

  Widget _actionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
