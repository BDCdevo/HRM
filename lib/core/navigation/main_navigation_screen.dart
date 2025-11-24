import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/logic/cubit/auth_cubit.dart';
import '../../features/auth/logic/cubit/auth_state.dart';
import '../../features/home/ui/screens/home_main_screen.dart';
import '../../features/chat/ui/screens/chat_list_screen.dart';
import '../../features/requests/ui/screens/requests_main_screen.dart';
import '../../features/more/ui/screens/more_main_screen.dart';
import '../../features/leaves/ui/screens/leaves_main_screen.dart';
import '../../features/general_request/ui/screens/general_request_screen.dart';
import '../../features/certificate/ui/screens/certificate_request_screen.dart';
import '../../features/training/ui/screens/training_request_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/radial_menu.dart';
import '../styles/app_colors.dart';
import '../routing/app_router.dart';

/// Main Navigation Screen
///
/// Modern bottom navigation bar with main app sections:
/// - Home (Dashboard & Quick Actions)
/// - Chat (Employee Messaging)
/// - Requests (All request types: Leaves, Attendance, etc.)
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
    if (kDebugMode) {
      debugPrint('🔍 MainNavigationScreen - userId from auth: $userId');
      debugPrint('🔍 MainNavigationScreen - user email: ${user?.email}');
    }

    // Company ID is always 6 (BDC) - hardcoded since UserModel doesn't contain company_id
    // TODO: Add company_id to UserModel in future versions
    const companyId = 6;

    return [
      const HomeMainScreen(),
      ChatListScreen(
        companyId: companyId,
        currentUserId: userId,
      ),
      const RequestsMainScreen(),
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
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
      color: AppColors.primary,
    ),
    NavBarItem(
      svgIcon: 'assets/svgs/leaves_icon.svg',
      label: 'Requests',
      color: AppColors.primary,
    ),
    NavBarItem(
      svgIcon: 'assets/svgs/profile_icon.svg',
      label: 'Profile',
      color: AppColors.primary,
    ),
  ];

  /// Build Radial Menu FAB with Semicircle/Arc Layout
  Widget _buildRadialMenu(BuildContext context) {
    return RadialMenu(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AppColors.primary,
      radius: 100,
      items: [
        RadialMenuItem(
          icon: Icons.event_available,
          label: 'Leave',
          backgroundColor: AppColors.success,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeavesMainScreen(),
              ),
            );
          },
        ),
        RadialMenuItem(
          icon: Icons.description,
          label: 'Request',
          backgroundColor: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralRequestScreen(),
              ),
            );
          },
        ),
        RadialMenuItem(
          icon: Icons.card_membership,
          label: 'Certificate',
          backgroundColor: AppColors.accent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CertificateRequestScreen(),
              ),
            );
          },
        ),
        RadialMenuItem(
          icon: Icons.school,
          label: 'Training',
          backgroundColor: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrainingRequestScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

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
          body: Stack(
            children: [
              // Main content
              IndexedStack(
                index: _currentIndex,
                children: _buildScreens(state),
              ),
              // Radial menu overlay
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildRadialMenu(context),
              ),
            ],
          ),
          floatingActionButton: null, // Remove FAB, we'll handle it in RadialMenu
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
