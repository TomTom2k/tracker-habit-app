import 'package:flutter/material.dart';
import '../widgets/home_page.dart';
import '../../../habit/presentation/pages/habit_page.dart';
import '../../../routines/presentation/pages/routines_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../statistics/presentation/pages/statistics_page.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const HabitPage(),
    const RoutinesPage(),
    const ProfilePage(),
    const StatisticsPage(),
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
      icon: Icons.schedule_outlined,
      activeIcon: Icons.schedule,
      label: 'Routines',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
    BottomNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Statistics',
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
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}

