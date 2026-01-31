import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  'اختر نوع الحساب',
                  style: TextStyles.font24BlackBold.copyWith(fontSize: 28.sp),
                ),
              ),
              SizedBox(height: 12.h),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'هل أنت طالب، معلم، أم ولي أمر يرغب في متابعة أبنائه؟',
                  style: TextStyles.font14GrayRegular.copyWith(fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRoleOption(
                        title: 'طالب',
                        desc: 'استكشف الكورسات، تعلم والعب.',
                        icon: Icons.school_outlined,
                        role: 'student',
                      ),
                      SizedBox(height: 15.h),
                      _buildRoleOption(
                        title: 'معلم',
                        desc: 'أنشئ دروسك وتابع تقدم طلابك.',
                        icon: Icons.person_outline,
                        role: 'teacher',
                      ),
                      SizedBox(height: 15.h),
                      _buildRoleOption(
                        title: 'ولي أمر',
                        desc: 'تابع نتائج ابنك ومستواه الدراسي.',
                        icon: Icons.family_restroom_outlined,
                        role: 'parent',
                      ),
                    ],
                  ),
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () async {
                          await CacheHelper.setData(key: 'role', value: selectedRole);
                          if (!mounted) return;

                          if (selectedRole == 'teacher') {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.teacherDashboardScreen, (route) => false);
                          } else if (selectedRole == 'student') {
                            Navigator.pushNamedAndRemoveUntil(context, Routes.studentHomeScreen, (route) => false);
                          } else {
                            // Link to Parent Dashboard - FIXED
                            Navigator.pushNamedAndRemoveUntil(context, Routes.parentDashboardScreen, (route) => false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.mainBlue,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('تأكيد الاختيار', style: TextStyles.font16WhiteSemiBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({required String title, required String desc, required IconData icon, required String role}) {
    bool isSelected = selectedRole == role;
    return FadeInLeft(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected ? ColorsManager.mainBlue.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? ColorsManager.mainBlue : ColorsManager.lighterGray, width: isSelected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? ColorsManager.mainBlue : Colors.grey, size: 30),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? ColorsManager.mainBlue : Colors.black)),
                    Text(desc, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: ColorsManager.mainBlue),
            ],
          ),
        ),
      ),
    );
  }
}
