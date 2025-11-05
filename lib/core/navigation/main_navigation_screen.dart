import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';
import '../../features/auth/logic/cubit/auth_state.dart';
import '../../features/home/ui/screens/home_main_screen.dart';
import '../../features/attendance/ui/screens/attendance_main_screen.dart';
import '../../features/leaves/ui/screens/leaves_main_screen.dart';
import '../../features/more/ui/screens/more_main_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../styles/app_colors.dart';

/// Main Navigation Screen
///
/// Modern bottom navigation bar with main app sections:
/// - Home (Dashboard & Quick Actions)
/// - Attendance (Check-in, History, Calendar)
/// - Leaves (Apply, History, Balance)
/// - More (Reports, Profile, Settings)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeMainScreen(),
    AttendanceMainScreen(),
    LeavesMainScreen(),
    MoreMainScreen(),
  ];

  final List<NavBarItem> _navItems = const [
    NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      color: AppColors.primary,
    ),
    NavBarItem(
      icon: Icons.access_time_outlined,
      activeIcon: Icons.access_time,
      label: 'Attendance',
      color: AppColors.success,
    ),
    NavBarItem(
      icon: Icons.event_busy_outlined,
      activeIcon: Icons.event_busy,
      label: 'Leaves',
      color: AppColors.warning,
    ),
    NavBarItem(
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      label: 'More',
      color: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            items: _navItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
