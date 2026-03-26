import 'package:equatable/equatable.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String teacherId;
  final List<ModuleEntity> modules;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.teacherId,
    required this.modules,
  });

  @override
  List<Object?> get props => [id, title, description, imageUrl, teacherId, modules];
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
  final LessonType type;
  final String contentUrl; // URL for video/pdf, or quiz ID

  const LessonEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.contentUrl,
  });

  @override
  List<Object?> get props => [id, title, type, contentUrl];
}

enum LessonType { video, pdf, quiz }
