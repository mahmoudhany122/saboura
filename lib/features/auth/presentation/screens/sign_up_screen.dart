import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_text_form_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordObscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: Text(
                    'إنشاء حساب جديد',
                    style: TextStyles.font24BlackBold,
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
                          hintText: 'الاسم الكامل',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال الاسم';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 18.h),
                      FadeInRight(
                        child: AppTextFormField(
                          hintText: 'رقم الهاتف',
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
                          hintText: 'البريد الإلكتروني',
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
                          hintText: 'كلمة المرور',
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
                      SizedBox(height: 24.h),
                      FadeInUp(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.pushNamed(context, Routes.roleSelectionScreen);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.mainBlue,
                            minimumSize: Size(double.infinity, 50.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyles.font16WhiteSemiBold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لديك حساب بالفعل؟ ',
                              style: TextStyles.font13GrayRegular,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'تسجيل الدخول',
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
    );
  }
}
