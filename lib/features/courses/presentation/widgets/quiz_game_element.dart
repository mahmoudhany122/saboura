import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/quiz_entity.dart';

class QuizGameElement extends StatelessWidget {
  final QuizTheme theme;
  final double progress;
  final bool isAnswered;
  final bool isCorrect;
  final String questionText;

  const QuizGameElement({
    super.key,
    required this.theme,
    required this.progress,
    required this.isAnswered,
    required this.isCorrect,
    required this.questionText,
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
      case QuizTheme.desert:
        return _buildDesert();
      default:
        return _buildDefault();
    }
  }

  Widget _buildDefault() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        questionText,
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCarRacing() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 120.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24, width: 4),
                ),
                child: CustomPaint(painter: RoadPainter()),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutBack,
                alignment: Alignment(progress * 2 - 1, 0),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Question bubble on top of the car
                    Transform.translate(
                      offset: Offset(0, -60.h),
                      child: FadeInDown(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: Text(questionText, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    Icon(Icons.directions_car, size: 70.sp, color: Colors.orangeAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonkey() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question bubble
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Text(questionText, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
          
          if (isAnswered)
            isCorrect
                ? BounceInDown(child: const Text('🍌 يمي! أحسنت!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)))
                : ShakeX(child: const Text('😢 ااااه!', style: TextStyle(fontSize: 24, color: Colors.redAccent))),
          
          SizedBox(height: 10.h),
          
          // Monkey State Icons (Using Lottie or Icons for emotions)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Icon(
              !isAnswered 
                ? Icons.face_retouching_natural 
                : (isCorrect ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied),
              key: ValueKey(isAnswered ? (isCorrect ? 'happy' : 'sad') : 'neutral'),
              size: 140.w,
              color: isAnswered ? (isCorrect ? Colors.orange : Colors.brown) : Colors.brown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpace() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          margin: EdgeInsets.only(bottom: progress * 250.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question on the Rocket
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Text(questionText, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.rocket_launch, size: 80, color: Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesert() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Question Oasis
        Positioned(
          top: 20.h,
          child: Container(
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(questionText, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
        ),
        AnimatedAlign(
          duration: const Duration(milliseconds: 1000),
          alignment: Alignment(progress * 2 - 1, 0.6),
          child: Icon(Icons.directions_run, size: 80.sp, color: Colors.brown),
        ),
      ],
    );
  }
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    double dashWidth = 15, dashSpace = 15, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
