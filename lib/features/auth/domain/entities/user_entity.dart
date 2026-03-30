import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uId;
  final String email;
  final String name;
  final String phone;
  final String role; // 'student', 'teacher', 'parent'
  final String? fcmToken;
  final String? profileImageUrl;
  final int points;
  final int streak;
  final List<String> badges;
  final DateTime? lastLoginDate;

  const UserEntity({
    required this.uId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.fcmToken,
    this.profileImageUrl,
    this.points = 0,
    this.streak = 0,
    this.badges = const [],
    this.lastLoginDate,
  });

  @override
  List<Object?> get props => [uId, email, name, phone, role, fcmToken, profileImageUrl, points, streak, badges, lastLoginDate];
}
