import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
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

  @override
  void initState() {
    super.initState();
    _checkInitialEnrollment();
  }

  void _checkInitialEnrollment() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getCompletedLessons(uId, widget.course.id);
      // Logic to determine initial enrollment status could go here
      // or be part of the Bloc state. For now, we listen to EnrollmentSuccess.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      bottomNavigationBar: !isEnrolled ? PersistentEnrollButton(course: widget.course) : null,
      body: BlocListener<CoursesCubit, CoursesState>(
        listener: (context, state) {
          if (state is EnrollmentSuccess) {
            setState(() => isEnrolled = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('تم الاشتراك في الكورس بنجاح! 🎉'),
                  backgroundColor: Colors.green),
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
                    CourseDetailsHeader(course: widget.course),
                    verticalSpace(24),
                    if (isEnrolled) ...[
                      CourseDetailsProgress(course: widget.course),
                      verticalSpace(24),
                    ],
                    Text('محتوى المنهج',
                        style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 18.sp)),
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

  Widget _buildLessonsList() {
    final lessons = widget.course.modules.isNotEmpty ? widget.course.modules[0].lessons : [];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        return LessonExpansionTile(
          lesson: lessons[index],
          index: index,
          isEnrolled: isEnrolled,
          courseId: widget.course.id,
        );
      },
    );
  }
}
