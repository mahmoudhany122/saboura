import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/di/service_locator.dart' as di;
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';
import 'core/theming/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // await Firebase.initializeApp(); // Uncomment after adding firebase options
  await di.init();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: SabouraApp(appRouter: AppRouter()),
    ),
  );
}

class SabouraApp extends StatelessWidget {
  final AppRouter appRouter;
  const SabouraApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: MaterialApp(
        title: 'Saboura',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primaryColor: ColorsManager.mainBlue,
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
          fontFamily: 'Cairo', // Assuming Cairo font is added
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: ColorsManager.mainBlue,
          // Add more dark theme configurations
        ),
        themeMode: ThemeMode.light, // Can be controlled by a cubit
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.splashScreen,
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
