import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';

abstract class CoursesState {
  const CoursesState();
}

class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

class CoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;
  const CoursesLoaded(this.courses);
}

class TeacherCoursesLoaded extends CoursesState {
  final List<CourseEntity> courses;
  const TeacherCoursesLoaded(this.courses);
}

class QuizResultsLoaded extends CoursesState {
  final List<QuizResultEntity> results;
  const QuizResultsLoaded(this.results);
}

class LessonStatusUpdated extends CoursesState {
  const LessonStatusUpdated();
}

class CourseAddedSuccess extends CoursesState {
  const CourseAddedSuccess();
}

class EnrollmentSuccess extends CoursesState {
  const EnrollmentSuccess();
}

class QuizResultSavedSuccess extends CoursesState {
  const QuizResultSavedSuccess();
}

class FileUploadedSuccess extends CoursesState {
  final String url;
  const FileUploadedSuccess(this.url);
}

class CoursesError extends CoursesState {
  final String error;
  const CoursesError(this.error);
}
