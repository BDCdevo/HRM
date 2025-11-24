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

    // Responsive sizing
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;
    final navHeight = isSmallScreen ? 60.0 : 65.0;
    final horizontalPadding = isSmallScreen ? 4.0 : 8.0;

    final fabSize = isSmallScreen ? 60.0 : (isMediumScreen ? 62.0 : 64.0);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Navigation Bar with notch
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipPath(
            clipper: _NavBarNotchClipper(notchRadius: fabSize / 2 + 8),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: surfaceColor.withOpacity(0.95),
                child: SafeArea(
                  child: Container(
                    height: navHeight,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4.0),
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
                                isSmallScreen: isSmallScreen,
                                isMediumScreen: isMediumScreen,
                              ),
                            );
                          }),
                          // Spacer for FAB
                          const Expanded(child: SizedBox()),
                          // Last 2 items
                          ...items.skip(2).take(2).toList().asMap().entries.map((entry) {
                            final index = entry.key + 2;
                            final item = entry.value;
                            final isSelected = currentIndex == index;

                            return Expanded(
                              child: _NavBarButton(
                                item: item,
                                isSelected: isSelected,
                                onTap: () => onTap(index),
                                isSmallScreen: isSmallScreen,
                                isMediumScreen: isMediumScreen,
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
          ),

        // Floating FAB Button (positioned above nav bar)
        Positioned(
          bottom: navHeight * 0.85, // Position it to cut through the nav bar
          child: _NavBarButton(
            item: items[4], // The 5th item (FAB)
            isSelected: false,
            onTap: () => onTap(4),
            isFab: true,
            isSmallScreen: isSmallScreen,
            isMediumScreen: isMediumScreen,
          ),
        ),
      ],
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
  final bool isFab;
  final bool isSmallScreen;
  final bool isMediumScreen;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isFab = false,
    this.isSmallScreen = false,
    this.isMediumScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = item.color ?? AppColors.primary;

    // Responsive sizing
    final fabSize = isSmallScreen ? 60.0 : (isMediumScreen ? 62.0 : 64.0);
    final fabIconSize = isSmallScreen ? 28.0 : (isMediumScreen ? 30.0 : 32.0);
    final fabBorderWidth = isSmallScreen ? 2.0 : 2.5;
    final labelFontSize = isSmallScreen ? 9.5 : (isMediumScreen ? 10.5 : 11.0);

    // FAB Style
    if (isFab) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: fabSize,
          height: fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: item.svgIcon != null
              ? Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 18.0),
                  child: SvgPicture.asset(
                    item.svgIcon!,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : Icon(
                  item.icon!,
                  size: fabIconSize,
                  color: Colors.white,
                ),
        ),
      );
    }

    // Regular Nav Button
    final iconSize = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final iconSizeSelected = isSmallScreen ? 24.0 : (isMediumScreen ? 25.0 : 26.0);
    final iconPadding = isSmallScreen ? 3.0 : 4.0;
    final iconPaddingSelected = isSmallScreen ? 5.0 : 6.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 2.0 : 4.0,
          horizontal: isSmallScreen ? 1.0 : 2.0,
        ),
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
                  padding: EdgeInsets.all(isSelected ? iconPaddingSelected : iconPadding),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(isDark ? 0.3 : 0.22)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: item.svgIcon != null
                      ? SvgPicture.asset(
                          isSelected
                              ? (item.activeSvgIcon ?? item.svgIcon!)
                              : item.svgIcon!,
                          width: isSelected ? iconSizeSelected : iconSize,
                          height: isSelected ? iconSizeSelected : iconSize,
                        )
                      : Icon(
                          isSelected ? (item.activeIcon ?? item.icon!) : item.icon!,
                          size: isSelected ? iconSizeSelected : iconSize,
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
            const SizedBox(height: 2),
            // Label
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? color
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : Colors.grey.shade600),
                  fontSize: labelFontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Clipper for Navigation Bar Notch
class _NavBarNotchClipper extends CustomClipper<Path> {
  final double notchRadius;

  _NavBarNotchClipper({required this.notchRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = size.width / 2;

    // Start from top-left
    path.moveTo(0, 0);

    // Top edge until notch start
    path.lineTo(center - notchRadius - 12, 0);

    // Create smooth curved notch (semicircle)
    path.quadraticBezierTo(
      center - notchRadius - 4, 0,
      center - notchRadius, 4,
    );

    path.arcToPoint(
      Offset(center + notchRadius, 4),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      center + notchRadius + 4, 0,
      center + notchRadius + 12, 0,
    );

    // Continue to top-right
    path.lineTo(size.width, 0);

    // Right edge
    path.lineTo(size.width, size.height);

    // Bottom edge
    path.lineTo(0, size.height);

    // Close path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

