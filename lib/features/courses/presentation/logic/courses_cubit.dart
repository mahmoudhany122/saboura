import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repos/courses_repo.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesRepo _coursesRepo;
  CoursesCubit(this._coursesRepo) : super(const CoursesInitial());

  List<String> enrolledCourseIds = [];
  List<String> completedLessonsIds = [];
  List<CourseEntity> teacherCourses = []; 
  List<CourseEntity> enrolledCourses = []; 
  List<QuizResultEntity> studentResults = [];
  List<EnrollmentEntity> courseEnrollments = [];
  List<CommentEntity> lessonComments = [];
  List<NotificationEntity> notifications = [];
  List<MessageEntity> chatMessages = [];
  Map<String, int> commentLikes = {};
  List<String> userBadges = [];

  Future<void> addCourse(CourseEntity course) async {
    emit(const CoursesLoading());
    try {
      final result = await _coursesRepo.addCourse(course);
      result.fold(
        (error) => emit(CoursesError(error)),
        (_) {
          final index = teacherCourses.indexWhere((c) => c.id == course.id);
          if (index != -1) {
            teacherCourses[index] = course;
          } else {
            teacherCourses.add(course);
          }
          emit(const CourseAddedSuccess());
          emit(CoursesLoaded(List.from(teacherCourses)));
        },
      );
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> getTeacherQuizResults(String teacherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getTeacherQuizResults(teacherId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (results) {
        studentResults = results;
        emit(QuizResultsLoaded(results));
      },
    );
  }

  Future<void> getCourseEnrollments(String teacherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getCourseEnrollments(teacherId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (enrollments) {
        courseEnrollments = enrollments;
        emit(QuizResultsLoaded(studentResults)); 
      },
    );
  }

  Future<void> saveQuizResult(QuizResultEntity result) async {
    final response = await _coursesRepo.saveQuizResult(result);
    response.fold(
      (error) => emit(CoursesError(error)),
      (_) {
        if (result.score == result.totalQuestions) _awardBadge('وسام النابغ ⚡');
        emit(const QuizResultSavedSuccess());
      },
    );
  }

  Future<void> sendMessage(MessageEntity message) async {
    final result = await _coursesRepo.sendMessage(message);
    result.fold(
      (error) => emit(CoursesError(error)),
      (_) {
        chatMessages.add(message);
        emit(const LessonStatusUpdated()); 
      },
    );
  }

  Future<void> getChatMessages(String userId, String otherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getChatMessages(userId, otherId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (messages) {
        chatMessages = messages;
        emit(const LessonStatusUpdated());
      },
    );
  }

  Future<void> getAllCourses() async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getAllCourses();
    result.fold((error) => emit(CoursesError(error)), (courses) {
      teacherCourses = courses;
      emit(CoursesLoaded(courses));
    });
  }

  Future<void> getStudentDashboardData(String userId) async {
    try {
      final coursesResult = await _coursesRepo.getStudentEnrolledCourses(userId);
      final resultsResult = await _coursesRepo.getStudentQuizResults(userId);
      coursesResult.fold((error) => null, (courses) {
        enrolledCourses = courses;
        enrolledCourseIds = courses.map((e) => e.id).toList();
      });
      resultsResult.fold((error) => null, (results) => studentResults = results);
      emit(CoursesLoaded(List.from(enrolledCourses)));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> getTeacherCourses(String teacherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getTeacherCourses(teacherId);
    result.fold((error) => emit(CoursesError(error)), (courses) {
      teacherCourses = courses;
      emit(CoursesLoaded(courses));
    });
  }

  Future<void> enrollInCourse(String userId, String courseId) async {
    final result = await _coursesRepo.enrollInCourse(userId, courseId);
    await result.fold((error) async => emit(CoursesError(error)), (_) async {
      if (!enrolledCourseIds.contains(courseId)) enrolledCourseIds.add(courseId);
      emit(const EnrollmentSuccess());
      await getStudentDashboardData(userId);
    });
  }

  Future<void> getNotifications(String userId) async {
    final result = await _coursesRepo.getNotifications(userId);
    result.fold((error) => null, (notifs) {
      notifications = notifs;
      emit(NotificationsLoaded(notifs));
    });
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    final result = await _coursesRepo.markNotificationAsRead(userId, notificationId);
    result.fold(
      (error) => null,
      (_) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = NotificationEntity(
            id: notifications[index].id,
            title: notifications[index].title,
            body: notifications[index].body,
            timestamp: notifications[index].timestamp,
            isRead: true,
          );
          emit(NotificationsLoaded(List.from(notifications)));
        }
      },
    );
  }

  Future<void> getLeaderboard() async {
    final result = await _coursesRepo.getLeaderboard();
    result.fold((error) => null, (leaderboard) => emit(LeaderboardLoaded(leaderboard)));
  }

  Future<String?> uploadFile(File file, String path) async {
    final result = await _coursesRepo.uploadFile(file, path);
    return result.fold((error) => null, (url) => url);
  }

  Future<void> getCompletedLessons(String userId, String courseId) async {
    final result = await _coursesRepo.getCompletedLessons(userId, courseId);
    result.fold((error) => null, (completed) {
      completedLessonsIds = completed;
      emit(const LessonStatusUpdated());
    });
  }

  Future<void> toggleLessonStatus(String userId, String courseId, String lessonId, bool isCompleted) async {
    await _coursesRepo.updateLessonStatus(userId, courseId, lessonId, isCompleted);
    if (isCompleted) {
      if (!completedLessonsIds.contains(lessonId)) completedLessonsIds.add(lessonId);
    } else {
      completedLessonsIds.remove(lessonId);
    }
    emit(const LessonStatusUpdated());
  }

  Future<void> getLessonComments(String lessonId) async {
    final result = await _coursesRepo.getLessonComments(lessonId);
    result.fold((error) => null, (comments) {
      lessonComments = comments;
      emit(const LessonStatusUpdated());
    });
  }

  Future<void> addComment(CommentEntity comment) async {
    await _coursesRepo.addComment(comment);
    lessonComments.insert(0, comment);
    emit(const LessonStatusUpdated());
  }

  Future<void> rateCourse(String courseId, double rating) async {
    await _coursesRepo.rateCourse(courseId, rating);
  }

  void _awardBadge(String badgeName) {
    if (!userBadges.contains(badgeName)) {
      userBadges.add(badgeName);
      emit(const LessonStatusUpdated()); 
    }
  }
}
