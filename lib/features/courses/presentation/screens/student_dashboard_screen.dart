import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getStudentDashboardData(uId);
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = CacheHelper.getData(key: 'userName') ?? 'بطل سبورة';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('لوحتي التعليمية'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          final cubit = context.read<CoursesCubit>();
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(userName),
                verticalSpace(30),
                Text('كورساتي المسجلة', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                verticalSpace(15),
                _buildEnrolledSection(state, cubit.enrolledCourses),
                verticalSpace(30),
                Text('آخر نتائج الاختبارات', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                verticalSpace(15),
                _buildQuizResultsSection(state, cubit.studentResults),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return FadeInDown(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [ColorsManager.mainBlue, Color(0xFF5096FF)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30.r, backgroundColor: Colors.white, child: const Icon(Icons.person, color: ColorsManager.mainBlue)),
            horizontalSpace(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أهلاً بك يا $userName! 👋', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('تابع تقدمك وحقق أهدافك 🌟', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledSection(CoursesState state, List<CourseEntity> courses) {
    if (state is CoursesLoading && courses.isEmpty) return const Center(child: CircularProgressIndicator());
    if (courses.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لم تشترك في أي كورس بعد')));
    
    return Column(
      children: courses.map((course) => _buildCourseItem(course)).toList(),
    );
  }

  Widget _buildQuizResultsSection(CoursesState state, List<QuizResultEntity> results) {
    if (state is CoursesLoading && results.isEmpty) return const Center(child: CircularProgressIndicator());
    if (results.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('لم تحل أي اختبارات بعد')));
    
    return Column(
      children: results.map((result) => _buildResultItem(result)).toList(),
    );
  }

  Widget _buildCourseItem(CourseEntity course) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.courseDetailsScreen, arguments: course);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill, color: ColorsManager.mainBlue, size: 30.w),
            horizontalSpace(15),
            Expanded(child: Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(QuizResultEntity result) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.quizTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(DateFormat('yyyy-MM-dd').format(result.timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${result.score}/${result.totalQuestions}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
