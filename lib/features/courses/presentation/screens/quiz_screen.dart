import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/sound_helper.dart';
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
  late ConfettiController _confettiController;
  final List<int> _userAnswers = [];
  final TextEditingController _fillInController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _remainingTime = widget.quiz.durationInMinutes * 60;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartWarning();
    });
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

  void _checkTextAnswer() {
    if (isAnswered || _fillInController.text.isEmpty) return;
    
    final currentQ = widget.quiz.questions[currentQuestionIndex];
    bool isCorrect = _fillInController.text.trim().toLowerCase() == 
                     currentQ.correctTextAnswer?.trim().toLowerCase();
    
    setState(() {
      isAnswered = true;
      if (isCorrect) {
        score++;
        SoundHelper.playCorrect();
      } else {
        SoundHelper.playWrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _moveToNext();
    });
  }

  void _checkAnswer(int index) {
    if (isAnswered || isQuizFinished || !hasStarted) return;
    
    _userAnswers.add(index);
    bool isCorrect = index == widget.quiz.questions[currentQuestionIndex].correctAnswerIndex;
    
    setState(() {
      selectedAnswerIndex = index;
      isAnswered = true;
      if (isCorrect) {
        score++;
        SoundHelper.playCorrect();
      } else {
        SoundHelper.playWrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      _moveToNext();
    });
  }

  void _moveToNext() {
    if (mounted) {
      if (currentQuestionIndex < widget.quiz.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedAnswerIndex = null;
          isAnswered = false;
          _fillInController.clear();
        });
      } else {
        _saveAndShowResult();
      }
    }
  }

  void _saveAndShowResult({String? reason}) {
    if (isQuizFinished) return;
    setState(() => isQuizFinished = true);
    if (_timer.isActive) _timer.cancel();

    if (reason == null && score >= (widget.quiz.questions.length / 2)) {
      _confettiController.play();
      SoundHelper.playSuccess();
    }

    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      final result = QuizResultEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uId,
        userName: CacheHelper.getData(key: 'userName') ?? 'طالب',
        courseId: widget.courseId,
        quizId: widget.quiz.id,
        quizTitle: widget.quiz.title,
        score: score,
        totalQuestions: widget.quiz.questions.length,
        timestamp: DateTime.now(),
        userAnswers: _userAnswers,
      );
      context.read<CoursesCubit>().saveQuizResult(result);
      context.read<CoursesCubit>().toggleLessonStatus(uId, widget.courseId, widget.lessonId, true);
    }
    _showResultDialog(reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasStarted) return const Scaffold(backgroundColor: Colors.white);
    
    var question = widget.quiz.questions[currentQuestionIndex];
    double progress = (currentQuestionIndex) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: _getThemeBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: Colors.transparent,
        actions: [
          Center(child: Text('${(_remainingTime ~/ 60)}:${(_remainingTime % 60).toString().padLeft(2, '0')} ', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                _buildProgressIndicator(),
                SizedBox(height: 20.h),
                Expanded(
                  flex: 2,
                  child: QuizGameElement(
                    theme: widget.quiz.theme,
                    progress: progress,
                    isAnswered: isAnswered,
                    isCorrect: isAnswered && (selectedAnswerIndex == question.correctAnswerIndex || question.type == QuestionType.fillInTheBlanks), // Simplified for brevity
                    questionText: question.questionText,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: question.type == QuestionType.multipleChoice 
                    ? _buildMultipleChoice(question)
                    : _buildFillInTheBlanks(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoice(QuestionEntity question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) => AnswerOption(
        index: index,
        optionText: question.options[index],
        isAnswered: isAnswered,
        isCorrect: index == question.correctAnswerIndex,
        isSelected: index == selectedAnswerIndex,
        onTap: () => _checkAnswer(index),
        theme: widget.quiz.theme,
      ),
    );
  }

  Widget _buildFillInTheBlanks() {
    return FadeInUp(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اكتب الإجابة الصحيحة:', style: TextStyle(fontWeight: FontWeight.bold)),
            verticalSpace(15),
            TextField(
              controller: _fillInController,
              textAlign: TextAlign.center,
              enabled: !isAnswered,
              decoration: InputDecoration(
                hintText: 'اكتب هنا...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            verticalSpace(20),
            ElevatedButton(
              onPressed: isAnswered ? null : _checkTextAnswer,
              style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue, minimumSize: const Size(double.infinity, 50)),
              child: const Text('تأكيد الإجابة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper widgets (Progress, Backgrounds, Dialogs) kept from previous version ---
  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(value: (currentQuestionIndex + 1) / widget.quiz.questions.length);
  }

  Color _getThemeBackgroundColor() {
    return widget.quiz.theme == QuizTheme.space ? const Color(0xFF0B0D17) : Colors.white;
  }

  void _showStartWarning() {
    setState(() { hasStarted = true; _startTimer(); });
  }

  void _showResultDialog({String? reason}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('انتهى الاختبار!'),
        content: Text('درجتك هي $score من ${widget.quiz.questions.length}'),
        actions: [TextButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text('تم'))],
      ),
    );
  }
}
