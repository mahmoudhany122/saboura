import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.mainBlue,
      appBar: AppBar(
        title: const Text('لوحة الأبطال 🏆', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTopThree(),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 20.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  return _buildLeaderboardItem(index + 4);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Container(
      height: 220.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopUser(rank: 2, name: 'سارة', points: 950, height: 140.h, color: Colors.grey.shade300),
          _buildTopUser(rank: 1, name: 'أحمد', points: 1200, height: 170.h, color: Colors.amber),
          _buildTopUser(rank: 3, name: 'ياسين', points: 880, height: 120.h, color: Colors.orange.shade300),
        ],
      ),
    );
  }

  Widget _buildTopUser({required int rank, required String name, required int points, required double height, required Color color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FadeInUp(
          child: CircleAvatar(
            radius: rank == 1 ? 40.r : 35.r,
            backgroundColor: color,
            child: CircleAvatar(
              radius: rank == 1 ? 36.r : 32.r,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 30, color: color),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 80.w,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$points pt', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: Text('$rank', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(int rank) {
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text('#$rank', style: TextStyles.font14DarkBlueMedium.copyWith(color: Colors.grey)),
            SizedBox(width: 15.w),
            const CircleAvatar(backgroundColor: ColorsManager.moreLightGray, child: Icon(Icons.person, color: Colors.grey)),
            SizedBox(width: 15.w),
            Expanded(child: Text('طالب مجتهد #$rank', style: TextStyles.font14DarkBlueMedium)),
            Text('${1000 - (rank * 50)} pt', style: TextStyle(color: ColorsManager.mainBlue, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
