import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../logic/courses_cubit.dart';
import '../logic/courses_state.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final uId = CacheHelper.getData(key: 'uId');
    if (uId != null) {
      context.read<CoursesCubit>().getNotifications(uId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('التنبيهات'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) {
          if (state is CoursesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final notifications = context.read<CoursesCubit>().notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_outlined, size: 80.w, color: ColorsManager.lightGray),
                  verticalSpace(20),
                  const Text('لا توجد تنبيهات حالياً'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(20.w),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: _buildNotificationItem(notifications[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          final uId = CacheHelper.getData(key: 'uId');
          context.read<CoursesCubit>().markNotificationAsRead(uId!, notification.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : ColorsManager.mainBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notification.isRead ? Colors.transparent : ColorsManager.mainBlue.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: notification.isRead ? ColorsManager.moreLightGray : ColorsManager.mainBlue,
              child: Icon(
                notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: notification.isRead ? Colors.grey : Colors.white,
                size: 20,
              ),
            ),
            horizontalSpace(15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyles.font14DarkBlueMedium.copyWith(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    notification.body,
                    style: TextStyles.font13GrayRegular,
                  ),
                  verticalSpace(8),
                  Text(
                    DateFormat('yyyy-MM-dd | hh:mm a').format(notification.timestamp),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: ColorsManager.mainBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
