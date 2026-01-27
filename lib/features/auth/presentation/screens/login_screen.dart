import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import '../widgets/dont_have_account_text.dart';
import '../widgets/email_and_password.dart';
import '../widgets/login_bloc_listener.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      'login'.tr(),
                      style: TextStyles.font24BlackBold.copyWith(fontSize: 28.sp),
                    ),
                  ),
                  verticalSpace(8),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'سجل دخولك للمتابعة في رحلة التعلم.',
                      style: TextStyles.font14GrayRegular,
                    ),
                  ),
                  verticalSpace(36),
                  EmailAndPassword(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  verticalSpace(24),
                  FadeInUp(
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        if (state is AuthLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.mainBlue,
                            minimumSize: Size(double.infinity, 56.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'login'.tr(),
                            style: TextStyles.font16WhiteSemiBold,
                          ),
                        );
                      },
                    ),
                  ),
                  verticalSpace(20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text('أو سجل دخول بواسطة', style: TextStyles.font13GrayRegular),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  verticalSpace(20),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().loginWithGoogle();
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                      label: const Text('Google', style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: ColorsManager.lighterGray),
                      ),
                    ),
                  ),
                  verticalSpace(30),
                  const DontHaveAccountText(),
                  const LoginBlocListener(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
