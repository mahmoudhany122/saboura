import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                    'login'.tr(),
                    style: TextStyles.font24BlackBold,
                  ),
                ),
                SizedBox(height: 8.h),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'سجل دخولك للمتابعة في رحلة التعلم.', // Add translation key for this if needed
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
                            'login'.tr(),
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
                              'dont_have_account'.tr(),
                              style: TextStyles.font13GrayRegular,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, Routes.signUpScreen);
                              },
                              child: Text(
                                'signup'.tr(),
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
