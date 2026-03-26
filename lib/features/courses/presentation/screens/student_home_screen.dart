import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().getAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    String userName = CacheHelper.getData(key: 'userName') ?? 'بطل سبورة';

    return Scaffold(
      backgroundColor: ColorsManager.moreLightGray,
      appBar: AppBar(
        title: const Text('استكشف الكورسات'),
        actions: [
          IconButton(
            onPressed: () => context.read<CoursesCubit>().getAllCourses(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is EnrollmentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم الاشتراك بنجاح! اذهب لصفحة تعلمي للبدء 🎓'), backgroundColor: Colors.green),
            );
            context.read<CoursesCubit>().getAllCourses(); // Refresh to update button status
          }
        },
        child: BlocBuilder<CoursesCubit, CoursesState>(
          builder: (context, state) {
            return _buildHomeScreenContent(userName, state);
          },
        ),
      ),
    );
  }

  Widget _buildHomeScreenContent(String userName, CoursesState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(20),
            FadeInDown(
              child: Text(
                'أهلاً بك يا $userName! 👋',
                style: TextStyles.font24BlackBold,
              ),
            ),
            verticalSpace(8),
            Text('جاهز لتعلم شيء جديد اليوم؟', style: TextStyles.font14GrayRegular),
            verticalSpace(24),
            
            // Categories
            FadeInLeft(
              child: SizedBox(
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('الكل'),
                    _buildCategoryChip('لغة عربية'),
                    _buildCategoryChip('رياضيات'),
                    _buildCategoryChip('علوم'),
                  ],
                ),
              ),
            ),
            
            verticalSpace(30),
            Text('الكورسات المتاحة', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
            verticalSpace(16),
            
            if (state is CoursesLoading)
              _buildShimmerLoading()
            else if (state is CoursesLoaded)
              _buildCoursesGrid(state.courses)
            else if (state is CoursesError)
              _buildErrorWidget(state.error)
            else
              const SizedBox.shrink(),
            
            verticalSpace(20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = label),
      child: Container(
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.mainBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? ColorsManager.mainBlue : ColorsManager.lighterGray),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : ColorsManager.gray,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesGrid(List<CourseEntity> courses) {
    if (courses.isEmpty) {
      return Center(child: Text('لا يوجد كورسات متاحة حالياً', style: TextStyles.font14GrayRegular));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.62,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: _buildCourseCard(courses[index]),
        );
      },
    );
  }

  Widget _buildCourseCard(CourseEntity course) {
    // Note: In a full implementation, we'd check if uId is in course.enrolledStudents
    bool isAlreadyEnrolled = false; 

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.courseDetailsScreen, arguments: course);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: course.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: course.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : Container(
                        color: ColorsManager.lighterGray,
                        child: const Center(child: Icon(Icons.school, size: 50, color: ColorsManager.mainBlue)),
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyles.font14DarkBlueMedium.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    verticalSpace(4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(' ${course.rating}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    verticalSpace(4),
                    Text(
                      'مجانًا',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAlreadyEnrolled ? null : () => _showEnrollConfirmation(context, course),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAlreadyEnrolled ? Colors.grey : ColorsManager.mainBlue,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          isAlreadyEnrolled ? 'مشترك بالفعل' : 'اشترك الآن',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
        childAspectRatio: 0.62,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 50, color: Colors.red),
          Text('عذراً، حدث خطأ ما', style: TextStyles.font15DarkBlueMedium),
          TextButton(onPressed: () => context.read<CoursesCubit>().getAllCourses(), child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  void _showEnrollConfirmation(BuildContext context, CourseEntity course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد الاشتراك'),
        content: Text('هل تود الاشتراك في كورس "${course.title}" والبدء في رحلة التعلم؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final uId = CacheHelper.getData(key: 'uId');
              if (uId != null) {
                this.context.read<CoursesCubit>().enrollInCourse(uId, course.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.mainBlue),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
