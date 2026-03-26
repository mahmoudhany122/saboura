import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/repos/courses_repo.dart';
import '../models/course_model.dart';

class CoursesRepoImpl implements CoursesRepo {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CoursesRepoImpl(this._firestore, this._storage);

  @override
  Future<Either<String, void>> addCourse(CourseEntity course) async {
    try {
      final courseModel = CourseModel(
        id: course.id,
        title: course.title,
        description: course.description,
        imageUrl: course.imageUrl,
        teacherId: course.teacherId,
        modules: course.modules,
        rating: course.rating,
        ratingCount: course.ratingCount,
        enrollmentCount: course.enrollmentCount,
      );
      await _firestore.collection('courses').doc(course.id).set(courseModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CourseEntity>>> getAllCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      final courses = snapshot.docs
          .map((doc) => CourseModel.fromJson(doc.data()))
          .toList();
      return Right(courses);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CourseEntity>>> getTeacherCourses(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      final courses = snapshot.docs
          .map((doc) => CourseModel.fromJson(doc.data()))
          .toList();
      return Right(courses);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateCourseLessons(String courseId, List<ModuleEntity> modules) async {
    try {
      final modulesJson = modules.map((m) => (m as ModuleModel).toJson()).toList();
      await _firestore.collection('courses').doc(courseId).update({
        'modules': modulesJson,
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> enrollInCourse(String userId, String courseId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('enrolled_courses').doc(courseId).set({
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0.0,
        'completedLessons': [],
      });
      await _firestore.collection('courses').doc(courseId).update({
        'enrollmentCount': FieldValue.increment(1),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CourseEntity>>> getStudentEnrolledCourses(String userId) async {
    try {
      final enrolledSnapshot = await _firestore.collection('users').doc(userId).collection('enrolled_courses').get();
      final courseIds = enrolledSnapshot.docs.map((doc) => doc.id).toList();
      
      if (courseIds.isEmpty) return const Right([]);

      final coursesSnapshot = await _firestore
          .collection('courses')
          .where(FieldPath.documentId, whereIn: courseIds)
          .get();

      final courses = coursesSnapshot.docs
          .map((doc) => CourseModel.fromJson(doc.data()))
          .toList();
      return Right(courses);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<QuizResultEntity>>> getStudentQuizResults(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_results')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final results = snapshot.docs.map((doc) {
        final data = doc.data();
        return QuizResultEntity(
          id: doc.id,
          userId: data['userId'],
          userName: data['userName'],
          courseId: data['courseId'],
          quizId: data['quizId'],
          quizTitle: data['quizTitle'],
          score: data['score'],
          totalQuestions: data['totalQuestions'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      return Right(results);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return Right(url);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveQuizResult(QuizResultEntity result) async {
    try {
      await _firestore.collection('quiz_results').doc(result.id).set({
        'userId': result.userId,
        'userName': result.userName,
        'courseId': result.courseId,
        'quizId': result.quizId,
        'quizTitle': result.quizTitle,
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'timestamp': result.timestamp,
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<QuizResultEntity>>> getTeacherQuizResults(String teacherId) async {
    try {
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      final courseIds = coursesSnapshot.docs.map((doc) => doc.id).toList();
      
      if (courseIds.isEmpty) return const Right([]);

      final resultsSnapshot = await _firestore
          .collection('quiz_results')
          .where('courseId', whereIn: courseIds)
          .orderBy('timestamp', descending: true)
          .get();

      final results = resultsSnapshot.docs.map((doc) {
        final data = doc.data();
        return QuizResultEntity(
          id: doc.id,
          userId: data['userId'],
          userName: data['userName'],
          courseId: data['courseId'],
          quizId: data['quizId'],
          quizTitle: data['quizTitle'],
          score: data['score'],
          totalQuestions: data['totalQuestions'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      return Right(results);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateLessonStatus(String userId, String courseId, String lessonId, bool isCompleted) async {
    try {
      final ref = _firestore.collection('users').doc(userId).collection('enrolled_courses').doc(courseId);
      if (isCompleted) {
        await ref.update({
          'completedLessons': FieldValue.arrayUnion([lessonId]),
        });
      } else {
        await ref.update({
          'completedLessons': FieldValue.arrayRemove([lessonId]),
        });
      }
      
      // Calculate progress percentage
      final courseDoc = await _firestore.collection('courses').doc(courseId).get();
      final courseData = CourseModel.fromJson(courseDoc.data()!);
      int totalLessons = 0;
      for (var module in courseData.modules) {
        totalLessons += module.lessons.length;
      }
      
      final enrolledDoc = await ref.get();
      final completedCount = (enrolledDoc.data()?['completedLessons'] as List).length;
      
      double progress = totalLessons > 0 ? (completedCount / totalLessons) : 0.0;
      await ref.update({'progress': progress});
      
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<String>>> getCompletedLessons(String userId, String courseId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('enrolled_courses').doc(courseId).get();
      final completed = List<String>.from(doc.data()?['completedLessons'] ?? []);
      return Right(completed);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
