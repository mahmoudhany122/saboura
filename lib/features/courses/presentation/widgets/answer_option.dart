import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/entities/quiz_entity.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String optionText;
  final bool isAnswered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback onTap;
  final QuizTheme theme;

  const AnswerOption({
    super.key,
    required this.index,
    required this.optionText,
    required this.isAnswered,
    required this.isCorrect,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // Standard UI for classic theme
    if (theme == QuizTheme.classic) {
      return _buildClassicOption();
    }

    // Gamified UI for other themes
    return _buildGamifiedOption();
  }

  Widget _buildClassicOption() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _getBorderColor(), width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: _getBorderColor(),
              child: Text('${String.fromCharCode(65 + index)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 15.w),
            Expanded(child: Text(optionText, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  Widget _buildGamifiedOption() {
    return FadeInUp(
      delay: Duration(milliseconds: index * 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The Game Shape (Bubble, Banana, Planet)
              _buildThemeShape(),
              // The Text
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  optionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.3), offset: const Offset(1, 1))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeShape() {
    Color baseColor = _getGamifiedBaseColor();
    
    switch (theme) {
      case QuizTheme.space:
        return Icon(Icons.circle, size: 80.w, color: baseColor.withOpacity(0.8)); // Planet shape
      case QuizTheme.monkey:
        return Icon(Icons.eco, size: 70.w, color: baseColor); // Leaf/Banana shape
      case QuizTheme.carRacing:
        return Container(
          width: 120.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 3),
          ),
        ); // Road Sign shape
      default:
        return const SizedBox.shrink();
    }
  }

  Color _getGamifiedBaseColor() {
    if (isAnswered) {
      if (isCorrect) return Colors.greenAccent;
      if (isSelected) return Colors.redAccent;
    }
    switch (theme) {
      case QuizTheme.space: return Colors.blueAccent;
      case QuizTheme.monkey: return Colors.yellow.shade700;
      case QuizTheme.carRacing: return Colors.orangeAccent;
      default: return Colors.white;
    }
  }

  Color _getTextColor() {
    if (theme == QuizTheme.space) return Colors.white;
    return Colors.black87;
  }

  Color _getBackgroundColor() {
    if (!isAnswered) return Colors.white;
    if (isCorrect) return Colors.green.shade50;
    if (isSelected) return Colors.red.shade50;
    return Colors.white;
  }

  Color _getBorderColor() {
    if (!isAnswered) return Colors.grey.shade200;
    if (isCorrect) return Colors.green;
    if (isSelected) return Colors.red;
    return Colors.grey.shade200;
  }
}
