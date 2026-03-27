import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizGameElement extends StatelessWidget {
  final QuizTheme theme;
  final double progress;
  final bool isAnswered;
  final bool isCorrect;

  const QuizGameElement({
    super.key,
    required this.theme,
    required this.progress,
    required this.isAnswered,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case QuizTheme.carRacing:
        return _buildCarRacing();
      case QuizTheme.monkey:
        return _buildMonkey();
      case QuizTheme.space:
        return _buildSpace();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCarRacing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 60.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: CustomPaint(painter: RoadPainter()),
        ),
        AnimatedAlign(
          duration: const Duration(milliseconds: 1000),
          alignment: Alignment(progress * 2 - 1, 0),
          child: const Icon(Icons.directions_car, size: 50, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildMonkey() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isAnswered)
            isCorrect
                ? ZoomIn(child: const Text('🐒 ييييي هااااا!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)))
                : ShakeX(child: const Text('🐒 اووووه لاااا!', style: TextStyle(fontSize: 30))),
          SizedBox(height: 10.h),
          Icon(
            isAnswered
                ? (isCorrect ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied)
                : Icons.emoji_emotions,
            size: 100.w,
            color: Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildSpace() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        margin: EdgeInsets.only(bottom: progress * 100.h),
        child: const RocketAnimation(),
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 10, dashSpace = 10, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RocketAnimation extends StatelessWidget {
  const RocketAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.rocket_launch, size: 60, color: Colors.redAccent),
        Container(
          width: 10,
          height: 20,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.orange, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
      ],
    );
  }
}
