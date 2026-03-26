import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

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
        _saveAndShowResult();
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

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (currentQuestionIndex < widget.quiz.questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswerIndex = null;
            isAnswered = false;
          });
        } else {
          _saveAndShowResult();
        }
      }
    });
  }

  void _saveAndShowResult() {
    _timer.cancel();
    
    // Logic to save result to Firestore
    final uId = CacheHelper.getData(key: 'uId');
    final userName = CacheHelper.getData(key: 'userName') ?? 'طالب';
    
    if (uId != null) {
      final result = QuizResultEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uId,
        userName: userName,
        courseId: 'unknown', // Ideally passed from previous screen
        quizId: widget.quiz.id,
        quizTitle: widget.quiz.title,
        score: score,
        totalQuestions: widget.quiz.questions.length,
        timestamp: DateTime.now(),
      );
      context.read<CoursesCubit>().saveQuizResult(result);
    }

    _showResultDialog();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('انتهى الاختبار يا بطل! 🏆', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 80),
            SizedBox(height: 20.h),
            Text('درجتك النهائية هي:', style: TextStyles.font14GrayRegular),
            Text('$score من ${widget.quiz.questions.length}', 
              style: TextStyles.font24BlackBold.copyWith(color: ColorsManager.mainBlue)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue),
              child: const Text('الرجوع للرئيسية', style: TextStyle(color: Colors.white)),
            ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              margin: EdgeInsets.only(left: 16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(_remainingTime ~/ 60)}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          if (widget.quiz.theme == QuizTheme.space) _buildSpaceBackground(),
          if (widget.quiz.theme == QuizTheme.desert) _buildDesertBackground(),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 20.h),
                
                FadeInDown(
                  key: ValueKey('q_$currentQuestionIndex'),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                    ),
                    child: Text(
                      question.questionText,
                      style: TextStyles.font24BlackBold.copyWith(fontSize: 22.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                Expanded(child: _buildGameElement()),
                
                ...List.generate(question.options.length, (index) => _buildOption(index, question)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameElement() {
    double progress = (currentQuestionIndex) / widget.quiz.questions.length;
    
    switch (widget.quiz.theme) {
      case QuizTheme.carRacing:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 60.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomPaint(painter: RoadPainter()),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 1000),
              alignment: Alignment(progress * 2 - 1, 0),
              child: const Icon(Icons.directions_car, size: 50, color: Colors.orange),
            ),
          ],
        );
      case QuizTheme.monkey:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isAnswered)
                (selectedAnswerIndex == widget.quiz.questions[currentQuestionIndex].correctAnswerIndex)
                  ? ZoomIn(child: const Text('🐒 ييييي هااااا!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)))
                  : ShakeX(child: const Text('🐒 اووووه لاااا!', style: TextStyle(fontSize: 30))),
              SizedBox(height: 10.h),
              Icon(
                isAnswered 
                  ? (selectedAnswerIndex == widget.quiz.questions[currentQuestionIndex].correctAnswerIndex ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied)
                  : Icons.emoji_emotions,
                size: 100.w, 
                color: Colors.brown
              ),
            ],
          ),
        );
      case QuizTheme.space:
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            margin: EdgeInsets.only(bottom: progress * 100.h),
            child: const RocketAnimation(),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOption(int index, QuestionEntity question) {
    bool isCorrect = index == question.correctAnswerIndex;
    bool isSelected = index == selectedAnswerIndex;

    Color cardColor = Colors.white;
    if (isAnswered) {
      if (isCorrect) cardColor = Colors.green.shade50;
      else if (isSelected) cardColor = Colors.red.shade50;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: () => _checkAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAnswered 
                  ? (isCorrect ? Colors.green : (isSelected ? Colors.red : ColorsManager.lighterGray))
                  : ColorsManager.lighterGray,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 35.w,
                height: 35.w,
                decoration: BoxDecoration(
                  color: isAnswered 
                      ? (isCorrect ? Colors.green : (isSelected ? Colors.red : ColorsManager.moreLightGray))
                      : ColorsManager.moreLightGray,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAnswered && (isCorrect || isSelected) ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isAnswered && isCorrect) const Icon(Icons.check_circle, color: Colors.green),
              if (isAnswered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (currentQuestionIndex + 1) / widget.quiz.questions.length,
          backgroundColor: Colors.transparent,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }

  Color _getThemeBackgroundColor() {
    switch (widget.quiz.theme) {
      case QuizTheme.space: return const Color(0xFF0B0D17);
      case QuizTheme.desert: return const Color(0xFFF4A460);
      case QuizTheme.carRacing: return const Color(0xFF87CEEB);
      default: return Colors.white;
    }
  }

  Widget _buildSpaceBackground() {
    return Stack(
      children: List.generate(10, (index) => Positioned(
        top: (index * 80.0) % 600,
        left: (index * 100.0) % 350,
        child: const Icon(Icons.star, color: Colors.white, size: 5),
      )),
    );
  }

  Widget _buildDesertBackground() {
    return Positioned(
      bottom: 0,
      child: Icon(Icons.terrain, size: 400.w, color: Colors.orange.shade700.withOpacity(0.3)),
    );
  }
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 10, dashSpace = 10, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2), Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RocketAnimation extends StatelessWidget {
  const RocketAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.rocket_launch, size: 60, color: Colors.redAccent),
        Container(
          width: 10,
          height: 20,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.orange, Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
        ),
      ],
    );
  }
}
