import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../leave/logic/cubit/leave_cubit.dart';
import '../widgets/leaves_apply_widget.dart';
import '../widgets/leaves_history_widget.dart';
import '../widgets/leaves_balance_widget.dart';

/// Leaves Main Screen
///
/// Main screen with tabs for Apply Leave, My Leaves, and Balance
class LeavesMainScreen extends StatefulWidget {
  const LeavesMainScreen({super.key});

  @override
  State<LeavesMainScreen> createState() => _LeavesMainScreenState();
}

class _LeavesMainScreenState extends State<LeavesMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.surface;
    final textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final appBarColor = isDarkMode ? AppColors.darkAppBar : AppColors.primary;

    return BlocProvider(
      create: (context) => LeaveCubit(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: appBarColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                        ? [
                            AppColors.darkAppBar,
                            AppColors.darkCard,
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                          ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  'assets/svgs/leaves_icon.svg',
                                  width: 28,
                                  height: 28,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Leaves',
                                      style: AppTextStyles.headlineMedium.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage your leave requests',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: isDarkMode ? AppColors.white : AppColors.primary,
                  unselectedLabelColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 3,
                  labelStyle: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelLarge,
                  tabs: const [
                    Tab(text: 'Apply Leave'),
                    Tab(text: 'My Leaves'),
                    Tab(text: 'Balance'),
                  ],
                ),
                backgroundColor: isDarkMode ? AppColors.darkCard : AppColors.surface,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            // Apply Leave Tab
            LeavesApplyWidget(),

            // My Leaves Tab
            LeavesHistoryWidget(),

            // Balance Tab
            LeavesBalanceWidget(),
          ],
        ),
      ),
    ),
    );
  }
}

/// Sliver Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this._tabBar, {required this.backgroundColor});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor;
  }
}
