import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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

  /// Build Speed Dial FAB with Semicircle/Arc Layout
  Widget _buildSpeedDial(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      activeForegroundColor: Colors.white,
      activeBackgroundColor: AppColors.primary,
      buttonSize: const Size(60, 60),
      visible: true,
      closeManually: false,
      curve: Curves.easeOutBack,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8.0,
      animationCurve: Curves.easeOutBack,
      isOpenOnStart: false,
      shape: const CircleBorder(),
      // Semicircle/Arc layout - upward only
      direction: SpeedDialDirection.up,
      animationDuration: const Duration(milliseconds: 350),
      childrenButtonSize: const Size(56, 56),
      spacing: 16,
      spaceBetweenChildren: 12,
      renderOverlay: true,
      // Custom dial root with rotation
      dialRoot: (ctx, open, toggleChildren) {
        return FloatingActionButton(
          onPressed: toggleChildren,
          backgroundColor: AppColors.primary,
          elevation: open ? 12 : 8,
          child: AnimatedRotation(
            turns: open ? 0.125 : 0.0, // 45 degrees rotation when open
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: Icon(
              open ? Icons.close : Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
      children: [
        // Bottom-Left in arc
        SpeedDialChild(
          child: const Icon(Icons.event_available, color: Colors.white, size: 24),
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          label: 'Leave',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          elevation: 6,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeavesMainScreen(),
              ),
            );
          },
        ),
        // Middle-Left in arc
        SpeedDialChild(
          child: const Icon(Icons.description, color: Colors.white, size: 24),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          label: 'Request',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          elevation: 6,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralRequestScreen(),
              ),
            );
          },
        ),
        // Middle-Right in arc
        SpeedDialChild(
          child: const Icon(Icons.card_membership, color: Colors.white, size: 24),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          label: 'Certificate',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          elevation: 6,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CertificateRequestScreen(),
              ),
            );
          },
        ),
        // Bottom-Right in arc
        SpeedDialChild(
          child: const Icon(Icons.school, color: Colors.white, size: 24),
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          label: 'Training',
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          elevation: 6,
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
          body: IndexedStack(
            index: _currentIndex,
            children: _buildScreens(state),
          ),
          floatingActionButton: _buildSpeedDial(context),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
