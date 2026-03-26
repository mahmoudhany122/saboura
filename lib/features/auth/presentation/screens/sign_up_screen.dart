import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => current is AuthSuccess || current is AuthError,
          listener: (context, state) {
            if (state is AuthSuccess) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.roleSelectionScreen,
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      'signup'.tr(),
                      style: TextStyles.font24BlackBold.copyWith(fontSize: 28.sp),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'انضم إلينا وابدأ رحلة التعلم اليوم.',
                      style: TextStyles.font14GrayRegular,
                    ),
                  ),
                  SizedBox(height: 36.h),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FadeInLeft(
                          child: AppTextFormField(
                            controller: _nameController,
                            hintText: 'name'.tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال الاسم الكامل';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 18.h),
                        FadeInRight(
                          child: AppTextFormField(
                            controller: _phoneController,
                            hintText: 'phone'.tr(),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال رقم الهاتف';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 18.h),
                        FadeInLeft(
                          child: AppTextFormField(
                            controller: _emailController,
                            hintText: 'email'.tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال البريد الإلكتروني';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 18.h),
                        FadeInRight(
                          child: AppTextFormField(
                            controller: _passwordController,
                            hintText: 'password'.tr(),
                            isObscureText: isPasswordObscureText,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPasswordObscureText = !isPasswordObscureText;
                                });
                              },
                              child: Icon(
                                isPasswordObscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: ColorsManager.mainBlue,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى إدخال كلمة المرور';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 30.h),
                        FadeInUp(
                          child: BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().signUp(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      name: _nameController.text.trim(),
                                      phone: _phoneController.text.trim(),
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
                                  'signup'.tr(),
                                  style: TextStyles.font16WhiteSemiBold,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 24.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'already_have_account'.tr(),
                                style: TextStyles.font13GrayRegular,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'login'.tr(),
                                  style: TextStyles.font13BlueSemiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
