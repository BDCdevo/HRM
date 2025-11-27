import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Theme-Aware Color Extension - Noon Style (Blue & Black)
///
/// Unified color system that automatically switches between Light & Dark mode
/// Inspired by Noon app 2024 design - Blue, Black, White
/// Usage: context.colors.background, context.colors.cardColor, etc.
extension AppColorsExtension on BuildContext {
  /// Get theme-aware colors based on current brightness
  AppThemeColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark ? AppThemeColors.dark() : AppThemeColors.light();
  }

  /// Quick check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Unified Theme Colors
///
/// Contains all colors used in the app with automatic Light/Dark support
class AppThemeColors {
  // ============================================
  // Background Colors
  // ============================================
  final Color background;
  final Color backgroundLight;
  final Color backgroundAlt;
  final Color surface;
  final Color surfaceVariant;

  // ============================================
  // Card Colors
  // ============================================
  final Color cardColor;
  final Color cardElevated;

  // ============================================
  // Text Colors
  // ============================================
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color textOnDark;

  // ============================================
  // Icon Colors
  // ============================================
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconTertiary;
  final Color iconOnDark;

  // ============================================
  // Border & Divider Colors
  // ============================================
  final Color border;
  final Color borderLight;
  final Color borderMedium;
  final Color divider;
  final Color dividerLight;

  // ============================================
  // Input/Field Colors
  // ============================================
  final Color fieldBackground;
  final Color fieldBorder;
  final Color fieldBorderFocused;

  // ============================================
  // Brand Colors (same for both themes)
  // ============================================
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color accent;
  final Color accentLight;
  final Color accentDark;

  // ============================================
  // Semantic Colors (same for both themes)
  // ============================================
  final Color success;
  final Color successLight;
  final Color successDark;
  final Color error;
  final Color errorLight;
  final Color errorDark;
  final Color warning;
  final Color warningLight;
  final Color warningDark;
  final Color info;
  final Color infoLight;

  // ============================================
  // Navigation Colors
  // ============================================
  final Color appBarBackground;
  final Color navBarBackground;
  final Color navBarSelected;
  final Color navBarUnselected;

  // ============================================
  // Shadow & Overlay Colors
  // ============================================
  final Color shadow;
  final Color shadowLight;
  final Color shadowMedium;
  final Color overlay;
  final Color overlayLight;

  // ============================================
  // Skeleton/Shimmer Colors
  // ============================================
  final Color skeletonBase;
  final Color skeletonHighlight;

  // ============================================
  // Base Colors
  // ============================================
  final Color white;
  final Color black;

  const AppThemeColors({
    // Backgrounds
    required this.background,
    required this.backgroundLight,
    required this.backgroundAlt,
    required this.surface,
    required this.surfaceVariant,
    // Cards
    required this.cardColor,
    required this.cardElevated,
    // Text
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.textOnDark,
    // Icons
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconTertiary,
    required this.iconOnDark,
    // Borders & Dividers
    required this.border,
    required this.borderLight,
    required this.borderMedium,
    required this.divider,
    required this.dividerLight,
    // Fields
    required this.fieldBackground,
    required this.fieldBorder,
    required this.fieldBorderFocused,
    // Brand
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
    // Semantic
    required this.success,
    required this.successLight,
    required this.successDark,
    required this.error,
    required this.errorLight,
    required this.errorDark,
    required this.warning,
    required this.warningLight,
    required this.warningDark,
    required this.info,
    required this.infoLight,
    // Navigation
    required this.appBarBackground,
    required this.navBarBackground,
    required this.navBarSelected,
    required this.navBarUnselected,
    // Shadows & Overlays
    required this.shadow,
    required this.shadowLight,
    required this.shadowMedium,
    required this.overlay,
    required this.overlayLight,
    // Skeleton
    required this.skeletonBase,
    required this.skeletonHighlight,
    // Base
    required this.white,
    required this.black,
  });

  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  factory AppThemeColors.light() {
    return const AppThemeColors(
      // Backgrounds
      background: AppColors.background,
      backgroundLight: AppColors.backgroundLight,
      backgroundAlt: AppColors.backgroundAlt,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      // Cards
      cardColor: AppColors.white,
      cardElevated: AppColors.white,
      // Text
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      textTertiary: AppColors.textTertiary,
      textDisabled: AppColors.textDisabled,
      textOnPrimary: AppColors.white, // White text on blue button
      textOnDark: AppColors.white,
      // Icons
      iconPrimary: AppColors.iconPrimary,
      iconSecondary: AppColors.iconSecondary,
      iconTertiary: AppColors.iconTertiary,
      iconOnDark: AppColors.white,
      // Borders & Dividers
      border: AppColors.border,
      borderLight: AppColors.borderLight,
      borderMedium: AppColors.borderMedium,
      divider: AppColors.divider,
      dividerLight: AppColors.dividerLight,
      // Fields - Noon style (gray background, blue focus)
      fieldBackground: AppColors.fieldBackground,
      fieldBorder: AppColors.border,
      fieldBorderFocused: AppColors.primary,
      // Brand
      primary: AppColors.primary,
      primaryLight: AppColors.primaryLight,
      primaryDark: AppColors.primaryDark,
      accent: AppColors.accent,
      accentLight: AppColors.accentLight,
      accentDark: AppColors.accentDark,
      // Semantic
      success: AppColors.success,
      successLight: AppColors.successLight,
      successDark: AppColors.successDark,
      error: AppColors.error,
      errorLight: AppColors.errorLight,
      errorDark: AppColors.errorDark,
      warning: AppColors.warning,
      warningLight: AppColors.warningLight,
      warningDark: AppColors.warningDark,
      info: AppColors.info,
      infoLight: AppColors.infoLight,
      // Navigation - Noon style (white bg, blue selected)
      appBarBackground: AppColors.white,
      navBarBackground: AppColors.white,
      navBarSelected: AppColors.primary,
      navBarUnselected: AppColors.textTertiary,
      // Shadows & Overlays
      shadow: AppColors.shadow,
      shadowLight: AppColors.shadowLight,
      shadowMedium: AppColors.shadowMedium,
      overlay: AppColors.overlay,
      overlayLight: AppColors.overlayLight,
      // Skeleton
      skeletonBase: AppColors.surfaceVariant,
      skeletonHighlight: AppColors.white,
      // Base
      white: AppColors.white,
      black: AppColors.black,
    );
  }

  // ============================================
  // DARK MODE COLORS
  // ============================================
  factory AppThemeColors.dark() {
    return const AppThemeColors(
      // Backgrounds
      background: AppColors.darkBackground,
      backgroundLight: AppColors.darkCard,
      backgroundAlt: AppColors.darkAppBar,
      surface: AppColors.darkCard,
      surfaceVariant: AppColors.darkInput,
      // Cards
      cardColor: AppColors.darkCard,
      cardElevated: AppColors.darkCardElevated,
      // Text
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textTertiary: AppColors.darkTextTertiary,
      textDisabled: AppColors.darkTextHint,
      textOnPrimary: AppColors.white, // White text on blue button
      textOnDark: AppColors.white,
      // Icons
      iconPrimary: AppColors.darkIcon,
      iconSecondary: AppColors.darkTextSecondary,
      iconTertiary: AppColors.darkTextTertiary,
      iconOnDark: AppColors.darkIcon,
      // Borders & Dividers
      border: AppColors.darkBorder,
      borderLight: AppColors.darkBorder,
      borderMedium: AppColors.darkBorder,
      divider: AppColors.darkDivider,
      dividerLight: AppColors.darkDivider,
      // Fields - Noon dark style (blue focus)
      fieldBackground: AppColors.darkInput,
      fieldBorder: AppColors.darkBorder,
      fieldBorderFocused: AppColors.darkPrimary,
      // Brand
      primary: AppColors.darkPrimary,
      primaryLight: AppColors.primary,
      primaryDark: AppColors.primaryDark,
      accent: AppColors.darkAccent,
      accentLight: AppColors.accentLight,
      accentDark: AppColors.accentDark,
      // Semantic
      success: AppColors.darkSuccess,
      successLight: AppColors.successLight,
      successDark: AppColors.successDark,
      error: AppColors.error,
      errorLight: AppColors.errorLight,
      errorDark: AppColors.errorDark,
      warning: AppColors.warning,
      warningLight: AppColors.warningLight,
      warningDark: AppColors.warningDark,
      info: AppColors.info,
      infoLight: AppColors.infoLight,
      // Navigation - Noon dark style (blue selected)
      appBarBackground: AppColors.darkAppBar,
      navBarBackground: AppColors.darkAppBar,
      navBarSelected: AppColors.darkPrimary,
      navBarUnselected: AppColors.darkNavUnselected,
      // Shadows & Overlays
      shadow: AppColors.shadow,
      shadowLight: AppColors.shadowLight,
      shadowMedium: AppColors.shadowMedium,
      overlay: AppColors.overlay,
      overlayLight: AppColors.overlayLight,
      // Skeleton
      skeletonBase: AppColors.darkSkeleton,
      skeletonHighlight: AppColors.darkSkeletonHighlight,
      // Base
      white: AppColors.white,
      black: AppColors.black,
    );
  }
}
