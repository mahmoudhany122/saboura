import 'package:equatable/equatable.dart';
import 'quiz_entity.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String teacherId;
  final List<ModuleEntity> modules;
  final double rating;
  final int ratingCount;
  final int enrollmentCount;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.teacherId,
    required this.modules,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.enrollmentCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        teacherId,
        modules,
        rating,
        ratingCount,
        enrollmentCount
      ];
}

class ModuleEntity extends Equatable {
  final String id;
  final String title;
  final List<LessonEntity> lessons;

  const ModuleEntity({
    required this.id,
    required this.title,
    required this.lessons,
  });

  @override
  List<Object?> get props => [id, title, lessons];
}

class LessonEntity extends Equatable {
  final String id;
  final String title;
  final String? videoUrl;
  final String? pdfUrl;
  final QuizEntity? quiz;

  const LessonEntity({
    required this.id,
    required this.title,
    this.videoUrl,
    this.pdfUrl,
    this.quiz,
  });

  @override
  List<Object?> get props => [id, title, videoUrl, pdfUrl, quiz];
}
