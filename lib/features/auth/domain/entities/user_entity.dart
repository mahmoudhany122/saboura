import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uId;
  final String email;
  final String name;
  final String phone;
  final String role; // 'student' or 'teacher'
  final String? fcmToken;

  const UserEntity({
    required this.uId,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [uId, email, name, phone, role, fcmToken];
}
