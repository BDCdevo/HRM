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

  /// Build Speed Dial FAB with Circular Layout
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
      curve: Curves.easeInOut,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      elevation: 8.0,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      shape: const CircleBorder(),
      // Circular/Radial layout
      useRotationTransition: true,
      animationDuration: const Duration(milliseconds: 300),
      childrenButtonSize: const Size(56, 56),
      spacing: 12,
      spaceBetweenChildren: 8,
      renderOverlay: true,
      // Custom dial root for circular arrangement
      dialRoot: (ctx, open, toggleChildren) {
        return FloatingActionButton(
          onPressed: toggleChildren,
          backgroundColor: AppColors.primary,
          elevation: 8,
          child: AnimatedRotation(
            turns: open ? 0.125 : 0.0, // 45 degrees rotation when open
            duration: const Duration(milliseconds: 300),
            child: Icon(
              open ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        );
      },
      children: [
        // Top-Left (315 degrees)
        SpeedDialChild(
          child: const Icon(Icons.event_available, color: Colors.white),
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          label: 'Leave',
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeavesMainScreen(),
              ),
            );
          },
        ),
        // Top-Right (45 degrees)
        SpeedDialChild(
          child: const Icon(Icons.description, color: Colors.white),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          label: 'Request',
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GeneralRequestScreen(),
              ),
            );
          },
        ),
        // Left (270 degrees)
        SpeedDialChild(
          child: const Icon(Icons.card_membership, color: Colors.white),
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          label: 'Certificate',
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CertificateRequestScreen(),
              ),
            );
          },
        ),
        // Right (90 degrees)
        SpeedDialChild(
          child: const Icon(Icons.school, color: Colors.white),
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          label: 'Training',
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
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
