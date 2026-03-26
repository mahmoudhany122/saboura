import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/logic/app_cubit.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('settings'.tr())),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // Theme Toggle
            FadeInLeft(
              child: _buildSettingTile(
                icon: Icons.dark_mode_outlined,
                title: 'الوضع المظلم',
                trailing: BlocBuilder<AppCubit, AppState>(
                  builder: (context, state) {
                    return Switch(
                      value: context.read<AppCubit>().isDark,
                      onChanged: (value) {
                        context.read<AppCubit>().changeTheme();
                      },
                      activeColor: ColorsManager.mainBlue,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 15.h),
            
            // Language Toggle
            FadeInRight(
              child: _buildSettingTile(
                icon: Icons.language_outlined,
                title: 'اللغة (Language)',
                trailing: TextButton(
                  onPressed: () {
                    if (context.locale == const Locale('ar')) {
                      context.setLocale(const Locale('en'));
                    } else {
                      context.setLocale(const Locale('ar'));
                    }
                  },
                  child: Text(
                    context.locale == const Locale('ar') ? 'English' : 'العربية',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 15.h),
            
            // Profile Info (Static for now)
            FadeInLeft(
              child: _buildSettingTile(
                icon: Icons.person_outline,
                title: 'تعديل الملف الشخصي',
                onTap: () {},
              ),
            ),
            SizedBox(height: 15.h),

            // logout
            FadeInRight(
              child: _buildSettingTile(
                icon:  Icons.logout,
                title: 'تسجيل الخروج'.tr(),
                  onTap: () {
                    CacheHelper.clearData();
                    Navigator.pushNamedAndRemoveUntil(
                        context, Routes.loginScreen, (route) => false);
                  },
                ),
              ),

            SizedBox(height: 15.h),
            const Spacer(),
            
            // App Version Info
            FadeInUp(
              child: Column(
                children: [
                  Text('تطبيق سبوره', style: TextStyles.font14DarkBlueMedium),
                  Text('v 1.0.0', style: TextStyles.font13GrayRegular),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: ColorsManager.mainBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ColorsManager.mainBlue),
      ),
      title: Text(title, style: TextStyles.font14DarkBlueMedium),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: ColorsManager.lighterGray),
      ),
    );
  }
}
