import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/leaderboard_entity.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CoursesCubit>().getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.mainBlue,
      appBar: AppBar(
        title: const Text('لوحة الأبطال 🏆', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          
          // Assuming we added a way to get leaderboard data in Cubit
          // For now, let's use a list from state if we updated the state file
          final leaderboard = state is LeaderboardLoaded ? state.leaderboard : <LeaderboardEntity>[];

          if (leaderboard.isEmpty && state is! CoursesLoading) {
            return const Center(child: Text('لا يوجد متصدرين حالياً', style: TextStyle(color: Colors.white)));
          }

          return Column(
            children: [
              if (leaderboard.length >= 3) _buildTopThree(leaderboard.sublist(0, 3)),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20.h),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: leaderboard.length > 3 
                    ? ListView.builder(
                        itemCount: leaderboard.length - 3,
                        itemBuilder: (context, index) {
                          return _buildLeaderboardItem(leaderboard[index + 3]);
                        },
                      )
                    : const Center(child: Text('كن أول من ينضم لقائمة الأبطال!')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardEntity> topThree) {
    // Sort to show 2nd, 1st, 3rd
    final displayOrder = [
      if (topThree.length > 1) topThree[1], // 2nd
      topThree[0], // 1st
      if (topThree.length > 2) topThree[2], // 3rd
    ];

    return Container(
      height: 240.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: displayOrder.map((user) {
          int rank = leaderboardRank(user, topThree);
          return _buildTopUser(
            rank: rank,
            name: user.userName,
            points: user.totalPoints,
            height: rank == 1 ? 170.h : (rank == 2 ? 140.h : 120.h),
            color: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey.shade300 : Colors.orange.shade300),
          );
        }).toList(),
      ),
    );
  }

  int leaderboardRank(LeaderboardEntity user, List<LeaderboardEntity> list) {
    return list.indexOf(user) + 1;
  }

  Widget _buildTopUser({required int rank, required String name, required int points, required double height, required Color color}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FadeInUp(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (rank == 1) 
                const Padding(
                  padding: EdgeInsets.only(bottom: 45),
                  child: Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
                ),
              CircleAvatar(
                radius: rank == 1 ? 40.r : 35.r,
                backgroundColor: color,
                child: CircleAvatar(
                  radius: rank == 1 ? 36.r : 32.r,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: color),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: 90.w,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$points XP', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              CircleAvatar(
                radius: 14,
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

  Widget _buildLeaderboardItem(LeaderboardEntity user) {
    return FadeInUp(
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Text('#${user.rank}', style: TextStyles.font14DarkBlueMedium.copyWith(color: Colors.grey, fontWeight: FontWeight.bold)),
            SizedBox(width: 15.w),
            CircleAvatar(
              backgroundColor: ColorsManager.mainBlue.withOpacity(0.1),
              child: const Icon(Icons.person, color: ColorsManager.mainBlue),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(user.userName, 
                style: TextStyles.font14DarkBlueMedium.copyWith(fontWeight: FontWeight.bold)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: ColorsManager.mainBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${user.totalPoints} XP', 
                style: const TextStyle(color: ColorsManager.mainBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
