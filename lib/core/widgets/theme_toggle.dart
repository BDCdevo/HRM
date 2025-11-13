import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/cubit/theme_cubit.dart';
import '../theme/cubit/theme_state.dart';
import '../styles/app_colors.dart';

/// Theme Toggle Widget
///
/// Switch between light and dark mode with animation
class ThemeToggle extends StatelessWidget {
  final bool showLabel;

  const ThemeToggle({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isDark = state.themeMode == ThemeMode.dark;

        return InkWell(
          onTap: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Label and Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.amber.withValues(alpha: 0.1)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.amber : Colors.blue,
                        size: 20,
                      ),
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: 12),
                      Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),

                // Animated Switch
                _AnimatedToggle(isDark: isDark),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animated Toggle Switch
class _AnimatedToggle extends StatelessWidget {
  final bool isDark;

  const _AnimatedToggle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark ? AppColors.primary : Colors.grey.shade300,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
        curve: Curves.easeInOut,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny,
            size: 14,
            color: isDark ? Colors.amber : Colors.orange,
          ),
        ),
      ),
    );
  }
}

/// Theme Mode Selector (3 options: Light, Dark, System)
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _ThemeModeOption(
                title: 'Light',
                icon: Icons.light_mode,
                mode: ThemeMode.light,
                isSelected: state.themeMode == ThemeMode.light,
                onTap: () {
                  context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                },
              ),
              const SizedBox(height: 8),
              _ThemeModeOption(
                title: 'Dark',
                icon: Icons.dark_mode,
                mode: ThemeMode.dark,
                isSelected: state.themeMode == ThemeMode.dark,
                onTap: () {
                  context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                },
              ),
              const SizedBox(height: 8),
              _ThemeModeOption(
                title: 'System',
                icon: Icons.brightness_auto,
                mode: ThemeMode.system,
                isSelected: state.themeMode == ThemeMode.system,
                onTap: () {
                  context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Theme Mode Option
class _ThemeModeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.title,
    required this.icon,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).iconTheme.color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
