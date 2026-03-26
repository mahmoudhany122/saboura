import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizScreen extends StatefulWidget {
  final QuizEntity quiz;
  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswered = false;
  int score = 0;
  late Timer _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.quiz.durationInMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer.cancel();
        _showResult();
      }
    });
  }

  void _checkAnswer(int index) {
    if (isAnswered) return;
    setState(() {
      selectedAnswerIndex = index;
      isAnswered = true;
      if (index == widget.quiz.questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = null;
          isAnswered = false;
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    _timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهى الاختبار!'),
        content: Text('درجتك النهائية هي: $score من ${widget.quiz.questions.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('الرجوع للرئيسية'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var question = widget.quiz.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: _getThemeBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '${(_remainingTime ~/ 60)}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildProgressIndicator(),
            SizedBox(height: 30.h),
            _buildThemeAnimation(),
            SizedBox(height: 20.h),
            FadeInLeft(
              key: ValueKey(currentQuestionIndex),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Text(
                  question.questionText,
                  style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 20.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            ...List.generate(question.options.length, (index) => _buildOption(index, question)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, QuestionEntity question) {
    Color cardColor = Colors.white;
    if (isAnswered) {
      if (index == question.correctAnswerIndex) {
        cardColor = Colors.green.shade100;
      } else if (index == selectedAnswerIndex) {
        cardColor = Colors.red.shade100;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => _checkAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isAnswered && index == question.correctAnswerIndex ? Colors.green : ColorsManager.lighterGray,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 15.w),
              Expanded(child: Text(question.options[index])),
              if (isAnswered && index == question.correctAnswerIndex) const Icon(Icons.check_circle, color: Colors.green),
              if (isAnswered && index == selectedAnswerIndex && index != question.correctAnswerIndex) const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: (currentQuestionIndex + 1) / widget.quiz.questions.length,
      backgroundColor: ColorsManager.lighterGray,
      color: ColorsManager.mainBlue,
      minHeight: 8.h,
    );
  }

  Widget _buildThemeAnimation() {
    switch (widget.quiz.theme) {
      case QuizTheme.carRacing:
        return const Icon(Icons.directions_car, size: 80, color: Colors.orange);
      case QuizTheme.monkey:
        return Icon(
          isAnswered 
            ? (selectedAnswerIndex == widget.quiz.questions[currentQuestionIndex].correctAnswerIndex ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied)
            : Icons.emoji_emotions,
          size: 80, 
          color: Colors.brown
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getThemeBackgroundColor() {
    switch (widget.quiz.theme) {
      case QuizTheme.space: return Colors.indigo.shade50;
      case QuizTheme.desert: return Colors.orange.shade50;
      default: return Colors.white;
    }
  }
}
