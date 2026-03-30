import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../domain/entities/course_entity.dart';

class CourseCard extends StatelessWidget {
  final CourseEntity course;
  final bool isAlreadyEnrolled;
  final VoidCallback onEnroll;

  const CourseCard({
    super.key,
    required this.course,
    required this.isAlreadyEnrolled,
    required this.onEnroll,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.courseDetailsScreen, arguments: course);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
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
                        child: const Center(
                          child: Icon(Icons.school, size: 50, color: ColorsManager.mainBlue),
                        ),
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
                        Text(' ${course.rating}',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    verticalSpace(4),
                    Text(
                      'مجانًا',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isAlreadyEnrolled ? null : onEnroll,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAlreadyEnrolled ? Colors.grey : ColorsManager.mainBlue,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(
                          isAlreadyEnrolled ? 'مشترك بالفعل' : 'اشترك الآن',
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
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
}
