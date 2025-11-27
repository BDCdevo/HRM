import 'package:flutter/material.dart';

/// App Colors - Yellow Theme System
///
/// Modern yellow color scheme with perfect harmony between Light & Dark modes
/// Inspired by Task Planning App Design - Fun & Energetic
class AppColors {
  // ============================================
  // LIGHT MODE - Yellow Theme
  // ============================================

  /// Primary - Deep Golden Yellow (أصفر ذهبي غامق)
  /// Used for: Buttons, icons, highlights ONLY - NOT backgrounds
  static const Color primary = Color(0xFFE5B800); // Darker Golden Yellow

  /// Primary Light - Medium Yellow
  static const Color primaryLight = Color(0xFFF4CA1C); // Medium yellow

  /// Primary Dark - Deep Gold
  static const Color primaryDark = Color(0xFFCC9900); // Deep gold

  // ============================================
  // Accent Colors (Light Mode)
  // ============================================

  /// Accent/Secondary - Deep Purple (بنفسجي للتباين)
  /// Used for: Secondary actions, highlights, dots
  static const Color accent = Color(0xFF7C5CFF); // Vibrant purple

  /// Secondary (alias for accent)
  static const Color secondary = Color(0xFF7C5CFF);

  /// Accent Light - Soft Purple
  static const Color accentLight = Color(0xFFA18AFF); // Light purple

  /// Accent Dark - Deep Purple
  static const Color accentDark = Color(0xFF5A3FD4); // Dark purple

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

  /// Warning - Orange (برتقالي للتحذيرات)
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFB84D);
  static const Color warningDark = Color(0xFFCC7700);

  /// Info - Warm Neutral Blue
  static const Color info = Color(0xFF8FA3C4);
  static const Color infoLight = Color(0xFFAFBFD6);

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
  static const Color whatsappSentBubble = Color(0xFFD9FDD3); // Light green for sent messages
  static const Color whatsappReceivedBubble = Color(0xFFFFFFFF); // White for received messages

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

  /// Text on primary color - Dark (للقراءة على الأصفر)
  static const Color textOnPrimary = Color(0xFF1F2937);

  /// Text on dark backgrounds - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors (Light Mode) - Clean White/Gray
  // ============================================

  /// Main background - Pure white (نظيف)
  static const Color background = Color(0xFFFFFFFF);

  /// Light background - Very light gray
  static const Color backgroundLight = Color(0xFFFAFAFA);

  /// Alternate background - Light gray
  static const Color backgroundAlt = Color(0xFFF5F5F5);

  /// Dark background (for dark sections in light mode)
  static const Color backgroundDark = Color(0xFF1F2937);

  /// Surface - Pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant - Very light gray
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  /// Input/Field Background - Light gray
  static const Color fieldBackground = Color(0xFFF5F5F5);

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
  static const Color dark = Color(0xFF1F2937);

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ============================================
  // DARK MODE - Modern Blue-Gray Theme
  // ============================================

  /// Dark mode - Main background (Deep blue-gray)
  static const Color darkBackground = Color(0xFF1B202D);

  /// Dark mode - Card/Surface (Lighter blue-gray)
  static const Color darkCard = Color(0xFF292F3F);

  /// Dark mode - AppBar & Navigation Bar (Same as cards)
  static const Color darkAppBar = Color(0xFF292F3F);

  /// Dark mode - Input fields (Same as cards)
  static const Color darkInput = Color(0xFF292F3F);

  /// Dark mode - Borders (Subtle lighter blue-gray)
  static const Color darkBorder = Color(0xFF3D4350);

  /// Dark mode - Dividers (Subtle lighter blue-gray)
  static const Color darkDivider = Color(0xFF3D4350);

  /// Dark mode - Primary text (Pure white for maximum contrast)
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark mode - Secondary text (Very bright gray for enhanced readability)
  static const Color darkTextSecondary = Color(0xFFE5E7EB);

  /// Dark mode - Tertiary text (Bright gray for better visibility)
  static const Color darkTextTertiary = Color(0xFFD1D5DB);

  /// Dark mode - Hint text (Light gray for improved visibility)
  static const Color darkTextHint = Color(0xFF9CA3AF);

  /// Dark mode - Icons (White)
  static const Color darkIcon = Color(0xFFFFFFFF);

  /// Dark mode - Skeleton/Shimmer base
  static const Color darkSkeleton = Color(0xFF1F2937);

  /// Dark mode - Skeleton/Shimmer highlight
  static const Color darkSkeletonHighlight = Color(0xFF374151);

  /// Dark mode - Unselected navigation items
  static const Color darkNavUnselected = Color(0xFF808080);

  /// Dark mode - Primary color (Darker Yellow for buttons)
  static const Color darkPrimary = Color(0xFFE5B800);

  /// Dark mode - Accent color (Purple for badges and highlights)
  static const Color darkAccent = Color(0xFF7C5CFF);

  /// Dark mode - Success/Badge color (Green for promo badges)
  static const Color darkSuccess = Color(0xFF4CAF50);

  /// Dark mode - Card elevated (Slightly lighter for hover/selected states)
  static const Color darkCardElevated = Color(0xFF323847);

  // ============================================
  // DARK MODE - WhatsApp Colors
  // ============================================

  /// Dark mode - WhatsApp message bubbles
  static const Color darkWhatsappSentBubble = Color(0xFF005C4B); // Dark green for sent
  static const Color darkWhatsappReceivedBubble = Color(0xFF1F2C33); // Dark gray for received

  /// Dark mode - WhatsApp text colors
  static const Color darkWhatsappGray = Color(0xFF8696A0);
  static const Color darkWhatsappText = Color(0xFFE9EDEF);

  /// Dark mode - Chat background
  static const Color darkChatBackground = Color(0xFF0B141A);

  // ============================================
  // LIGHT MODE - Chat Colors
  // ============================================

  /// Light mode - Chat background (WhatsApp style)
  static const Color chatBackground = Color(0xFFECE5DD);

  /// Light mode - Chat input background
  static const Color chatInputBackground = Color(0xFFF0F0F0);

  /// Dark mode - Chat input background
  static const Color darkChatInputBackground = Color(0xFF1F2C34);

  // ============================================
  // Chart Colors (Yellow Theme)
  // ============================================

  /// Chart color palette - Yellow Theme harmony
  static const List<Color> chartColors = [
    Color(0xFFE5B800), // Darker golden yellow
    Color(0xFF7C5CFF), // Purple accent
    Color(0xFF1F2937), // Dark charcoal
    Color(0xFFFF9500), // Orange
    Color(0xFFA8ADB3), // Warm gray
  ];

  // ============================================
  // Gradient Colors (Yellow Theme)
  // ============================================

  /// Primary gradient - Darker Yellow gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE5B800), Color(0xFFF4CA1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Purple gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7C5CFF), Color(0xFFA18AFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient - Warm Neutral Purple
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9B8AA4), Color(0xFFB8AAC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark mode gradient - Dark charcoal
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF374151)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
