import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';
import '../../features/auth/logic/cubit/auth_state.dart';
import '../../features/home/ui/screens/home_main_screen.dart';
import '../../features/chat/ui/screens/chat_list_screen.dart';
import '../../features/leaves/ui/screens/leaves_main_screen.dart';
import '../../features/more/ui/screens/more_main_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../styles/app_colors.dart';

/// Main Navigation Screen
///
/// Modern bottom navigation bar with main app sections:
/// - Home (Dashboard & Quick Actions)
/// - Chat (Employee Messaging)
/// - Leaves (Apply, History, Balance)
/// - More (Reports, Profile, Settings)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  List<Widget> _buildScreens(AuthState authState) {
    // Get user data from auth state
    final user = authState is AuthAuthenticated ? authState.user : null;
    final userId = user?.id ?? 0;

    // Debug logging
    print('🔍 MainNavigationScreen - userId from auth: $userId');
    print('🔍 MainNavigationScreen - user email: ${user?.email}');

    // Company ID is always 6 (BDC) - hardcoded since UserModel doesn't contain company_id
    // TODO: Add company_id to UserModel in future versions
    const companyId = 6;

    return [
      const HomeMainScreen(),
      ChatListScreen(
        companyId: companyId,
        currentUserId: userId,
      ),
      const LeavesMainScreen(),
      const MoreMainScreen(),
    ];
  }

  final List<NavBarItem> _navItems = const [
    NavBarItem(
      svgIcon: 'assets/svgs/home_icon.svg',
      label: 'Home',
      color: AppColors.primary,
    ),
    NavBarItem(
      svgIcon: 'assets/whatsapp_icons/whatsapp.svg',
      label: 'Chat',
      color: Color(0xFF25D366), // WhatsApp green
    ),
    NavBarItem(
      svgIcon: 'assets/svgs/leaves_icon.svg',
      label: 'Leaves',
      color: AppColors.primary,
    ),
    NavBarItem(
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      label: 'More',
      color: AppColors.primary,
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
            children: _buildScreens(state),
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
