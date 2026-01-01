import 'dart:io';
import 'package:dartz/dartz.dart';
import '../entities/course_entity.dart';
import '../entities/quiz_result_entity.dart';
import '../entities/leaderboard_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/notification_entity.dart';
import '../entities/enrollment_entity.dart';
import '../entities/message_entity.dart';

abstract class CoursesRepo {
  Future<Either<String, void>> addCourse(CourseEntity course);
  Future<Either<String, List<CourseEntity>>> getAllCourses();
  Future<Either<String, List<CourseEntity>>> getTeacherCourses(String teacherId);
  Future<Either<String, void>> updateCourseLessons(String courseId, List<ModuleEntity> modules);
  Future<Either<String, void>> enrollInCourse(String userId, String courseId);
  Future<Either<String, List<CourseEntity>>> getStudentEnrolledCourses(String userId);
  Future<Either<String, List<QuizResultEntity>>> getStudentQuizResults(String userId);
  Future<Either<String, String>> uploadFile(File file, String path);
  Future<Either<String, void>> saveQuizResult(QuizResultEntity result);
  Future<Either<String, List<QuizResultEntity>>> getTeacherQuizResults(String teacherId);
  Future<Either<String, void>> updateLessonStatus(String userId, String courseId, String lessonId, bool isCompleted);
  Future<Either<String, List<String>>> getCompletedLessons(String userId, String courseId);
  Future<Either<String, List<LeaderboardEntity>>> getLeaderboard();
  Future<Either<String, void>> rateCourse(String courseId, double rating);
  Future<Either<String, List<CommentEntity>>> getLessonComments(String lessonId);
  Future<Either<String, void>> addComment(CommentEntity comment);
  Future<Either<String, List<NotificationEntity>>> getNotifications(String userId);
  Future<Either<String, void>> markNotificationAsRead(String userId, String notificationId);
  Future<Either<String, List<EnrollmentEntity>>> getCourseEnrollments(String teacherId);
  Future<Either<String, void>> sendMessage(MessageEntity message);
  Future<Either<String, List<MessageEntity>>> getChatMessages(String userId, String otherId);
}
