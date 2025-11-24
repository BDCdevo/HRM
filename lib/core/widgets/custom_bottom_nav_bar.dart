import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

/// Custom Bottom Navigation Bar - Modern Design (inspired by Odoo)
///
/// Features:
/// - Gradient background
/// - Glassmorphism effect with blur
/// - Smooth animations
/// - Badge support
/// - Dark mode support
/// - Clean and minimal design
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkAppBar : AppColors.white;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive spacing
    final horizontalPadding = screenWidth > 600 ? 24.0 : 8.0;
    final fabSpacing = screenWidth > 600 ? 100.0 : 70.0;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: surfaceColor,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              surfaceColor.withOpacity(0.95),
              surfaceColor,
            ],
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: SafeArea(
              child: Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // First 2 items
                    ...items.take(2).toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = currentIndex == index;

                      return Expanded(
                        child: _NavBarButton(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => onTap(index),
                        ),
                      );
                    }),
                    // Spacer for FAB
                    SizedBox(width: fabSpacing),
                    // Last 2 items
                    ...items.skip(2).toList().asMap().entries.map((entry) {
                      final index = entry.key + 2;
                      final item = entry.value;
                      final isSelected = currentIndex == index;

                      return Expanded(
                        child: _NavBarButton(
                          item: item,
                          isSelected: isSelected,
                          onTap: () => onTap(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation Bar Item Model
class NavBarItem {
  final IconData? icon;
  final IconData? activeIcon;
  final String? svgIcon;
  final String? activeSvgIcon;
  final String label;
  final Color? color;
  final int? badgeCount;

  const NavBarItem({
    this.icon,
    this.activeIcon,
    this.svgIcon,
    this.activeSvgIcon,
    required this.label,
    this.color,
    this.badgeCount,
  }) : assert(icon != null || svgIcon != null, 'Either icon or svgIcon must be provided');
}

/// Navigation Bar Button
class _NavBarButton extends StatelessWidget {
  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = item.color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 6.0 : 4.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(isDark ? 0.3 : 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: item.svgIcon != null
                      ? SvgPicture.asset(
                          isSelected
                              ? (item.activeSvgIcon ?? item.svgIcon!)
                              : item.svgIcon!,
                          width: isSelected ? 26 : 22,
                          height: isSelected ? 26 : 22,
                          // Don't apply color filter to keep original WhatsApp colors
                        )
                      : Icon(
                          isSelected ? (item.activeIcon ?? item.icon!) : item.icon!,
                          size: isSelected ? 26 : 22,
                          color: isSelected
                              ? color
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey.shade600),
                        ),
                ),
                // Badge
                if (item.badgeCount != null && item.badgeCount! > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkAppBar
                              : AppColors.white,
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        item.badgeCount! > 99
                            ? '99+'
                            : item.badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            // Hide label - icons only for cleaner look
          ],
        ),
      ),
    );
  }
}
