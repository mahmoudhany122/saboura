import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uId,
    required super.email,
    required super.name,
    required super.phone,
    required super.role,
    super.fcmToken,
    super.profileImageUrl,
    super.points,
    super.streak,
    super.badges,
    super.lastLoginDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      fcmToken: json['fcmToken'],
      profileImageUrl: json['profileImageUrl'],
      points: json['points'] ?? 0,
      streak: json['streak'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      lastLoginDate: json['lastLoginDate'] != null 
          ? DateTime.parse(json['lastLoginDate']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'fcmToken': fcmToken,
      'profileImageUrl': profileImageUrl,
      'points': points,
      'streak': streak,
      'badges': badges,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
    };
  }
}
