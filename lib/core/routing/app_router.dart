import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/courses/presentation/screens/add_course_screen.dart';
import '../../features/courses/presentation/screens/add_lessons_screen.dart';
import '../../features/courses/presentation/screens/add_quiz_screen.dart';
import '../../features/courses/presentation/screens/quiz_screen.dart';
import '../../features/home/presentation/screens/teacher_main_layout.dart';
import '../../features/home/presentation/screens/student_main_layout.dart';
import '../../features/courses/presentation/screens/student_dashboard_screen.dart';
import '../../features/courses/presentation/screens/leaderboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/courses/domain/entities/quiz_entity.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signUpScreen:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case Routes.roleSelectionScreen:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case Routes.addCourseScreen:
        return MaterialPageRoute(builder: (_) => const AddCourseScreen());
      case Routes.addLessonsScreen:
        return MaterialPageRoute(
          builder: (_) => AddLessonsScreen(courseData: arguments as Map<String, dynamic>),
        );
      case Routes.addQuizScreen:
        return MaterialPageRoute(builder: (_) => const AddQuizScreen());
      case Routes.teacherDashboardScreen:
        return MaterialPageRoute(builder: (_) => const TeacherMainLayout());
      case Routes.studentHomeScreen:
        return MaterialPageRoute(builder: (_) => const StudentMainLayout());
      case Routes.studentDashboardScreen:
        return MaterialPageRoute(builder: (_) => const StudentDashboardScreen());
      case Routes.leaderboardScreen:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case Routes.settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case Routes.quizScreen:
        return MaterialPageRoute(
          builder: (_) => QuizScreen(quiz: arguments as QuizEntity),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Home Screen'))),
        );
      default:
        return null;
    }
  }
}
