import 'package:flutter/material.dart';

/// App Colors - Blue Theme System
///
/// Modern blue color scheme with perfect harmony between Light & Dark modes
/// Inspired by Material Design 3 Blue palette
class AppColors {
  // ============================================
  // LIGHT MODE - Blue Theme
  // ============================================

  /// Primary - Warm Neutral Blue (محايد دافئ)
  /// Used for: Primary buttons, AppBar, important elements
  static const Color primary = Color(0xFF6B7FA8); // Warm desaturated blue

  /// Primary Light - Soft Warm Blue
  static const Color primaryLight = Color(0xFF8FA3C4); // Light warm blue

  /// Primary Dark - Deep Warm Blue
  static const Color primaryDark = Color(0xFF4A5D7E); // Dark warm blue

  // ============================================
  // Accent Colors (Light Mode)
  // ============================================

  /// Accent/Secondary - Warm Teal (تيل دافئ محايد)
  /// Used for: Secondary actions, highlights
  static const Color accent = Color(0xFF7FA89A); // Warm desaturated teal

  /// Secondary (alias for accent)
  static const Color secondary = Color(0xFF7FA89A);

  /// Accent Light - Soft Warm Teal
  static const Color accentLight = Color(0xFFA3C4B7); // Light warm teal

  /// Accent Dark - Deep Warm Teal
  static const Color accentDark = Color(0xFF5A7E70); // Dark warm teal

  /// Accent Purple - Warm Neutral Purple
  static const Color accentPurple = Color(0xFF9B8AA4); // Warm desaturated purple

  /// Accent Gray - Warm Subtle Gray
  static const Color accentGray = Color(0xFFA8ADB3); // Warm neutral gray

  // ============================================
  // Semantic Colors
  // ============================================

  /// Success - Warm Neutral Green
  static const Color success = Color(0xFF6B9B7F);
  static const Color successLight = Color(0xFF8FB5A3);
  static const Color successDark = Color(0xFF4A7E5D);

  /// Error - Warm Neutral Red
  static const Color error = Color(0xFFB37373);
  static const Color errorLight = Color(0xFFC99999);
  static const Color errorDark = Color(0xFF8F5757);

  /// Warning - Warm Amber
  static const Color warning = Color(0xFFBF9B6F);
  static const Color warningLight = Color(0xFFD4B594);
  static const Color warningDark = Color(0xFF9A7A54);

  /// Info - Warm Neutral Blue
  static const Color info = Color(0xFF8FA3C4);
  static const Color infoLight = Color(0xFFAFBFD6);

  // ============================================
  // Special Purpose Colors
  // ============================================

  /// WhatsApp Green - For chat/messaging
  static const Color whatsappGreen = Color(0xFF25D366);

  /// Services Colors - Warm neutral tones
  static const Color servicesGray = Color(0xFF6B7280);
  static const Color servicesLightGray = Color(0xFF9CA3AF);

  // ============================================
  // Text Colors (Light Mode) - Enhanced Contrast
  // ============================================

  /// Primary text - Very Dark (for maximum readability)
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary text - Dark gray (better contrast)
  static const Color textSecondary = Color(0xFF374151);

  /// Tertiary text - Medium gray (improved visibility)
  static const Color textTertiary = Color(0xFF6B7280);

  /// Disabled text - Light gray
  static const Color textDisabled = Color(0xFF9CA3AF);

  /// Text on primary color - White
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark backgrounds - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors (Light Mode)
  // ============================================

  /// Main background - Very light blue-gray
  static const Color background = Color(0xFFF5F7FA);

  /// Light background - Almost white with blue tint
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Alternate background - Light blue-gray
  static const Color backgroundAlt = Color(0xFFEDF2F7);

  /// Dark background (for dark sections in light mode)
  static const Color backgroundDark = Color(0xFF6B7FA8);

  /// Surface - Pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant - Very light gray
  static const Color surfaceVariant = Color(0xFFF7FAFC);

  /// Input/Field Background - Very light warm gray
  static const Color fieldBackground = Color(0xFFF8F9FA);

  // ============================================
  // Border Colors (Light Mode)
  // ============================================

  /// Default border - Light gray with blue tint
  static const Color border = Color(0xFFE2E8F0);

  /// Light border - Very light gray
  static const Color borderLight = Color(0xFFF1F5F9);

  /// Medium border - Medium gray
  static const Color borderMedium = Color(0xFFCBD5E0);

  /// Soft border - Warm light gray
  static const Color borderSoft = Color(0xFFDDE2E8);

  /// Neutral border - Light warm gray
  static const Color borderNeutral = Color(0xFFD1D5DB);

  /// Dark border - Dark gray
  static const Color borderDark = Color(0xFF718096);

  // ============================================
  // Shadow & Overlay Colors
  // ============================================

  /// Default shadow - Black with opacity
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x26000000);

  /// Overlays
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Icon Colors (Light Mode) - Enhanced Contrast
  // ============================================

  /// Primary icon - Very Dark (better visibility)
  static const Color iconPrimary = Color(0xFF1F2937);

  /// Secondary icon - Dark gray (improved contrast)
  static const Color iconSecondary = Color(0xFF374151);

  /// Tertiary icon - Medium gray (better visibility)
  static const Color iconTertiary = Color(0xFF6B7280);

  /// Icon on dark backgrounds - White
  static const Color iconOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Divider Colors (Light Mode)
  // ============================================

  /// Default divider - Light gray
  static const Color divider = Color(0xFFE2E8F0);

  /// Light divider - Very light gray
  static const Color dividerLight = Color(0xFFF1F5F9);

  // ============================================
  // Base Colors
  // ============================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Dark - Primary dark (alias)
  static const Color dark = Color(0xFF4A5D7E);

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ============================================
  // DARK MODE - Modern Black Theme (Updated Design)
  // ============================================

  /// Dark mode - Main background (Pure dark black)
  static const Color darkBackground = Color(0xFF1A1A1A);

  /// Dark mode - Card/Surface (Dark gray)
  static const Color darkCard = Color(0xFF2D2D2D);

  /// Dark mode - AppBar & Navigation Bar (Darker black)
  static const Color darkAppBar = Color(0xFF1F1F1F);

  /// Dark mode - Input fields (Dark gray)
  static const Color darkInput = Color(0xFF2D2D2D);

  /// Dark mode - Borders (Lighter gray for better visibility)
  static const Color darkBorder = Color(0xFF4B5563);

  /// Dark mode - Dividers (Lighter gray for better visibility)
  static const Color darkDivider = Color(0xFF4B5563);

  /// Dark mode - Primary text (Pure white)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark mode - Secondary text (Brighter gray for enhanced contrast)
  static const Color darkTextSecondary = Color(0xFFD1D5DB);

  /// Dark mode - Tertiary text (Medium-light gray for better visibility)
  static const Color darkTextTertiary = Color(0xFFA0A0A0);

  /// Dark mode - Hint text (Light gray for improved visibility)
  static const Color darkTextHint = Color(0xFF9CA3AF);

  /// Dark mode - Icons (White)
  static const Color darkIcon = Color(0xFFFFFFFF);

  /// Dark mode - Skeleton/Shimmer base
  static const Color darkSkeleton = Color(0xFF2D2D2D);

  /// Dark mode - Skeleton/Shimmer highlight
  static const Color darkSkeletonHighlight = Color(0xFF3D3D3D);

  /// Dark mode - Unselected navigation items
  static const Color darkNavUnselected = Color(0xFF808080);

  /// Dark mode - Primary color (Keep existing blue for buttons)
  static const Color darkPrimary = Color(0xFF8FA3C4);

  /// Dark mode - Accent color (Green for badges and success states)
  static const Color darkAccent = Color(0xFF4CAF50);

  /// Dark mode - Success/Badge color (Green for promo badges)
  static const Color darkSuccess = Color(0xFF4CAF50);

  /// Dark mode - Card elevated (Slightly lighter for hover/selected states)
  static const Color darkCardElevated = Color(0xFF363636);

  // ============================================
  // Chart Colors (Blue Theme)
  // ============================================

  /// Chart color palette - Warm Neutral harmony
  static const List<Color> chartColors = [
    Color(0xFF6B7FA8), // Warm neutral blue
    Color(0xFF7FA89A), // Warm teal
    Color(0xFF9B8AA4), // Warm purple
    Color(0xFFBF9B6F), // Warm amber
    Color(0xFFA8ADB3), // Warm gray
  ];

  // ============================================
  // Gradient Colors (Blue Theme)
  // ============================================

  /// Primary gradient - Warm Neutral Blue gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6B7FA8), Color(0xFF8FA3C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Warm Teal gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7FA89A), Color(0xFFA3C4B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient - Warm Neutral Purple
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9B8AA4), Color(0xFFB8AAC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode gradient - Dark blue to lighter blue
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A1929), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
