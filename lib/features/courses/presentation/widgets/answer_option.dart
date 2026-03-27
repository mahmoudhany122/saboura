import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/colors.dart';

class AnswerOption extends StatelessWidget {
  final int index;
  final String optionText;
  final bool isAnswered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.index,
    required this.optionText,
    required this.isAnswered,
    required this.isCorrect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = Colors.white;
    if (isAnswered) {
      if (isCorrect) {
        cardColor = Colors.green.shade50;
      } else if (isSelected) {
        cardColor = Colors.red.shade50;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAnswered
                  ? (isCorrect
                      ? Colors.green
                      : (isSelected ? Colors.red : ColorsManager.lighterGray))
                  : ColorsManager.lighterGray,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 35.w,
                height: 35.w,
                decoration: BoxDecoration(
                  color: isAnswered
                      ? (isCorrect
                          ? Colors.green
                          : (isSelected ? Colors.red : ColorsManager.moreLightGray))
                      : ColorsManager.moreLightGray,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isAnswered && (isCorrect || isSelected)
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isAnswered && isCorrect)
                const Icon(Icons.check_circle, color: Colors.green),
              if (isAnswered && isSelected && !isCorrect)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
