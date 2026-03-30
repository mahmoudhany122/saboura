import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/service_locator.dart' as di;
import 'core/helpers/cache_helper.dart';
import 'core/helpers/notification_helper.dart';
import 'core/logic/app_cubit.dart';
import 'core/logic/bloc_observer.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theming/colors.dart';
import 'features/auth/presentation/logic/auth_cubit.dart';
import 'features/courses/presentation/logic/courses_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Core Services
  await EasyLocalization.ensureInitialized();
  await CacheHelper.init();
  
  // These MUST be awaited to avoid GetIt errors during provider creation
  await Firebase.initializeApp();
  await di.init();
  
  // Optional services can run in background
  NotificationHelper.init();
  
  Bloc.observer = MyBlocObserver();
  bool isDark = CacheHelper.getData(key: 'isDark') ?? false;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AppCubit()..changeTheme(fromCache: isDark)),
          BlocProvider(create: (context) => di.sl<AuthCubit>()),
          BlocProvider(create: (context) => di.sl<CoursesCubit>()),
        ],
        child: SabouraApp(appRouter: AppRouter()),
      ),
    ),
  );
}

class SabouraApp extends StatelessWidget {
  final AppRouter appRouter;
  const SabouraApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          child: MaterialApp(
            title: 'Saboura',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            themeMode: context.read<AppCubit>().isDark ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              primaryColor: ColorsManager.mainBlue,
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              fontFamily: 'Cairo',
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: ColorsManager.darkBlue),
                titleTextStyle: TextStyle(color: ColorsManager.darkBlue, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: ColorsManager.mainBlue,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splashScreen,
            onGenerateRoute: appRouter.generateRoute,
          ),
        );
      },
    );
  }
}
