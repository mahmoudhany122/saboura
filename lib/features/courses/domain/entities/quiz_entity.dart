import 'package:equatable/equatable.dart';

enum QuestionType { multipleChoice, fillInTheBlanks }

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
  final List<String> options; // Empty for Fill in the blanks
  final int correctAnswerIndex; // -1 for Fill in the blanks
  final String? correctTextAnswer; // Used for Fill in the blanks
  final QuestionType type;

  const QuestionEntity({
    required this.id,
    required this.questionText,
    this.options = const [],
    this.correctAnswerIndex = -1,
    this.correctTextAnswer,
    this.type = QuestionType.multipleChoice,
  });

  @override
  List<Object?> get props => [id, questionText, options, correctAnswerIndex, correctTextAnswer, type];
}

enum QuizTheme { classic, carRacing, space, desert, monkey }
