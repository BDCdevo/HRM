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

  /// Build Quick Actions FAB
  Widget _buildSpeedDial(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickActionsSheet(context),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Show Quick Actions Bottom Sheet
  void _showQuickActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bolt,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Actions List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildActionTile(
                    context,
                    icon: Icons.event_available,
                    iconColor: AppColors.success,
                    title: 'Apply for Leave',
                    subtitle: 'Submit a leave request',
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
                  _buildActionTile(
                    context,
                    icon: Icons.description,
                    iconColor: AppColors.primary,
                    title: 'General Request',
                    subtitle: 'Submit any general request',
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
                  _buildActionTile(
                    context,
                    icon: Icons.card_membership,
                    iconColor: AppColors.accent,
                    title: 'Request Certificate',
                    subtitle: 'Request employment certificate',
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
                  _buildActionTile(
                    context,
                    icon: Icons.school,
                    iconColor: AppColors.warning,
                    title: 'Request Training',
                    subtitle: 'Submit a training request',
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
          ],
        ),
      ),
    );
  }

  /// Build Action Tile
  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
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
