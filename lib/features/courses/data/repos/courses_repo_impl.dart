import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/quiz_result_entity.dart';
import '../../domain/entities/leaderboard_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/message_entity.dart';
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
      final modulesJson = modules.map((m) => ModuleModel(
        id: m.id,
        title: m.title,
        lessons: m.lessons,
      ).toJson()).toList();
      
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
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['name'] ?? 'طالب';

      final enrollmentData = {
        'userId': userId,
        'userName': userName,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0.0,
        'completedLessons': [],
      };

      await _firestore.collection('users').doc(userId).collection('enrolled_courses').doc(courseId).set(enrollmentData);
      await _firestore.collection('enrollments').doc('${userId}_${courseId}').set(enrollmentData);

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
          userAnswers: List<int>.from(data['userAnswers'] ?? []),
        );
      }).toList();

      return Right(results);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
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
      // 1. Save the result
      await _firestore.collection('quiz_results').doc(result.id).set({
        'userId': result.userId,
        'userName': result.userName,
        'courseId': result.courseId,
        'quizId': result.quizId,
        'quizTitle': result.quizTitle,
        'score': result.score,
        'totalQuestions': result.totalQuestions,
        'timestamp': result.timestamp,
        'userAnswers': result.userAnswers,
      });

      // 2. REWARD SYSTEM: Calculate and Add XP to user profile
      int xpGained = result.score * 10;
      if (result.score == result.totalQuestions) xpGained += 50; // Genius Bonus

      await _firestore.collection('users').doc(result.userId).update({
        'points': FieldValue.increment(xpGained),
        'streak': FieldValue.increment(1),
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<QuizResultEntity>>> getTeacherQuizResults(String teacherId) async {
    try {
      final resultsSnapshot = await _firestore
          .collection('quiz_results')
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
          userAnswers: List<int>.from(data['userAnswers'] ?? []),
        );
      }).toList();

      return Right(results);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateLessonStatus(String userId, String courseId, String lessonId, bool isCompleted) async {
    try {
      final ref = _firestore.collection('users').doc(userId).collection('enrolled_courses').doc(courseId);
      final globalRef = _firestore.collection('enrollments').doc('${userId}_${courseId}');

      if (isCompleted) {
        await ref.update({'completedLessons': FieldValue.arrayUnion([lessonId])});
        await globalRef.update({'completedLessons': FieldValue.arrayUnion([lessonId])});
      } else {
        await ref.update({'completedLessons': FieldValue.arrayRemove([lessonId])});
        await globalRef.update({'completedLessons': FieldValue.arrayRemove([lessonId])});
      }
      
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
      await globalRef.update({'progress': progress});
      
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

  @override
  Future<Either<String, List<LeaderboardEntity>>> getLeaderboard() async {
    try {
      final snapshot = await _firestore.collection('users').orderBy('points', descending: true).limit(10).get();
      final leaderboard = snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data();
        return LeaderboardEntity(
          userId: entry.value.id,
          userName: data['name'] ?? 'طالب',
          totalPoints: data['points'] ?? 0,
          rank: entry.key + 1,
        );
      }).toList();
      return Right(leaderboard);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> rateCourse(String courseId, double rating) async {
    try {
      final courseRef = _firestore.collection('courses').doc(courseId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(courseRef);
        if (!snapshot.exists) throw Exception("Course does not exist!");

        double currentRating = (snapshot.data()?['rating'] ?? 0.0).toDouble();
        int currentCount = snapshot.data()?['ratingCount'] ?? 0;

        double newRating = ((currentRating * currentCount) + rating) / (currentCount + 1);
        
        transaction.update(courseRef, {
          'rating': newRating,
          'ratingCount': currentCount + 1,
        });
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CommentEntity>>> getLessonComments(String lessonId) async {
    try {
      final snapshot = await _firestore
          .collection('comments')
          .where('lessonId', isEqualTo: lessonId)
          .get();

      final comments = snapshot.docs.map((doc) {
        final data = doc.data();
        return CommentEntity(
          id: doc.id,
          userId: data['userId'],
          userName: data['userName'],
          lessonId: data['lessonId'],
          content: data['content'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();

      return Right(comments);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addComment(CommentEntity comment) async {
    try {
      await _firestore.collection('comments').doc(comment.id).set({
        'userId': comment.userId,
        'userName': comment.userName,
        'lessonId': comment.lessonId,
        'content': comment.content,
        'timestamp': comment.timestamp,
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<NotificationEntity>>> getNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      final notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationEntity(
          id: doc.id,
          title: data['title'],
          body: data['body'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();

      return Right(notifications);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<EnrollmentEntity>>> getCourseEnrollments(String teacherId) async {
    try {
      final coursesSnapshot = await _firestore.collection('courses').where('teacherId', isEqualTo: teacherId).get();
      final courseIds = coursesSnapshot.docs.map((doc) => doc.id).toList();

      if (courseIds.isEmpty) return const Right([]);

      final enrollmentsSnapshot = await _firestore.collection('enrollments').where('courseId', whereIn: courseIds).get();

      final enrollments = enrollmentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return EnrollmentEntity(
          userId: data['userId'],
          userName: data['userName'],
          courseId: data['courseId'],
          enrolledAt: (data['enrolledAt'] as Timestamp).toDate(),
          progress: (data['progress'] ?? 0.0).toDouble(),
          completedLessons: List<String>.from(data['completedLessons'] ?? []),
        );
      }).toList();

      return Right(enrollments);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> sendMessage(MessageEntity message) async {
    try {
      await _firestore.collection('chats').doc(message.id).set({
        'senderId': message.senderId,
        'senderName': message.senderName,
        'receiverId': message.receiverId,
        'content': message.content,
        'timestamp': message.timestamp,
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<MessageEntity>>> getChatMessages(String userId, String otherId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('senderId', whereIn: [userId, otherId])
          .get();

      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageEntity(
          id: doc.id,
          senderId: data['senderId'],
          senderName: data['senderName'],
          receiverId: data['receiverId'],
          content: data['content'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).where((msg) => 
        (msg.senderId == userId && msg.receiverId == otherId) || 
        (msg.senderId == otherId && msg.receiverId == userId)
      ).toList();

      return Right(messages);
    } catch (e) {
      print("[FIREBASE_ERROR]: $e");
      return Left(e.toString());
    }
  }
}
