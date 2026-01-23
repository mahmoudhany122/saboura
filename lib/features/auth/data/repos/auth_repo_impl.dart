import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repo.dart';
import '../models/user_model.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepoImpl(this._firebaseAuth, this._firestore, this._googleSignIn);

  @override
  Future<Either<String, UserEntity>> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return Right(UserModel.fromJson(userDoc.data()!));
      } else {
        return const Left('User data not found in Firestore');
      }
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      
      final userModel = UserModel(
        uId: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        role: '', // To be updated in Role Selection
      );

      await _firestore.collection('users').doc(userModel.uId).set(userModel.toJson());
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(e.message ?? 'An error occurred');
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> loginWithGoogle() async {
    try {
      // Correct way to call signIn() in google_sign_in 6.x
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return const Left('Google Sign-In cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        return Right(UserModel.fromJson(userDoc.data()!));
      } else {
        final userModel = UserModel(
          uId: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          phone: '',
          role: '',
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toJson());
        return Right(userModel);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
