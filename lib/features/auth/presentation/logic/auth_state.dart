abstract class AuthState<T> {
  const AuthState();
}

class AuthInitial<T> extends AuthState<T> {
  const AuthInitial();
}

class AuthLoading<T> extends AuthState<T> {
  const AuthLoading();
}

class AuthSuccess<T> extends AuthState<T> {
  final T data;
  const AuthSuccess(this.data);
}

class AuthError<T> extends AuthState<T> {
  final String error;
  const AuthError({required this.error});
}
