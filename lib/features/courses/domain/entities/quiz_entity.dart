import 'package:equatable/equatable.dart';

class QuizEntity extends Equatable {
  final String id;
  final String title;
  final int durationInMinutes;
  final List<QuestionEntity> questions;
  final QuizTheme theme;

  const QuizEntity({
    required this.id,
    required this.title,
    required this.durationInMinutes,
    required this.questions,
    this.theme = QuizTheme.classic,
  });

  @override
  List<Object?> get props => [id, title, durationInMinutes, questions, theme];
}

class QuestionEntity extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [id, questionText, options, correctAnswerIndex];
}

enum QuizTheme { classic, carRacing, space, desert, monkey }
