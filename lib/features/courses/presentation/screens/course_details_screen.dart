import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../widgets/course_details_header.dart';
import '../widgets/course_details_progress.dart';
import '../widgets/lesson_expansion_tile.dart';
import '../widgets/persistent_enroll_button.dart';

class CourseDetailsScreen extends StatefulWidget {
  final CourseEntity course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  bool isEnrolled = false;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialEnrollment();
  }

  void _checkInitialEnrollment() {
    final cubit = context.read<CoursesCubit>();
    final uId = CacheHelper.getData(key: 'uId');
    if (cubit.enrolledCourseIds.contains(widget.course.id)) {
      setState(() => isEnrolled = true);
    }
    if (uId != null) cubit.getCompletedLessons(uId, widget.course.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      bottomNavigationBar: !isEnrolled ? PersistentEnrollButton(course: widget.course) : null,
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is EnrollmentSuccess) setState(() => isEnrolled = true);
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
                    CourseDetailsHeader(course: widget.course),
                    verticalSpace(24),
                    if (isEnrolled) ...[
                      CourseDetailsProgress(course: widget.course),
                      verticalSpace(24),
                      _buildRatingSection(), // New Rating Section
                      verticalSpace(24),
                    ],
                    Text('منهج الكورس', style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    verticalSpace(15),
                    _buildCurriculum(),
                    verticalSpace(100), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('ما رأيك في هذا الكورس؟', style: TextStyle(fontWeight: FontWeight.bold)),
          verticalSpace(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() => _userRating = index + 1.0);
                  context.read<CoursesCubit>().rateCourse(widget.course.id, _userRating);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكراً لتقييمك! ❤️'), backgroundColor: Colors.amber));
                },
                icon: Icon(
                  index < _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 35.sp,
                ),
              );
            }),
          ),
        ],
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
              : Container(color: ColorsManager.mainBlue.withOpacity(0.1), child: const Icon(Icons.school, size: 80, color: ColorsManager.mainBlue)),
        ),
      ),
    );
  }

  Widget _buildCurriculum() {
    if (widget.course.modules.isEmpty) return const Center(child: Text('لا يوجد محتوى مضاف لهذا الكورس بعد.'));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.course.modules.length,
      itemBuilder: (context, moduleIndex) {
        final module = widget.course.modules[moduleIndex];
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
          child: ExpansionTile(
            initiallyExpanded: moduleIndex == 0,
            title: Text('الوحدة ${moduleIndex + 1}: ${module.title}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: ColorsManager.darkBlue)),
            subtitle: Text('${module.lessons.length} دروس', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            children: module.lessons.asMap().entries.map((entry) {
              return LessonExpansionTile(lesson: entry.value, index: entry.key, isEnrolled: isEnrolled, courseId: widget.course.id);
            }).toList(),
          ),
        );
      },
    );
  }
}
