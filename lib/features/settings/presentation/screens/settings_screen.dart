import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/helpers/cache_helper.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/helpers/image_upload_helper.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import '../../../courses/presentation/logic/courses_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;
  String? profilePic;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    profilePic = CacheHelper.getData(key: 'profileImageUrl');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => isUploading = true);
      final file = File(pickedFile.path);
      
      // Upload to ImgBB for free storage
      final url = await ImageUploadHelper.uploadImage(file);
      
      if (url != null) {
        setState(() {
          profilePic = url;
          isUploading = false;
        });
        await CacheHelper.setData(key: 'profileImageUrl', value: url);
        // Here you would also update Firestore user profile
      } else {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userName = CacheHelper.getData(key: 'userName') ?? 'مستخدم';
    String userRole = CacheHelper.getData(key: 'role') ?? 'student';

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات والملف الشخصي'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildProfileHeader(userName, userRole),
            verticalSpace(30),
            _buildSettingsSection(),
            verticalSpace(40),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String role) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: ColorsManager.moreLightGray,
                backgroundImage: profilePic != null ? NetworkImage(profilePic!) : null,
                child: profilePic == null ? Icon(Icons.person, size: 50.r, color: Colors.grey) : null,
              ),
              if (isUploading) const CircularProgressIndicator(),
              CircleAvatar(
                backgroundColor: ColorsManager.mainBlue,
                radius: 18.r,
                child: IconButton(
                  icon: Icon(Icons.camera_alt, size: 18.r, color: Colors.white),
                  onPressed: _pickImage,
                ),
              ),
            ],
          ),
          verticalSpace(15),
          Text(name, style: TextStyles.font15DarkBlueMedium.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          Text(role == 'teacher' ? 'معلم معتمد 🎓' : 'طالب مجتهد 🌟', style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _settingsTile(Icons.notifications_active_outlined, 'تفعيل التنبيهات', isSwitch: true),
          const Divider(height: 1),
          _settingsTile(Icons.language_outlined, 'لغة التطبيق', trailing: 'العربية'),
          const Divider(height: 1),
          _settingsTile(Icons.dark_mode_outlined, 'الوضع الليلي', isSwitch: true, initialValue: false),
          const Divider(height: 1),
          _settingsTile(Icons.info_outline, 'عن منصه سبورة'),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, {bool isSwitch = false, bool initialValue = true, String? trailing}) {
    return ListTile(
      leading: Icon(icon, color: ColorsManager.mainBlue),
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      trailing: isSwitch 
        ? Switch(value: initialValue, onChanged: (v){}, activeColor: ColorsManager.mainBlue)
        : (trailing != null ? Text(trailing, style: const TextStyle(color: Colors.grey)) : const Icon(Icons.arrow_forward_ios, size: 14)),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        CacheHelper.clearData();
        Navigator.pushNamedAndRemoveUntil(context, Routes.loginScreen, (route) => false);
      },
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 56.h),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
