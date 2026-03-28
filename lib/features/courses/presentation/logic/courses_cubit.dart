import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/comment_entity.dart';
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
  List<CommentEntity> lessonComments = [];
  Map<String, int> commentLikes = {};

  Future<void> addCourse(CourseEntity course) async {
    emit(const CoursesLoading());
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
  }

  Future<void> getAllCourses() async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getAllCourses();
    result.fold(
      (error) => emit(CoursesError(error)),
      (courses) => emit(CoursesLoaded(courses)),
    );
  }

  Future<void> getTeacherCourses(String teacherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getTeacherCourses(teacherId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (courses) {
        teacherCourses = courses;
        emit(CoursesLoaded(courses));
      },
    );
  }

  Future<void> getStudentDashboardData(String userId) async {
    emit(const CoursesLoading());
    final coursesResult = await _coursesRepo.getStudentEnrolledCourses(userId);
    final resultsResult = await _coursesRepo.getStudentQuizResults(userId);

    coursesResult.fold(
      (error) => emit(CoursesError(error)),
      (courses) {
        enrolledCourses = courses;
        enrolledCourseIds = courses.map((e) => e.id).toList();
      },
    );

    resultsResult.fold(
      (error) => null,
      (results) {
        studentResults = results;
      },
    );

    emit(CoursesLoaded(List.from(enrolledCourses)));
  }

  Future<void> getCompletedLessons(String userId, String courseId) async {
    final result = await _coursesRepo.getCompletedLessons(userId, courseId);
    result.fold(
      (error) => null,
      (completed) {
        completedLessonsIds = completed;
        emit(const LessonStatusUpdated());
      },
    );
  }

  Future<void> toggleLessonStatus(String userId, String courseId, String lessonId, bool isCompleted) async {
    final result = await _coursesRepo.updateLessonStatus(userId, courseId, lessonId, isCompleted);
    result.fold(
      (error) => emit(CoursesError(error)),
      (_) {
        if (isCompleted) {
          completedLessonsIds.add(lessonId);
        } else {
          completedLessonsIds.remove(lessonId);
        }
        emit(const LessonStatusUpdated());
      },
    );
  }

  Future<void> saveQuizResult(QuizResultEntity result) async {
    final response = await _coursesRepo.saveQuizResult(result);
    response.fold(
      (error) => emit(CoursesError(error)),
      (_) => emit(const QuizResultSavedSuccess()),
    );
  }

  Future<String?> uploadFile(File file, String path) async {
    final result = await _coursesRepo.uploadFile(file, path);
    return result.fold(
      (error) {
        emit(CoursesError(error));
        return null;
      },
      (url) => url,
    );
  }

  Future<void> enrollInCourse(String userId, String courseId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.enrollInCourse(userId, courseId);
    await result.fold(
      (error) async => emit(CoursesError(error)),
      (_) async {
        enrolledCourseIds.add(courseId);
        emit(const EnrollmentSuccess());
        await getStudentDashboardData(userId);
      },
    );
  }

  // Comments & Likes logic
  Future<void> getLessonComments(String lessonId) async {
    final result = await _coursesRepo.getLessonComments(lessonId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (comments) {
        lessonComments = comments;
        emit(const LessonStatusUpdated());
      },
    );
  }

  Future<void> addComment(CommentEntity comment) async {
    final result = await _coursesRepo.addComment(comment);
    result.fold(
      (error) => emit(CoursesError(error)),
      (_) {
        lessonComments.insert(0, comment);
        emit(const LessonStatusUpdated());
      },
    );
  }

  void likeComment(String commentId) {
    commentLikes[commentId] = (commentLikes[commentId] ?? 0) + 1;
    emit(const LessonStatusUpdated());
  }
}
