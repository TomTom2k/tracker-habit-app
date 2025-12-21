import 'package:flutter/material.dart';
import '../widgets/home_page.dart';
import '../../../habit/presentation/pages/habit_page.dart';
import '../../../todo/presentation/pages/todo_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../pomodoro/presentation/pages/pomodoro_page.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HabitPage(),
    const TodoPage(),
    const ProfilePage(),
    const PomodoroPage(),
  ];

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icons.check_circle_outline,
      activeIcon: Icons.check_circle,
      label: 'Habit',
    ),
    BottomNavItem(
      icon: Icons.task_outlined,
      activeIcon: Icons.task,
      label: 'Todo',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
    BottomNavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: 'Pomodoro',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
          });
          
          // Reload habits khi switch về habit tab
          if (index == 1 && _previousIndex != 1) {
            // HabitPage sẽ tự động reload trong didChangeDependencies
            // Nhưng để đảm bảo, ta có thể trigger reload bằng cách rebuild
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Force rebuild habit page để trigger reload
            });
          }
        },
        items: _navItems,
      ),
    );
  }
}

