import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المعلم'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.addCourseScreen),
        backgroundColor: ColorsManager.mainBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة كورس', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            FadeInDown(
              child: Text(
                'مرحباً أستاذ محمد 👋',
                style: TextStyles.font24BlackBold,
              ),
            ),
            SizedBox(height: 10.h),
            Text('لديك 3 كورسات نشطة و 150 طالب', style: TextStyles.font14GrayRegular),
            SizedBox(height: 30.h),
            Text('كورساتك الحالية', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
            SizedBox(height: 15.h),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildCourseItem(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: ColorsManager.lighterGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.book, color: ColorsManager.mainBlue),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('كورس اللغة العربية - المستوى الأول', style: TextStyles.font15DarkBlueMedium),
                SizedBox(height: 4.h),
                Text('45 طالب مسجل', style: TextStyles.font13GrayRegular),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildStatChip(Icons.play_circle_outline, '12 درس'),
                    SizedBox(width: 10.w),
                    _buildStatChip(Icons.quiz_outlined, '4 اختبارات'),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: ColorsManager.lightGray),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ColorsManager.moreLightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: ColorsManager.mainBlue),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(fontSize: 11.sp, color: ColorsManager.mainBlue)),
        ],
      ),
    );
  }
}
