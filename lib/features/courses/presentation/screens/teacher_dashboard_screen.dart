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
import '../widgets/teacher_course_item.dart';

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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('لوحة تحكم المعلم'),
        actions: [
          IconButton(onPressed: _loadCourses, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () {
              CacheHelper.clearData();
              Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.addCourseScreen),
        backgroundColor: ColorsManager.mainBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('كورس جديد', style: TextStyle(color: Colors.white)),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
          
          final courses = context.read<CoursesCubit>().teacherCourses;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(userName),
                SizedBox(height: 30.h),
                Text('إدارة المحتوى والطلاب', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                SizedBox(height: 15.h),
                courses.isEmpty ? _buildEmptyState() : _buildCoursesList(courses),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(String userName) {
    return FadeInDown(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: ColorsManager.mainBlue,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً أستاذ $userName 👋', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('تابع طلابك وحدث محتواك التعليمي بسهولة.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList(List<CourseEntity> courses) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Column(
            children: [
              TeacherCourseItem(course: courses[index]),
              _buildCourseStatsRow(courses[index]),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseStatsRow(CourseEntity course) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(Icons.people, '${course.enrollmentCount} طالب'),
          _statItem(Icons.comment, 'تعليقات الطلاب'),
          _statItem(Icons.analytics, 'التقارير', color: Colors.blue, onTap: () {
            Navigator.pushNamed(context, Routes.quizResultsScreen); // Link to analytics
          }),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, {Color color = Colors.grey, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Icon(Icons.library_books_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('لم تقم بإضافة أي كورس بعد'),
        ],
      ),
    );
  }
}
