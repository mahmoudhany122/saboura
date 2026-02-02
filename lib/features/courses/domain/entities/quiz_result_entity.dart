import 'package:equatable/equatable.dart';

class QuizResultEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String courseId;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime timestamp;
  final List<int> userAnswers; // Store the index of the answer chosen for each question

  const QuizResultEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.timestamp,
    required this.userAnswers,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        courseId,
        quizId,
        quizTitle,
        score,
        totalQuestions,
        timestamp,
        userAnswers,
      ];
}
