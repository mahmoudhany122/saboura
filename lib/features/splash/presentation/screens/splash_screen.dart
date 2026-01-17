import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check Auto Login Logic
    String? uId = CacheHelper.getData(key: 'uId');
    String? role = CacheHelper.getData(key: 'role');

    if (uId != null) {
      if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, Routes.teacherDashboardScreen);
      } else if (role == 'student') {
        Navigator.pushReplacementNamed(context, Routes.studentHomeScreen);
      } else {
        Navigator.pushReplacementNamed(context, Routes.roleSelectionScreen);
      }
    } else {
      bool? onBoardingDone = CacheHelper.getData(key: 'onBoardingDone');
      if (onBoardingDone == true) {
        Navigator.pushReplacementNamed(context, Routes.loginScreen);
      } else {
        Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeInDown(
          duration: const Duration(milliseconds: 1500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: ColorsManager.mainBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.mainBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: TextStyles.font32BlueBold.copyWith(
                      color: Colors.white,
                      fontSize: 60.sp,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Text(
                  'منصه سبورة'.tr(),
                  style: TextStyles.font32BlueBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
