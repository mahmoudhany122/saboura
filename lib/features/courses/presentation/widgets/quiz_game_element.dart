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
    return LayoutBuilder(
      builder: (context, constraints) {
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
      },
    );
  }

  Widget _buildDefault() {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Text(
          questionText,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCarRacing() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 100.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: CustomPaint(painter: RoadPainter()),
        ),
        AnimatedAlign(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutBack,
          alignment: Alignment(progress * 2 - 1, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flexible Question Bubble above Car
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.w),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: Text(
                    questionText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Icon(Icons.directions_car, size: 60.sp, color: Colors.orangeAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonkey() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Scrollable Question Card
        Flexible(
          child: Container(
            padding: EdgeInsets.all(12.w),
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: SingleChildScrollView(
              child: Text(
                questionText,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (isAnswered)
          isCorrect
              ? BounceInDown(child: Text('🍌 يمي! أحسنت!', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.green)))
              : ShakeX(child: Text('😢 ااااه!', style: TextStyle(fontSize: 20.sp, color: Colors.redAccent))),
        
        Icon(
          !isAnswered 
            ? Icons.face_retouching_natural 
            : (isCorrect ? Icons.sentiment_very_satisfied : Icons.sentiment_very_dissatisfied),
          size: 100.w,
          color: isAnswered ? (isCorrect ? Colors.orange : Colors.brown) : Colors.brown,
        ),
      ],
    );
  }

  Widget _buildSpace() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      margin: EdgeInsets.only(bottom: progress * 200.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180.w),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(
                questionText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Icon(Icons.rocket_launch, size: 70.sp, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildDesert() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: 10.h,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 250.w),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                questionText,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        AnimatedAlign(
          duration: const Duration(milliseconds: 1000),
          alignment: Alignment(progress * 2 - 1, 0.6),
          child: Icon(Icons.directions_run, size: 70.sp, color: Colors.brown),
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
