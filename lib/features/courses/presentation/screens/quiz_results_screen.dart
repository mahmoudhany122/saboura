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
import '../../domain/entities/quiz_result_entity.dart';

class QuizResultsScreen extends StatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getTeacherQuizResults(uId);
      context.read<CoursesCubit>().getCourseEnrollments(uId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('مركز التقارير والطلاب'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: ColorsManager.mainBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: ColorsManager.mainBlue,
          tabs: const [
            Tab(text: 'نتائج الاختبارات', icon: Icon(Icons.assignment_turned_in)),
            Tab(text: 'الطلاب المشتركين', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) return const Center(child: CircularProgressIndicator());
          
          final results = context.read<CoursesCubit>().studentResults;
          final students = context.read<CoursesCubit>().courseEnrollments;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildResultsTab(results),
              _buildStudentsTab(students),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsTab(List<QuizResultEntity> results) {
    if (results.isEmpty) return _buildEmptyState('لا توجد نتائج اختبارات حتى الآن');

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return FadeInUp(
          child: GestureDetector(
            onTap: () {
              // Navigate to Review Screen
              Navigator.pushNamed(context, Routes.quizReviewScreen, arguments: {
                'result': result,
                'quiz': context.read<CoursesCubit>().teacherCourses.firstWhere((c) => c.id == result.courseId).modules[0].lessons.firstWhere((l) => l.quiz?.id == result.quizId).quiz,
              });
            },
            child: _buildResultCard(result),
          ),
        );
      },
    );
  }

  Widget _buildStudentsTab(List students) {
    if (students.isEmpty) return _buildEmptyState('لا يوجد طلاب مشتركين في هذا الكورس بعد');

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(student.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('تاريخ الاشتراك: ${DateFormat('yyyy-MM-dd').format(student.enrolledAt)}'),
            trailing: Text('${(student.progress * 100).toInt()}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(QuizResultEntity result) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.assignment)),
          horizontalSpace(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(result.quizTitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          _buildScoreBadge(result.score, result.totalQuestions),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score, int total) {
    double percentage = score / total;
    Color color = percentage >= 0.8 ? Colors.green : (percentage >= 0.5 ? Colors.orange : Colors.red);
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text('$score / $total', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80.w, color: Colors.grey[300]),
          verticalSpace(20),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
