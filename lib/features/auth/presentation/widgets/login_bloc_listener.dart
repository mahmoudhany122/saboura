import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/routes.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class LoginBlocListener extends StatelessWidget {
  const LoginBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current is AuthSuccess || current is AuthError,
      listener: (context, state) {
        if (state is AuthSuccess) {
          final user = state.user;
          
          // Smart Routing Logic: Check if user already has a role
          if (user.role == 'teacher') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.teacherDashboardScreen,
              (route) => false,
            );
          } else if (user.role == 'student') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.studentHomeScreen,
              (route) => false,
            );
          } else if (user.role == 'parent') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.parentDashboardScreen,
              (route) => false,
            );
          } else {
            // Only new users without a role go to Selection Screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.roleSelectionScreen,
              (route) => false,
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
