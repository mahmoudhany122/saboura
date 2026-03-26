import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  AuthCubit(this._authRepo) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());
    final result = await _authRepo.loginWithEmailAndPassword(email, password);
    result.fold(
      (error) => emit(AuthError(error: error)),
      (user) async {
        await CacheHelper.setData(key: 'uId', value: user.uId);
        await CacheHelper.setData(key: 'role', value: user.role);
        await CacheHelper.setData(key: 'userName', value: user.name);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    emit(const AuthLoading());
    final result = await _authRepo.signUpWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );
    result.fold(
      (error) => emit(AuthError(error: error)),
      (user) async {
        await CacheHelper.setData(key: 'uId', value: user.uId);
        await CacheHelper.setData(key: 'userName', value: user.name);
        emit(AuthSuccess(user));
      },
    );
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthLoading());
    final result = await _authRepo.loginWithGoogle();
    result.fold(
      (error) => emit(AuthError(error: error)),
      (user) async {
        await CacheHelper.setData(key: 'uId', value: user.uId);
        await CacheHelper.setData(key: 'role', value: user.role);
        await CacheHelper.setData(key: 'userName', value: user.name);
        emit(AuthSuccess(user));
      },
    );
  }
}
