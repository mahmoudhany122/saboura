import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.teacherId,
    required super.modules,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      teacherId: json['teacherId'],
      modules: (json['modules'] as List)
          .map((m) => ModuleModel.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'teacherId': teacherId,
      'modules': modules.map((m) => (m as ModuleModel).toJson()).toList(),
    };
  }
}

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    required super.id,
    required super.title,
    required super.lessons,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      title: json['title'],
      lessons: (json['lessons'] as List)
          .map((l) => LessonModel.fromJson(l))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((l) => (l as LessonModel).toJson()).toList(),
    };
  }
}

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.title,
    required super.type,
    required super.contentUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      type: LessonType.values.byName(json['type']),
      contentUrl: json['contentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'contentUrl': contentUrl,
    };
  }
}
