import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repos/auth_repo_impl.dart';
import '../../features/auth/domain/repos/auth_repo.dart';
import '../../features/auth/presentation/logic/auth_cubit.dart';
import '../../features/courses/data/repos/courses_repo_impl.dart';
import '../../features/courses/domain/repos/courses_repo.dart';
import '../../features/courses/presentation/logic/courses_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Clear old registrations to prevent hang during Hot Restart
  await sl.reset();

  // Features - Auth
  sl.registerFactory(() => AuthCubit(sl()));
  sl.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(sl(), sl(), sl()));

  // Features - Courses
  sl.registerFactory(() => CoursesCubit(sl()));
  sl.registerLazySingleton<CoursesRepo>(() => CoursesRepoImpl(sl(), sl()));

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
