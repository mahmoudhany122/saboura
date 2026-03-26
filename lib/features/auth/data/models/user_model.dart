import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uId,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }
}
