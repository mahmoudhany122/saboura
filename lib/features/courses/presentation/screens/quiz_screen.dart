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
import '../widgets/quiz_game_element.dart';
import '../widgets/answer_option.dart';

class QuizScreen extends StatefulWidget {
  final QuizEntity quiz;
  final String courseId;
  final String lessonId;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.courseId,
    required this.lessonId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswered = false;
  int score = 0;
  late Timer _timer;
  int _remainingTime = 0;
  bool isQuizFinished = false;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingTime = widget.quiz.durationInMinutes * 60;
    
    // Show warning dialog before starting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartWarning();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Anti-cheat: If app goes to background, finish quiz immediately
    if (state == AppLifecycleState.paused && hasStarted && !isQuizFinished) {
      _saveAndShowResult(reason: 'تم إلغاء الاختبار لمحاولة الخروج من التطبيق');
    }
  }

  void _showStartWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ تحذير هام', textAlign: TextAlign.center),
        content: const Text(
          '1. يسمح بحل الاختبار مرة واحدة فقط.\n'
          '2. أي محاولة للخروج من التطبيق ستؤدي لإلغاء الاختبار فوراً.\n'
          '3. بمجرد البدء، سيبدأ العد التنازلي.',
          textAlign: TextAlign.right,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => hasStarted = true);
                _startTimer();
              },
              style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue),
              child: const Text('أنا مستعد، ابدأ الآن!', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _timer.cancel();
        _saveAndShowResult(reason: 'انتهى الوقت المحدد للاختبار');
      }
    });
  }

  void _checkAnswer(int index) {
    if (isAnswered || isQuizFinished || !hasStarted) return;
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

  void _saveAndShowResult({String? reason}) {
    if (isQuizFinished) return;
    setState(() => isQuizFinished = true);
    if (_timer.isActive) _timer.cancel();

    final uId = CacheHelper.getData(key: 'uId');
    final userName = CacheHelper.getData(key: 'userName') ?? 'طالب';

    if (uId != null) {
      final result = QuizResultEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uId,
        userName: userName,
        courseId: widget.courseId,
        quizId: widget.quiz.id,
        quizTitle: widget.quiz.title,
        score: score,
        totalQuestions: widget.quiz.questions.length,
        timestamp: DateTime.now(),
      );
      
      context.read<CoursesCubit>().saveQuizResult(result);
      context.read<CoursesCubit>().toggleLessonStatus(uId, widget.courseId, widget.lessonId, true);
    }
    _showResultDialog(reason: reason);
  }

  void _showResultDialog({String? reason}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(reason ?? 'انتهى الاختبار يا بطل! 🏆', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, color: reason != null ? Colors.red : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(reason != null ? Icons.warning_amber_rounded : Icons.stars, color: reason != null ? Colors.red : Colors.amber, size: 80),
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
    WidgetsBinding.instance.removeObserver(this);
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return const Scaffold(backgroundColor: Colors.white);
    
    var question = widget.quiz.questions[currentQuestionIndex];
    double progress = (currentQuestionIndex) / widget.quiz.questions.length;
    bool isCorrect = isAnswered && (selectedAnswerIndex == question.correctAnswerIndex);

    return PopScope(
      canPop: isQuizFinished,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmation();
      },
      child: Scaffold(
        backgroundColor: _getThemeBackgroundColor(),
        appBar: AppBar(
          title: Text(widget.quiz.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitConfirmation(),
          ),
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
                  Expanded(
                    child: QuizGameElement(
                      theme: widget.quiz.theme,
                      progress: progress,
                      isAnswered: isAnswered,
                      isCorrect: isCorrect,
                    ),
                  ),
                  ...List.generate(
                      question.options.length,
                      (index) => AnswerOption(
                            index: index,
                            optionText: question.options[index],
                            isAnswered: isAnswered,
                            isCorrect: index == question.correctAnswerIndex,
                            isSelected: index == selectedAnswerIndex,
                            onTap: () => _checkAnswer(index),
                          )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحذير!'),
        content: const Text('إذا خرجت الآن سيتم إنهاء الاختبار وحساب درجتك الحالية فقط. هل أنت متأكد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إكمال الاختبار')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _saveAndShowResult(reason: 'تم إنهاء الاختبار بناءً على رغبتك');
            },
            child: const Text('خروج وحفظ', style: TextStyle(color: Colors.red)),
          ),
        ],
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
      case QuizTheme.space:
        return const Color(0xFF0B0D17);
      case QuizTheme.desert:
        return const Color(0xFFF4A460);
      case QuizTheme.carRacing:
        return const Color(0xFF87CEEB);
      default:
        return Colors.white;
    }
  }

  Widget _buildSpaceBackground() {
    return Stack(
      children: List.generate(
          10,
          (index) => Positioned(
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
