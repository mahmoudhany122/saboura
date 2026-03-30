import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theming/colors.dart';

class CourseImagePicker extends StatelessWidget {
  final File? imageFile;
  final String imageUrl;
  final VoidCallback onTap;

  const CourseImagePicker({
    super.key,
    this.imageFile,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorsManager.moreLightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsManager.lighterGray),
              image: imageFile != null
                  ? DecorationImage(image: FileImage(imageFile!), fit: BoxFit.cover)
                  : (imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null),
            ),
            child: (imageFile == null && imageUrl.isEmpty)
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: ColorsManager.mainBlue),
                      SizedBox(height: 8),
                      Text('اضغط لإضافة صورة أو ضع رابطاً بالأسفل',
                          style: TextStyle(color: ColorsManager.gray, fontSize: 12)),
                    ],
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
