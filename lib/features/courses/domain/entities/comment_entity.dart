import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String lessonId;
  final String content;
  final DateTime timestamp;

  const CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lessonId,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, userName, lessonId, content, timestamp];
}
