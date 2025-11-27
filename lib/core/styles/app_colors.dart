import 'package:flutter/material.dart';

/// App Colors - Noon Style Theme (2024)
///
/// Clean, professional design inspired by Noon app
/// Blue & Black theme - minimal and modern
class AppColors {
  // ============================================
  // LIGHT MODE - Noon Style (Blue & Black)
  // ============================================

  /// Primary - Noon Blue
  /// Used for: Primary buttons, links, CTAs
  static const Color primary = Color(0xFF2962FF); // Noon Blue

  /// Primary Light
  static const Color primaryLight = Color(0xFF5B8BFF);

  /// Primary Dark
  static const Color primaryDark = Color(0xFF0039CB);

  // ============================================
  // Accent Colors
  // ============================================

  /// Accent/Secondary - Dark Blue
  static const Color accent = Color(0xFF1A237E);

  /// Secondary (alias)
  static const Color secondary = Color(0xFF1A237E);

  /// Accent Light
  static const Color accentLight = Color(0xFF534BAE);

  /// Accent Dark
  static const Color accentDark = Color(0xFF000051);

  /// Accent Purple - For special offers
  static const Color accentPurple = Color(0xFF7C4DFF);

  /// Accent Gray
  static const Color accentGray = Color(0xFF757575);

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

  /// Warning - Amber
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFCA28);
  static const Color warningDark = Color(0xFFFF8F00);

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
  static const Color servicesGray = Color(0xFF757575);
  static const Color servicesLightGray = Color(0xFFBDBDBD);

  // ============================================
  // Text Colors - Noon Style (Black & Gray)
  // ============================================

  /// Primary text - Black
  static const Color textPrimary = Color(0xFF212121);

  /// Secondary text - Dark gray
  static const Color textSecondary = Color(0xFF424242);

  /// Tertiary text - Medium gray
  static const Color textTertiary = Color(0xFF757575);

  /// Disabled text
  static const Color textDisabled = Color(0xFFBDBDBD);

  /// Text on primary (blue button) - White
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors - Pure White
  // ============================================

  /// Main background
  static const Color background = Color(0xFFFFFFFF);

  /// Light background
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Alternate background
  static const Color backgroundAlt = Color(0xFFF5F5F5);

  /// Dark background
  static const Color backgroundDark = Color(0xFF212121);

  /// Surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Field background
  static const Color fieldBackground = Color(0xFFF5F5F5);

  // ============================================
  // Border Colors
  // ============================================

  /// Default border
  static const Color border = Color(0xFFE0E0E0);

  /// Light border
  static const Color borderLight = Color(0xFFEEEEEE);

  /// Medium border
  static const Color borderMedium = Color(0xFFBDBDBD);

  /// Soft border
  static const Color borderSoft = Color(0xFFE0E0E0);

  /// Neutral border
  static const Color borderNeutral = Color(0xFFBDBDBD);

  /// Dark border
  static const Color borderDark = Color(0xFF757575);

  // ============================================
  // Shadow & Overlay
  // ============================================

  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x26000000);

  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Icon Colors
  // ============================================

  /// Primary icon - Dark
  static const Color iconPrimary = Color(0xFF212121);

  /// Secondary icon
  static const Color iconSecondary = Color(0xFF424242);

  /// Tertiary icon
  static const Color iconTertiary = Color(0xFF757575);

  /// Icon on dark
  static const Color iconOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Divider Colors
  // ============================================

  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFEEEEEE);

  // ============================================
  // Base Colors
  // ============================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color dark = Color(0xFF212121);
  static const Color transparent = Colors.transparent;

  // ============================================
  // DARK MODE
  // ============================================

  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkAppBar = Color(0xFF1E1E1E);
  static const Color darkInput = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF424242);
  static const Color darkDivider = Color(0xFF424242);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color darkTextTertiary = Color(0xFFBDBDBD);
  static const Color darkTextHint = Color(0xFF757575);

  static const Color darkIcon = Color(0xFFFFFFFF);
  static const Color darkSkeleton = Color(0xFF2C2C2C);
  static const Color darkSkeletonHighlight = Color(0xFF424242);
  static const Color darkNavUnselected = Color(0xFF757575);

  /// Dark mode primary - Same blue
  static const Color darkPrimary = Color(0xFF448AFF);

  /// Dark mode accent
  static const Color darkAccent = Color(0xFF536DFE);

  /// Dark mode success
  static const Color darkSuccess = Color(0xFF69F0AE);

  static const Color darkCardElevated = Color(0xFF2C2C2C);

  // ============================================
  // Chat Colors
  // ============================================

  static const Color darkWhatsappSentBubble = Color(0xFF005C4B);
  static const Color darkWhatsappReceivedBubble = Color(0xFF1E1E1E);
  static const Color darkWhatsappGray = Color(0xFF8696A0);
  static const Color darkWhatsappText = Color(0xFFE9EDEF);
  static const Color darkChatBackground = Color(0xFF121212);

  static const Color chatBackground = Color(0xFFF5F5F5);
  static const Color chatInputBackground = Color(0xFFFFFFFF);
  static const Color darkChatInputBackground = Color(0xFF2C2C2C);

  // ============================================
  // Chart Colors
  // ============================================

  static const List<Color> chartColors = [
    Color(0xFF2962FF), // Blue
    Color(0xFF1A237E), // Dark Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFB300), // Amber
    Color(0xFF757575), // Gray
  ];

  // ============================================
  // Gradients
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2962FF), Color(0xFF448AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFFB388FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF212121), Color(0xFF424242)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
