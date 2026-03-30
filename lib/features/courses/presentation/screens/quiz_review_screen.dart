import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizReviewScreen extends StatelessWidget {
  final QuizResultEntity result;
  final QuizEntity quiz;

  const QuizReviewScreen({super.key, required this.result, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('مراجعة إجابات: ${result.userName}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: quiz.questions.length,
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                final userAnswerIndex = result.userAnswers.length > index ? result.userAnswers[index] : -1;
                final isCorrect = userAnswerIndex == question.correctAnswerIndex;

                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildQuestionReviewCard(index + 1, question, userAnswerIndex, isCorrect),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryStat('الدرجة', '${result.score}/${result.totalQuestions}', Colors.blue),
          _buildSummaryStat('النسبة', '${((result.score / result.totalQuestions) * 100).toInt()}%', Colors.green),
          _buildSummaryStat('الحالة', result.score >= (result.totalQuestions / 2) ? 'ناجح ✅' : 'راسب ❌', 
            result.score >= (result.totalQuestions / 2) ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyles.font13GrayRegular),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18.sp)),
      ],
    );
  }

  Widget _buildQuestionReviewCard(int number, QuestionEntity question, int userAnswerIndex, bool isCorrect) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isCorrect ? Colors.green : Colors.red,
                child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              horizontalSpace(10),
              Expanded(child: Text(question.questionText, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          verticalSpace(15),
          ...List.generate(question.options.length, (idx) {
            bool isUserChoice = idx == userAnswerIndex;
            bool isCorrectChoice = idx == question.correctAnswerIndex;
            
            Color bgColor = Colors.transparent;
            Color borderColor = Colors.grey.shade200;
            Widget? trailing;

            if (isCorrectChoice) {
              bgColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
              trailing = const Icon(Icons.check_circle, color: Colors.green, size: 20);
            } else if (isUserChoice && !isCorrect) {
              bgColor = Colors.red.withOpacity(0.1);
              borderColor = Colors.red;
              trailing = const Icon(Icons.cancel, color: Colors.red, size: 20);
            }

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(question.options[idx], 
                    style: TextStyle(color: isCorrectChoice ? Colors.green.shade900 : (isUserChoice ? Colors.red.shade900 : Colors.black87)))),
                  if (trailing != null) trailing,
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
