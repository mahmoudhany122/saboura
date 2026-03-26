import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/cache_helper.dart';
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

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      // For now we will use a dedicated method in cubit if exists or update state
      // Let's assume we added getTeacherQuizResults to CoursesCubit
      // context.read<CoursesCubit>().getTeacherQuizResults(uId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('نتائج الطلاب'),
        centerTitle: true,
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          // Note: In a real app, you'd handle QuizResultsLoaded state
          // For now, let's mock the list to show the design
          List<QuizResultEntity> mockResults = [
            QuizResultEntity(
              id: '1',
              userId: 'u1',
              userName: 'ياسين محمد',
              courseId: 'c1',
              quizId: 'q1',
              quizTitle: 'اختبار الحروف العربية',
              score: 9,
              totalQuestions: 10,
              timestamp: DateTime.now(),
            ),
            QuizResultEntity(
              id: '2',
              userId: 'u2',
              userName: 'ليان أحمد',
              courseId: 'c1',
              quizId: 'q1',
              quizTitle: 'اختبار الحروف العربية',
              score: 7,
              totalQuestions: 10,
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            ),
          ];

          return _buildResultsList(mockResults);
        },
      ),
    );
  }

  Widget _buildResultsList(List<QuizResultEntity> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 80.w, color: ColorsManager.lightGray),
            verticalSpace(20),
            const Text('لا توجد نتائج اختبارات حتى الآن'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 100),
          child: Container(
            margin: EdgeInsets.only(bottom: 15.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: ColorsManager.mainBlue.withOpacity(0.1),
                  child: const Icon(Icons.person, color: ColorsManager.mainBlue),
                ),
                horizontalSpace(15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.userName, style: TextStyles.font15DarkBlueMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(result.quizTitle, style: TextStyles.font13GrayRegular),
                      Text(
                        DateFormat('yyyy-MM-dd | hh:mm a').format(result.timestamp),
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildScoreBadge(result.score, result.totalQuestions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBadge(int score, int total) {
    double percentage = score / total;
    Color color = percentage >= 0.8 ? Colors.green : (percentage >= 0.5 ? Colors.orange : Colors.red);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$score / $total',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14.sp),
      ),
    );
  }
}
