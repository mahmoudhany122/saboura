import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/course_entity.dart';
import '../widgets/course_card.dart';
import '../widgets/category_filter.dart';

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
            context.read<CoursesCubit>().getAllCourses(); 
          }
        },
        child: BlocBuilder<CoursesCubit, CoursesState>(
          builder: (context, state) {
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
                    
                    CategoryFilter(
                      selectedCategory: selectedCategory,
                      onCategorySelected: (category) {
                        setState(() => selectedCategory = category);
                      },
                    ),
                    
                    verticalSpace(30),
                    Text('الكورسات المتاحة', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
                    verticalSpace(16),
                    
                    _buildBody(state),
                    
                    verticalSpace(20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(CoursesState state) {
    if (state is CoursesLoading) {
      return _buildShimmerLoading();
    } else if (state is CoursesLoaded) {
      return _buildCoursesGrid(state.courses);
    } else if (state is CoursesError) {
      return _buildErrorWidget(state.error);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCoursesGrid(List<CourseEntity> courses) {
    final filteredCourses = selectedCategory == 'الكل'
        ? courses
        : courses.where((c) => c.title.contains(selectedCategory)).toList();

    if (filteredCourses.isEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text('لا يوجد كورسات في هذا القسم حالياً', style: TextStyles.font14GrayRegular),
      ));
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
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        bool isEnrolled = context.read<CoursesCubit>().enrolledCourseIds.contains(course.id);
        
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: CourseCard(
            course: course,
            isAlreadyEnrolled: isEnrolled,
            onEnroll: () => _showEnrollConfirmation(context, course),
          ),
        );
      },
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
