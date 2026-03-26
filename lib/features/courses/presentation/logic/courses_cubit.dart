import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/repos/courses_repo.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final CoursesRepo _coursesRepo;
  CoursesCubit(this._coursesRepo) : super(const CoursesInitial());

  List<String> enrolledCourseIds = [];
  List<String> completedLessonsIds = [];

  Future<void> addCourse(CourseEntity course) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.addCourse(course);
    result.fold(
      (error) => emit(CoursesError(error)),
      (_) => emit(const CourseAddedSuccess()),
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
      (courses) => emit(CoursesLoaded(courses)),
    );
  }

  Future<void> getTeacherQuizResults(String teacherId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getTeacherQuizResults(teacherId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (results) => emit(QuizResultsLoaded(results)),
    );
  }

  Future<void> getStudentEnrolledCourses(String userId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getStudentEnrolledCourses(userId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (courses) {
        enrolledCourseIds = courses.map((e) => e.id).toList();
        emit(CoursesLoaded(courses));
      },
    );
  }

  Future<void> getStudentQuizResults(String userId) async {
    emit(const CoursesLoading());
    final result = await _coursesRepo.getStudentQuizResults(userId);
    result.fold(
      (error) => emit(CoursesError(error)),
      (results) => emit(QuizResultsLoaded(results)),
    );
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
    result.fold(
      (error) => emit(CoursesError(error)),
      (_) {
        enrolledCourseIds.add(courseId);
        emit(const EnrollmentSuccess());
      },
    );
  }
}
