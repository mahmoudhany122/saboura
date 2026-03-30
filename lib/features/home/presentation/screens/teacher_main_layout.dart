import 'package:flutter/material.dart';
import '../../../../core/theming/colors.dart';
import '../../../courses/presentation/screens/teacher_dashboard_screen.dart';
import '../../../courses/presentation/screens/teacher_my_courses_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class TeacherMainLayout extends StatefulWidget {
  const TeacherMainLayout({super.key});

  @override
  State<TeacherMainLayout> createState() => _TeacherMainLayoutState();
}

class _TeacherMainLayoutState extends State<TeacherMainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TeacherDashboardScreen(),
    const TeacherMyCoursesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: ColorsManager.mainBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'كورساتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
