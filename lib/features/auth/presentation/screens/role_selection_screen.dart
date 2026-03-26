import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
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
                  'هل أنت طالب تبحث عن المعرفة أم معلم ترغب في مشاركتها؟',
                  style: TextStyles.font14GrayRegular.copyWith(fontSize: 16.sp),
                ),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Column(
                  children: [
                    FadeInLeft(
                      duration: const Duration(milliseconds: 800),
                      child: RoleCard(
                        title: 'طالب',
                        description: 'استكشف الكورسات، تابع دروسك، وتواصل مع معلميك.',
                        icon: Icons.school_outlined,
                        isSelected: selectedRole == 'student',
                        onTap: () {
                          setState(() {
                            selectedRole = 'student';
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    FadeInRight(
                      duration: const Duration(milliseconds: 800),
                      child: RoleCard(
                        title: 'معلم',
                        description: 'أنشئ كورساتك، أضف دروسك، وتابع تقدم طلابك.',
                        icon: Icons.person_outline,
                        isSelected: selectedRole == 'teacher',
                        onTap: () {
                          setState(() {
                            selectedRole = 'teacher';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                          if (selectedRole == 'teacher') {
                            Navigator.pushNamedAndRemoveUntil(
                                context, Routes.teacherDashboardScreen, (route) => false);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                                context, Routes.studentHomeScreen, (route) => false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.mainBlue,
                    disabledBackgroundColor: ColorsManager.lightGray,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تأكيد الاختيار',
                    style: TextStyles.font16WhiteSemiBold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.mainBlue.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorsManager.mainBlue : ColorsManager.lighterGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: ColorsManager.mainBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? ColorsManager.mainBlue : ColorsManager.moreLightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : ColorsManager.mainBlue,
                size: 32.w,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyles.font15DarkBlueMedium.copyWith(
                      fontSize: 18.sp,
                      color: isSelected ? ColorsManager.mainBlue : ColorsManager.darkBlue,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyles.font13GrayRegular.copyWith(
                      color: isSelected ? ColorsManager.mainBlue.withOpacity(0.7) : ColorsManager.gray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              FadeIn(
                child: const Icon(
                  Icons.check_circle,
                  color: ColorsManager.mainBlue,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
