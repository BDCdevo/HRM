import 'package:flutter/material.dart';

/// App Colors - Professional Navy, Blue & Yellow Theme
///
/// Balanced professional design with:
/// - Navy: AppBar, headers, primary elements
/// - Blue: Buttons, links, actions
/// - Yellow: Accents, badges, highlights
/// - White/Gray: Clean backgrounds
class AppColors {
  // ============================================
  // LIGHT MODE - Professional Theme
  // ============================================

  /// Primary - Navy Blue (كحلي)
  /// Used for: AppBar, headers, important text
  static const Color primary = Color(0xFF1E3A5F); // Navy Blue

  /// Primary Light
  static const Color primaryLight = Color(0xFF2E5077);

  /// Primary Dark
  static const Color primaryDark = Color(0xFF0F1E33);

  // ============================================
  // Secondary - Blue (أزرق)
  // ============================================

  /// Secondary Blue - For buttons and actions
  static const Color accent = Color(0xFF2196F3); // Blue

  /// Secondary (alias)
  static const Color secondary = Color(0xFF2196F3);

  /// Accent Light
  static const Color accentLight = Color(0xFF64B5F6);

  /// Accent Dark
  static const Color accentDark = Color(0xFF1976D2);

  // ============================================
  // Tertiary - Yellow (أصفر للتمييز)
  // ============================================

  /// Yellow - For highlights, badges, special elements
  static const Color accentYellow = Color(0xFFFFC107); // Amber Yellow

  /// Yellow Light
  static const Color accentYellowLight = Color(0xFFFFD54F);

  /// Yellow Dark
  static const Color accentYellowDark = Color(0xFFFFA000);

  /// Accent Purple - For special offers
  static const Color accentPurple = Color(0xFF7C4DFF);

  /// Accent Gray
  static const Color accentGray = Color(0xFF78909C);

  // ============================================
  // Semantic Colors
  // ============================================

  /// Success - Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  /// Error - Red
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  /// Warning - Orange
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  /// Info - Light Blue
  static const Color info = Color(0xFF03A9F4);
  static const Color infoLight = Color(0xFF4FC3F7);

  // ============================================
  // Special Purpose Colors
  // ============================================

  /// WhatsApp Green
  static const Color whatsappGreen = Color(0xFF25D366);

  /// WhatsApp Gray Colors
  static const Color whatsappGrayDark = Color(0xFF667781);
  static const Color whatsappGrayMedium = Color(0xFF54656F);
  static const Color whatsappGrayLight = Color(0xFF8696A0);
  static const Color whatsappBlack = Color(0xFF111B21);

  /// WhatsApp Bubbles
  static const Color whatsappSentBubble = Color(0xFFD9FDD3);
  static const Color whatsappReceivedBubble = Color(0xFFFFFFFF);

  /// Services Colors
  static const Color servicesGray = Color(0xFF607D8B);
  static const Color servicesLightGray = Color(0xFF90A4AE);

  // ============================================
  // Text Colors
  // ============================================

  /// Primary text - Dark Navy
  static const Color textPrimary = Color(0xFF1E3A5F);

  /// Secondary text - Gray
  static const Color textSecondary = Color(0xFF546E7A);

  /// Tertiary text - Light Gray
  static const Color textTertiary = Color(0xFF78909C);

  /// Disabled text
  static const Color textDisabled = Color(0xFFB0BEC5);

  /// Text on primary (navy/blue) - White
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors
  // ============================================

  /// Main background - Clean white
  static const Color background = Color(0xFFFFFFFF);

  /// Light background - Very light gray
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Alternate background - Light blue-gray
  static const Color backgroundAlt = Color(0xFFF5F7FA);

  /// Dark background - Navy
  static const Color backgroundDark = Color(0xFF1E3A5F);

  /// Surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant
  static const Color surfaceVariant = Color(0xFFF5F7FA);

  /// Field background
  static const Color fieldBackground = Color(0xFFF5F7FA);

  // ============================================
  // Border Colors
  // ============================================

  /// Default border
  static const Color border = Color(0xFFE0E0E0);

  /// Light border
  static const Color borderLight = Color(0xFFECEFF1);

  /// Medium border
  static const Color borderMedium = Color(0xFFB0BEC5);

  /// Soft border
  static const Color borderSoft = Color(0xFFE0E0E0);

  /// Neutral border
  static const Color borderNeutral = Color(0xFFCFD8DC);

  /// Dark border
  static const Color borderDark = Color(0xFF78909C);

  // ============================================
  // Shadow & Overlay
  // ============================================

  static const Color shadow = Color(0x1A1E3A5F);
  static const Color shadowLight = Color(0x0D1E3A5F);
  static const Color shadowMedium = Color(0x261E3A5F);

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Icon Colors
  // ============================================

  /// Primary icon - Navy
  static const Color iconPrimary = Color(0xFF1E3A5F);

  /// Secondary icon - Gray
  static const Color iconSecondary = Color(0xFF546E7A);

  /// Tertiary icon - Light Gray
  static const Color iconTertiary = Color(0xFF78909C);

  /// Icon on dark
  static const Color iconOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Divider Colors
  // ============================================

  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFECEFF1);

  // ============================================
  // Base Colors
  // ============================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color dark = Color(0xFF1E3A5F);
  static const Color transparent = Colors.transparent;

  // ============================================
  // DARK MODE
  // ============================================

  static const Color darkBackground = Color(0xFF0D1B2A);
  static const Color darkCard = Color(0xFF1B2838);
  static const Color darkAppBar = Color(0xFF1B2838);
  static const Color darkInput = Color(0xFF243447);
  static const Color darkBorder = Color(0xFF37474F);
  static const Color darkDivider = Color(0xFF37474F);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0BEC5);
  static const Color darkTextTertiary = Color(0xFF78909C);
  static const Color darkTextHint = Color(0xFF546E7A);

  static const Color darkIcon = Color(0xFFFFFFFF);
  static const Color darkSkeleton = Color(0xFF243447);
  static const Color darkSkeletonHighlight = Color(0xFF37474F);
  static const Color darkNavUnselected = Color(0xFF78909C);

  /// Dark mode primary - Light Blue
  static const Color darkPrimary = Color(0xFF64B5F6);

  /// Dark mode accent - Yellow
  static const Color darkAccent = Color(0xFFFFC107);

  /// Dark mode success
  static const Color darkSuccess = Color(0xFF81C784);

  static const Color darkCardElevated = Color(0xFF243447);

  // ============================================
  // Chat Colors
  // ============================================

  static const Color darkWhatsappSentBubble = Color(0xFF005C4B);
  static const Color darkWhatsappReceivedBubble = Color(0xFF1B2838);
  static const Color darkWhatsappGray = Color(0xFF8696A0);
  static const Color darkWhatsappText = Color(0xFFE9EDEF);
  static const Color darkChatBackground = Color(0xFF0D1B2A);

  static const Color chatBackground = Color(0xFFF5F7FA);
  static const Color chatInputBackground = Color(0xFFFFFFFF);
  static const Color darkChatInputBackground = Color(0xFF243447);

  // ============================================
  // Chart Colors - Professional Mix
  // ============================================

  static const List<Color> chartColors = [
    Color(0xFF1E3A5F), // Navy
    Color(0xFF2196F3), // Blue
    Color(0xFFFFC107), // Yellow
    Color(0xFF4CAF50), // Green
    Color(0xFF78909C), // Gray
  ];

  // ============================================
  // Gradients
  // ============================================

  /// Navy gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A5F), Color(0xFF2E5077)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Yellow gradient
  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark gradient
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
