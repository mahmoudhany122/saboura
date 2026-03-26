import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.teacherId,
    required super.modules,
    super.rating,
    super.ratingCount,
    super.enrollmentCount,
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
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      enrollmentCount: json['enrollmentCount'] ?? 0,
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
      'rating': rating,
      'ratingCount': ratingCount,
      'enrollmentCount': enrollmentCount,
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
    super.videoUrl,
    super.pdfUrl,
    super.quiz,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'],
      title: json['title'],
      videoUrl: json['videoUrl'],
      pdfUrl: json['pdfUrl'],
      quiz: json['quiz'] != null ? _quizFromJson(json['quiz']) : null,
    );
  }

  static QuizEntity _quizFromJson(Map<String, dynamic> json) {
    return QuizEntity(
      id: json['id'],
      title: json['title'],
      durationInMinutes: json['durationInMinutes'],
      questions: (json['questions'] as List)
          .map((q) => QuestionEntity(
                id: q['id'],
                questionText: q['questionText'],
                options: List<String>.from(q['options']),
                correctAnswerIndex: q['correctAnswerIndex'],
              ))
          .toList(),
      theme: QuizTheme.values.byName(json['theme'] ?? 'classic'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'quiz': quiz != null ? _quizToJson(quiz!) : null,
    };
  }

  static Map<String, dynamic> _quizToJson(QuizEntity quiz) {
    return {
      'id': quiz.id,
      'title': quiz.title,
      'durationInMinutes': quiz.durationInMinutes,
      'theme': quiz.theme.name,
      'questions': quiz.questions
          .map((q) => {
                'id': q.id,
                'questionText': q.questionText,
                'options': q.options,
                'correctAnswerIndex': q.correctAnswerIndex,
              })
          .toList(),
    };
  }
}
