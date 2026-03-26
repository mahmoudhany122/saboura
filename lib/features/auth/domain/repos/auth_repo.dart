import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<Either<String, UserEntity>> loginWithEmailAndPassword(String email, String password);
  Future<Either<String, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  });
  Future<Either<String, UserEntity>> loginWithGoogle();
  Future<void> logout();
}
