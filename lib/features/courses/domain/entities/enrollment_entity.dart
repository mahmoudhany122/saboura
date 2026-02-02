import 'package:equatable/equatable.dart';

class EnrollmentEntity extends Equatable {
  final String userId;
  final String userName;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;
  final List<String> completedLessons;

  const EnrollmentEntity({
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.enrolledAt,
    required this.progress,
    required this.completedLessons,
  });

  @override
  List<Object?> get props => [userId, userName, courseId, enrolledAt, progress, completedLessons];
}
