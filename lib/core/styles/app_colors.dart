import 'package:flutter/material.dart';

/// App Colors - Noon Style Theme
///
/// Clean, professional design inspired by Noon app
/// Yellow for primary actions only, white backgrounds, dark text
class AppColors {
  // ============================================
  // LIGHT MODE - Noon Style
  // ============================================

  /// Primary - Noon Yellow (أصفر نون)
  /// Used for: Primary buttons, FAB, selected states ONLY
  static const Color primary = Color(0xFFFEED00); // Noon Yellow

  /// Primary Light - Lighter Yellow
  static const Color primaryLight = Color(0xFFFFF44F); // Light yellow

  /// Primary Dark - Darker Yellow (for pressed states)
  static const Color primaryDark = Color(0xFFE5D600); // Pressed yellow

  // ============================================
  // Accent Colors - Noon Blue
  // ============================================

  /// Accent/Secondary - Noon Blue (للروابط والعروض)
  static const Color accent = Color(0xFF3866DF); // Noon Blue

  /// Secondary (alias for accent)
  static const Color secondary = Color(0xFF3866DF);

  /// Accent Light - Soft Blue
  static const Color accentLight = Color(0xFF5A8AFF); // Light blue

  /// Accent Dark - Deep Blue
  static const Color accentDark = Color(0xFF2850B8); // Dark blue

  /// Accent Purple - For special offers
  static const Color accentPurple = Color(0xFF8B5CF6); // Purple

  /// Accent Gray
  static const Color accentGray = Color(0xFF6B7280);

  // ============================================
  // Semantic Colors - Noon Style
  // ============================================

  /// Success - Green
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);

  /// Error - Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Warning - Orange
  static const Color warning = Color(0xFFF97316);
  static const Color warningLight = Color(0xFFFB923C);
  static const Color warningDark = Color(0xFFEA580C);

  /// Info - Blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // ============================================
  // Special Purpose Colors
  // ============================================

  /// WhatsApp Green - For chat/messaging
  static const Color whatsappGreen = Color(0xFF25D366);

  /// WhatsApp Gray Colors - For chat UI (Light mode)
  static const Color whatsappGrayDark = Color(0xFF667781);
  static const Color whatsappGrayMedium = Color(0xFF54656F);
  static const Color whatsappGrayLight = Color(0xFF8696A0);
  static const Color whatsappBlack = Color(0xFF111B21);

  /// WhatsApp Message Bubble Colors
  static const Color whatsappSentBubble = Color(0xFFD9FDD3);
  static const Color whatsappReceivedBubble = Color(0xFFFFFFFF);

  /// Services Colors
  static const Color servicesGray = Color(0xFF6B7280);
  static const Color servicesLightGray = Color(0xFF9CA3AF);

  // ============================================
  // Text Colors - Noon Style (Dark & Clear)
  // ============================================

  /// Primary text - Pure Black
  static const Color textPrimary = Color(0xFF000000);

  /// Secondary text - Dark gray
  static const Color textSecondary = Color(0xFF404040);

  /// Tertiary text - Medium gray
  static const Color textTertiary = Color(0xFF737373);

  /// Disabled text - Light gray
  static const Color textDisabled = Color(0xFFA3A3A3);

  /// Text on primary (yellow) - Black
  static const Color textOnPrimary = Color(0xFF000000);

  /// Text on dark backgrounds - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors - Pure White (Noon Style)
  // ============================================

  /// Main background - Pure white
  static const Color background = Color(0xFFFFFFFF);

  /// Light background - Very light gray (for sections)
  static const Color backgroundLight = Color(0xFFF5F5F5);

  /// Alternate background - Light gray
  static const Color backgroundAlt = Color(0xFFF0F0F0);

  /// Dark background
  static const Color backgroundDark = Color(0xFF1A1A1A);

  /// Surface - Pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant - Very light gray
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Input/Field Background
  static const Color fieldBackground = Color(0xFFF5F5F5);

  // ============================================
  // Border Colors - Noon Style (Subtle)
  // ============================================

  /// Default border - Light gray
  static const Color border = Color(0xFFE5E5E5);

  /// Light border
  static const Color borderLight = Color(0xFFF0F0F0);

  /// Medium border
  static const Color borderMedium = Color(0xFFD4D4D4);

  /// Soft border
  static const Color borderSoft = Color(0xFFE5E5E5);

  /// Neutral border
  static const Color borderNeutral = Color(0xFFD4D4D4);

  /// Dark border
  static const Color borderDark = Color(0xFF737373);

  // ============================================
  // Shadow & Overlay Colors
  // ============================================

  /// Shadows - Subtle
  static const Color shadow = Color(0x14000000);
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1F000000);

  /// Overlays
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Icon Colors - Dark (Noon Style)
  // ============================================

  /// Primary icon - Black
  static const Color iconPrimary = Color(0xFF000000);

  /// Secondary icon - Dark gray
  static const Color iconSecondary = Color(0xFF404040);

  /// Tertiary icon - Medium gray
  static const Color iconTertiary = Color(0xFF737373);

  /// Icon on dark backgrounds
  static const Color iconOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Divider Colors
  // ============================================

  /// Default divider
  static const Color divider = Color(0xFFE5E5E5);

  /// Light divider
  static const Color dividerLight = Color(0xFFF0F0F0);

  // ============================================
  // Base Colors
  // ============================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Dark
  static const Color dark = Color(0xFF1A1A1A);

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ============================================
  // DARK MODE - Noon Dark Style
  // ============================================

  /// Dark mode - Main background
  static const Color darkBackground = Color(0xFF121212);

  /// Dark mode - Card/Surface
  static const Color darkCard = Color(0xFF1E1E1E);

  /// Dark mode - AppBar
  static const Color darkAppBar = Color(0xFF1E1E1E);

  /// Dark mode - Input fields
  static const Color darkInput = Color(0xFF2A2A2A);

  /// Dark mode - Borders
  static const Color darkBorder = Color(0xFF333333);

  /// Dark mode - Dividers
  static const Color darkDivider = Color(0xFF333333);

  /// Dark mode - Primary text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark mode - Secondary text
  static const Color darkTextSecondary = Color(0xFFE5E5E5);

  /// Dark mode - Tertiary text
  static const Color darkTextTertiary = Color(0xFFA3A3A3);

  /// Dark mode - Hint text
  static const Color darkTextHint = Color(0xFF737373);

  /// Dark mode - Icons
  static const Color darkIcon = Color(0xFFFFFFFF);

  /// Dark mode - Skeleton
  static const Color darkSkeleton = Color(0xFF2A2A2A);
  static const Color darkSkeletonHighlight = Color(0xFF333333);

  /// Dark mode - Nav unselected
  static const Color darkNavUnselected = Color(0xFF737373);

  /// Dark mode - Primary (Noon Yellow)
  static const Color darkPrimary = Color(0xFFFEED00);

  /// Dark mode - Accent
  static const Color darkAccent = Color(0xFF3866DF);

  /// Dark mode - Success
  static const Color darkSuccess = Color(0xFF22C55E);

  /// Dark mode - Card elevated
  static const Color darkCardElevated = Color(0xFF2A2A2A);

  // ============================================
  // DARK MODE - Chat Colors
  // ============================================

  static const Color darkWhatsappSentBubble = Color(0xFF005C4B);
  static const Color darkWhatsappReceivedBubble = Color(0xFF1E1E1E);
  static const Color darkWhatsappGray = Color(0xFF8696A0);
  static const Color darkWhatsappText = Color(0xFFE9EDEF);
  static const Color darkChatBackground = Color(0xFF121212);

  // ============================================
  // LIGHT MODE - Chat Colors
  // ============================================

  static const Color chatBackground = Color(0xFFF5F5F5);
  static const Color chatInputBackground = Color(0xFFFFFFFF);
  static const Color darkChatInputBackground = Color(0xFF2A2A2A);

  // ============================================
  // Chart Colors - Noon Style
  // ============================================

  static const List<Color> chartColors = [
    Color(0xFFFEED00), // Noon Yellow
    Color(0xFF3866DF), // Noon Blue
    Color(0xFF22C55E), // Green
    Color(0xFFF97316), // Orange
    Color(0xFF737373), // Gray
  ];

  // ============================================
  // Gradient Colors
  // ============================================

  /// Primary gradient - Yellow
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFEED00), Color(0xFFFFF44F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Blue
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3866DF), Color(0xFF5A8AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark gradient
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
