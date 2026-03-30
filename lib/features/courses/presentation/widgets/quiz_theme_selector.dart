import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theming/colors.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizThemeSelector extends StatelessWidget {
  final QuizTheme selectedQuizTheme;
  final Function(QuizTheme) onThemeSelected;

  const QuizThemeSelector({
    super.key,
    required this.selectedQuizTheme,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildThemeCard(QuizTheme.classic, 'كلاسيكي', Icons.quiz),
          _buildThemeCard(QuizTheme.carRacing, 'سباق', Icons.directions_car),
          _buildThemeCard(QuizTheme.space, 'فضاء', Icons.rocket_launch),
          _buildThemeCard(QuizTheme.monkey, 'قرد', Icons.emoji_emotions),
        ],
      ),
    );
  }

  Widget _buildThemeCard(QuizTheme theme, String name, IconData icon) {
    bool isSelected = selectedQuizTheme == theme;
    return GestureDetector(
      onTap: () => onThemeSelected(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(left: 10.w),
        width: 80.w,
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.mainBlue : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? ColorsManager.mainBlue : ColorsManager.lighterGray),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : ColorsManager.mainBlue),
            Text(name,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
