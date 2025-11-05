import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

/// Custom Bottom Navigation Bar
///
/// Modern, animated bottom navigation bar with icons and labels
/// Refactored for better performance and no overflow issues
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavBarButton(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
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
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  const NavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

/// Navigation Bar Button
/// Refactored to prevent overflow and improve responsiveness
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
    final color = item.color ?? AppColors.primary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withOpacity(0.1),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSelected ? 6 : 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    size: isSelected ? 24 : 22,
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                // Label with flexible sizing
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: isSelected
                        ? AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                            fontSize: 11,
                            height: 1.2,
                          )
                        : AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            height: 1.2,
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
