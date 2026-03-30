import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final TextEditingController _studentIdController = TextEditingController();
  bool _isLinked = false;
  String _linkedStudentName = '';

  void _linkStudent() {
    if (_studentIdController.text.isNotEmpty) {
      setState(() {
        _linkedStudentName = 'أحمد محمد'; // Mock name for now
        _isLinked = true;
      });
      context.read<CoursesCubit>().getStudentDashboardData(_studentIdController.text);
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('بوابة ولي الأمر'),
        centerTitle: true,
        actions: [
          if (_isLinked) 
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.red), 
              onPressed: () => setState(() => _isLinked = false)
            ),
        ],
      ),
      body: !_isLinked ? _buildLinkSection() : _buildLinkedContent(),
    );
  }

  Widget _buildLinkSection() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.family_restroom, size: 100, color: ColorsManager.mainBlue),
          verticalSpace(20),
          Text('ربط حساب الابن', style: TextStyles.font24BlackBold),
          verticalSpace(10),
          const Text('أدخل معرف الطالب (Student ID) لمتابعة تقدمه فوراً.', textAlign: TextAlign.center),
          verticalSpace(30),
          TextField(
            controller: _studentIdController,
            decoration: InputDecoration(
              hintText: 'مثلاً: user_123...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          verticalSpace(20),
          ElevatedButton(
            onPressed: _linkStudent,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.mainBlue,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('تأكيد الربط ومتابعة ابني', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedContent() {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        final cubit = context.read<CoursesCubit>();
        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStudentHeader(),
              verticalSpace(30),
              _buildNoteSection(),
              verticalSpace(30),
              Text('الكورسات التي يدرسها حالياً', style: TextStyles.font15DarkBlueMedium),
              verticalSpace(15),
              if (cubit.enrolledCourses.isEmpty)
                const Center(child: Text('لا يوجد كورسات مسجلة لهذا الطالب'))
              else
                ...cubit.enrolledCourses.map((c) => _buildSimpleCourseCard(c)),
              verticalSpace(30),
              Text('آخر نتائج الاختبارات', style: TextStyles.font15DarkBlueMedium),
              verticalSpace(15),
              if (cubit.studentResults.isEmpty)
                const Center(child: Text('لم يحل الطالب أي اختبارات بعد'))
              else
                ...cubit.studentResults.map((r) => 
                  _buildResultTile(r.quizTitle, '${r.score}/${r.totalQuestions}', r.timestamp)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentHeader() {
    return FadeInDown(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30, 
              backgroundColor: ColorsManager.mainBlue, 
              child: Icon(Icons.person, color: Colors.white)
            ),
            horizontalSpace(15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_linkedStudentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text('طالب مجتهد 🌟', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.blue.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: Colors.blue), 
              SizedBox(width: 8), 
              Text('كلمة في حق ابني', style: TextStyle(fontWeight: FontWeight.bold))
            ]
          ),
          verticalSpace(10),
          TextField(
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'اكتب ملاحظة ليراها المعلم عن ابنك...', 
              border: InputBorder.none
            ),
            style: TextStyle(fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleCourseCard(CourseEntity course) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.book, color: ColorsManager.mainBlue),
          horizontalSpace(15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('75% تقدم المنهج', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          // Chat with Teacher Button
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: ColorsManager.mainBlue),
            onPressed: () {
              Navigator.pushNamed(context, Routes.chatScreen, arguments: {
                'otherId': course.teacherId,
                'otherName': 'معلم المادة',
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(String title, String score, DateTime date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.quiz, color: Colors.orange),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text(score, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
