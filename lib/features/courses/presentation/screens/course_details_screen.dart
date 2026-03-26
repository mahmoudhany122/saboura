import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseEntity course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool isEnrolled = false;

  @override
  void initState() {
    super.initState();
    _checkInitialEnrollment();
  }

  void _checkInitialEnrollment() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      // Load completed lessons to sync state
      context.read<CoursesCubit>().getCompletedLessons(uId, widget.course.id);
      
      // We can also check if this course is in the student's enrolled courses list if we have it
      // For now, we will handle it through the state listener below
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      bottomNavigationBar: !isEnrolled ? _buildPersistentEnrollButton() : null,
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is EnrollmentSuccess) {
            setState(() => isEnrolled = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم الاشتراك في الكورس بنجاح! 🎉'), backgroundColor: Colors.green),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    verticalSpace(24),
                    if (isEnrolled) ...[
                      _buildProgressSection(),
                      verticalSpace(24),
                    ],
                    Text('محتوى المنهج', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                    verticalSpace(15),
                    _buildLessonsList(),
                    verticalSpace(100), // Space for persistent button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: ColorsManager.mainBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.course.id,
          child: widget.course.imageUrl.isNotEmpty
              ? Image.network(widget.course.imageUrl, fit: BoxFit.cover)
              : Container(
                  color: ColorsManager.mainBlue.withOpacity(0.1),
                  child: const Icon(Icons.school, size: 80, color: ColorsManager.mainBlue),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.course.title, style: TextStyles.font24BlackBold),
            verticalSpace(8),
            Text(widget.course.description, style: TextStyles.font14GrayRegular),
            verticalSpace(15),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                horizontalSpace(5),
                Text(widget.course.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                horizontalSpace(20),
                const Icon(Icons.people_outline, color: ColorsManager.mainBlue, size: 20),
                horizontalSpace(5),
                Text('${widget.course.enrollmentCount} طالب مشترك', style: TextStyles.font13GrayRegular),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, state) {
        final completedIds = context.read<CoursesCubit>().completedLessonsIds;
        int totalLessons = 0;
        if (widget.course.modules.isNotEmpty) {
          totalLessons = widget.course.modules[0].lessons.length;
        }
        double progress = totalLessons > 0 ? (completedIds.length / totalLessons) : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('تقدمك في التعلم', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(color: ColorsManager.mainBlue, fontWeight: FontWeight.bold)),
              ],
            ),
            verticalSpace(10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: ColorsManager.lighterGray,
              color: ColorsManager.mainBlue,
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLessonsList() {
    final lessons = widget.course.modules.isNotEmpty ? widget.course.modules[0].lessons : [];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return BlocBuilder<CoursesCubit, CoursesState>(
          builder: (context, state) {
            bool isCompleted = context.read<CoursesCubit>().completedLessonsIds.contains(lesson.id);
            return Container(
              margin: EdgeInsets.only(bottom: 15.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent),
              ),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green.withOpacity(0.1) : ColorsManager.mainBlue.withOpacity(0.1),
                  child: isCompleted 
                    ? const Icon(Icons.check, color: Colors.green) 
                    : Text('${index + 1}', style: const TextStyle(color: ColorsManager.mainBlue)),
                ),
                title: Text(lesson.title, style: TextStyle(fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null)),
                subtitle: Text(isCompleted ? 'مكتمل ✅' : 'اضغط لفتح المحتوى'),
                children: [
                  if (isEnrolled) ...[
                    if (lesson.videoUrl != null) _buildContentItem(Icons.play_circle, 'مشاهدة الفيديو', Colors.red, () {
                      Navigator.pushNamed(context, Routes.lessonViewerScreen, arguments: lesson);
                    }),
                    if (lesson.pdfUrl != null) _buildContentItem(Icons.picture_as_pdf, 'تحميل المذكرة', Colors.orange, () {
                      Navigator.pushNamed(context, Routes.lessonViewerScreen, arguments: lesson);
                    }),
                    if (lesson.quiz != null) _buildContentItem(Icons.quiz, 'دخول الاختبار', Colors.green, () {
                      Navigator.pushNamed(context, Routes.quizScreen, arguments: lesson.quiz);
                    }),
                    ListTile(
                      title: const Text('تحديد كدرس مكتمل', style: TextStyle(fontSize: 13, color: Colors.blue)),
                      trailing: Switch(
                        value: isCompleted,
                        onChanged: (val) {
                          final uId = CacheHelper.getData(key: 'uId');
                          if (uId != null) {
                            context.read<CoursesCubit>().toggleLessonStatus(uId, widget.course.id, lesson.id, val);
                          }
                        },
                      ),
                    ),
                  ] else 
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text('🔒 يجب الاشتراك أولاً لفتح هذا الدرس', style: TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14.sp)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  Widget _buildPersistentEnrollButton() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          bool isLoading = state is CoursesLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : () {
              final uId = CacheHelper.getData(key: 'uId');
              if (uId != null) {
                context.read<CoursesCubit>().enrollInCourse(uId, widget.course.id);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.mainBlue,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading 
              ? const CircularProgressIndicator(color: Colors.white) 
              : Text('اشترك في الكورس الآن - مجاناً', style: TextStyles.font16WhiteSemiBold),
          );
        },
      ),
    );
  }
}
