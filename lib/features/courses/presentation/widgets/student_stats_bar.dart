import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class StudentStatsBar extends StatelessWidget {
  final int points;
  final int streak;

  const StudentStatsBar({
    super.key,
    required this.points,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.stars_rounded,
            color: Colors.amber,
            value: points.toString(),
            label: 'نقطة',
          ),
          Container(width: 1, height: 30.h, color: Colors.grey[200]),
          _buildStatItem(
            icon: Icons.local_fire_department_rounded,
            color: Colors.orange,
            value: streak.toString(),
            label: 'يوم متواصل',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyles.font15DarkBlueMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
