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

  /// Show requests dialog
  void _showRequestsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              const Text(
                'New Request',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Leave Request
              _buildRequestOption(
                context: context,
                icon: Icons.event_available,
                title: 'Leave Request',
                subtitle: 'Apply for time off',
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeavesMainScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // General Request
              _buildRequestOption(
                context: context,
                icon: Icons.description,
                title: 'General Request',
                subtitle: 'Submit a general request',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GeneralRequestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Certificate Request
              _buildRequestOption(
                context: context,
                icon: Icons.card_membership,
                title: 'Certificate Request',
                subtitle: 'Request a certificate',
                color: AppColors.accent,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CertificateRequestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Training Request
              _buildRequestOption(
                context: context,
                icon: Icons.school,
                title: 'Training Request',
                subtitle: 'Request training',
                color: AppColors.warning,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainingRequestScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build request option button
  Widget _buildRequestOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

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
      label: 'More',
      color: AppColors.primary,
    ),
    NavBarItem(
      icon: Icons.add,
      label: 'New',
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
              if (index == 4) {
                // FAB button clicked - show requests dialog
                _showRequestsDialog(context);
              } else {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        );
      },
    );
  }
}
