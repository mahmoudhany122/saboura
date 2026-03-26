import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../domain/entities/quiz_entity.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  QuizTheme selectedQuizTheme = QuizTheme.classic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة كورس جديد'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: ColorsManager.darkBlue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Center(
                  child: Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorsManager.lighterGray,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorsManager.lightGray),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 50, color: ColorsManager.mainBlue),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text('بيانات الكورس الأساسية', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
              SizedBox(height: 16.h),
              AppTextFormField(
                hintText: 'اسم الكورس',
                validator: (v) => v!.isEmpty ? 'يرجى إدخال اسم الكورس' : null,
              ),
              SizedBox(height: 16.h),
              AppTextFormField(
                hintText: 'نبذة عن الكورس',
                validator: (v) => v!.isEmpty ? 'يرجى إدخال نبذة' : null,
              ),
              SizedBox(height: 30.h),
              Text('إعدادات الاختبار التفاعلي', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
              SizedBox(height: 12.h),
              const Text('اختر طابع الاختبار (خاص بالأطفال):', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16.h),
              SizedBox(
                height: 120.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildThemeCard(QuizTheme.classic, 'كلاسيكي', Icons.quiz),
                    _buildThemeCard(QuizTheme.carRacing, 'سباق سيارات', Icons.directions_car),
                    _buildThemeCard(QuizTheme.space, 'فضاء', Icons.rocket_launch),
                    _buildThemeCard(QuizTheme.monkey, 'القرد المرح', Icons.emoji_emotions),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              FadeInUp(
                child: ElevatedButton(
                  onPressed: () {
                    // Logic to save course and add questions
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.mainBlue,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('إضافة محتوى الكورس', style: TextStyles.font16WhiteSemiBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(QuizTheme theme, String title, IconData icon) {
    bool isSelected = selectedQuizTheme == theme;
    return GestureDetector(
      onTap: () => setState(() => selectedQuizTheme = theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(left: 12.w),
        width: 100.w,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.mainBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? ColorsManager.mainBlue : ColorsManager.lighterGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : ColorsManager.mainBlue, size: 30),
            SizedBox(height: 8.h),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
