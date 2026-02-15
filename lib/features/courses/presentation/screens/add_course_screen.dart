import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/helpers/image_upload_helper.dart';
import '../../domain/entities/quiz_entity.dart';
import '../widgets/course_image_picker.dart';
import '../widgets/quiz_theme_selector.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  QuizTheme selectedQuizTheme = QuizTheme.classic;
  File? _image;
  bool _isUploadingImage = false;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageUrlController.clear();
      });
      
      // Auto-upload to ImgBB
      setState(() => _isUploadingImage = true);
      final uploadedUrl = await ImageUploadHelper.uploadImage(_image!);
      setState(() => _isUploadingImage = false);

      if (uploadedUrl != null) {
        setState(() {
          _imageUrlController.text = uploadedUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم رفع الصورة بنجاح! ✅'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل رفع الصورة، سيتم المحاولة لاحقاً'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة كورس جديد')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CourseImagePicker(
                    imageFile: _image,
                    imageUrl: _imageUrlController.text,
                    onTap: _isUploadingImage ? () {} : _pickImage,
                  ),
                  if (_isUploadingImage)
                    const CircularProgressIndicator(color: ColorsManager.mainBlue),
                ],
              ),
              const SizedBox(height: 15),
              AppTextFormField(
                controller: _imageUrlController,
                hintText: 'رابط الصورة (يُملأ تلقائياً عند الرفع)',
                validator: (v) => null,
                suffixIcon: const Icon(Icons.link, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Text('بيانات الكورس', style: TextStyles.font15DarkBlueMedium),
              const SizedBox(height: 16),
              AppTextFormField(
                controller: _titleController,
                hintText: 'اسم الكورس',
                validator: (v) => v!.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              AppTextFormField(
                controller: _descriptionController,
                hintText: 'نبذة عن الكورس',
                validator: (v) => v!.isEmpty ? 'يرجى إدخال نبذة' : null,
              ),
              const SizedBox(height: 30),
              Text('طابع الاختبار للأطفال', style: TextStyles.font15DarkBlueMedium),
              const SizedBox(height: 16),
              QuizThemeSelector(
                selectedQuizTheme: selectedQuizTheme,
                onThemeSelected: (theme) {
                  setState(() => selectedQuizTheme = theme);
                },
              ),
              const SizedBox(height: 40),
              FadeInUp(
                child: ElevatedButton(
                  onPressed: _isUploadingImage ? null : () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(
                        context,
                        Routes.addLessonsScreen,
                        arguments: {
                          'title': _titleController.text,
                          'description': _descriptionController.text,
                          'imageUrl': _imageUrlController.text,
                          'imageFile': _image,
                          'quizTheme': selectedQuizTheme,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsManager.mainBlue,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('إضافة محتوى الكورس', style: TextStyles.font16WhiteSemiBold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
