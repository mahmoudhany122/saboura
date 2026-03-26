import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'تعلم من أفضل المعلمين',
      description: 'نوفر لك نخبة من المعلمين المتميزين في كافة المجالات لضمان أفضل تجربة تعليمية.',
      image: 'assets/images/onboarding1.png', // Placeholder
    ),
    OnboardingContent(
      title: 'محتوى تعليمي متكامل',
      description: 'دروس مسجلة، بث مباشر، واختبارات دورية لتقييم مستواك الدراسي بشكل مستمر.',
      image: 'assets/images/onboarding2.png',
    ),
    OnboardingContent(
      title: 'ابدأ رحلتك الآن',
      description: 'انضم إلى آلاف الطلاب المتفوقين وابدأ رحلة النجاح مع منصة سبورة.',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FadeInDown(
                          child: Container(
                            height: 250.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorsManager.lighterGray,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.school, size: 100, color: ColorsManager.mainBlue),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        FadeInUp(
                          child: Text(
                            _contents[index].title,
                            style: TextStyles.font24BlackBold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            _contents[index].description,
                            style: TextStyles.font14GrayRegular,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage != _contents.length - 1)
                          TextButton(
                            onPressed: () {
                              _pageController.jumpToPage(_contents.length - 1);
                            },
                            child: Text('تخطي', style: TextStyles.font14GrayRegular),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _contents.length - 1) {
                              Navigator.pushReplacementNamed(context, Routes.loginScreen);
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsManager.mainBlue,
                            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _currentPage == _contents.length - 1 ? 'ابدأ الآن' : 'التالي',
                            style: TextStyles.font16WhiteSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: _currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index ? ColorsManager.mainBlue : ColorsManager.lightGray,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final String image;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });
}
