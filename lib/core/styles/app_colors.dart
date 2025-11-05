import 'package:flutter/material.dart';

/// App Colors
///
/// Centralized color palette for the HRM app
/// Based on the UI design reference with minimalist black & white theme
///
/// Primary colors derived from: C:\Users\B-SMART\AndroidStudioProjects\hrm\ui_design
class AppColors {
  // ============================================
  // Brand Colors (Primary Palette)
  // ============================================

  /// Main brand color - Dark Navy
  /// Used for: Primary buttons, active states, important text
  static const Color primary = Color(0xFF2D3142);

  /// Lighter variant of primary
  static const Color primaryLight = Color(0xFF4F5D75);

  /// Darker variant of primary - Pure black for maximum contrast
  static const Color primaryDark = Color(0xFF000000);

  // ============================================
  // Accent Colors
  // ============================================

  /// Accent color - Coral/Orange
  /// Used for: CTAs, highlights, warnings, active indicators
  static const Color accent = Color(0xFFEF8354);

  /// Secondary color - Green (alias for success, for backwards compatibility)
  /// Used for: Secondary buttons, success indicators
  /// @deprecated Use `accent` for secondary actions or `success` for success states
  static const Color secondary = Color(0xFF10B981);

  /// Secondary accent - Purple
  /// Used for: Secondary actions, special highlights
  static const Color accentPurple = Color(0xFF9B72AA);

  /// Tertiary accent - Light Gray
  /// Used for: Subtle backgrounds, inactive states
  static const Color accentGray = Color(0xFFBFC0C0);

  // ============================================
  // Semantic Colors
  // ============================================

  /// Error/Danger color - Coral (matches accent)
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  /// Success color - Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  /// Warning color - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  /// Info color - Dark Navy (matches primary)
  static const Color info = Color(0xFF4F5D75);
  static const Color infoLight = Color(0xFF9CA3AF);

  // ============================================
  // Text Colors
  // ============================================

  /// Primary text - Near black
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary text - Medium gray
  static const Color textSecondary = Color(0xFF6B7280);

  /// Tertiary text - Light gray
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Disabled text - Very light gray
  static const Color textDisabled = Color(0xFFD1D5DB);

  /// Text on dark backgrounds - White
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text on primary color - White
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // Background Colors
  // ============================================

  /// Main background - Pure white
  static const Color background = Color(0xFFFFFFFF);

  /// Light background - Very light gray
  static const Color backgroundLight = Color(0xFFF8F9FA);

  /// Alternate background - Light gray
  static const Color backgroundAlt = Color(0xFFF3F4F6);

  /// Dark background - Dark navy (for cards, modals)
  static const Color backgroundDark = Color(0xFF2D3142);

  /// Surface color - White (for elevated elements)
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant - Very light gray
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ============================================
  // Border Colors
  // ============================================

  /// Default border - Light gray
  static const Color border = Color(0xFFE5E7EB);

  /// Light border - Very light gray
  static const Color borderLight = Color(0xFFF3F4F6);

  /// Medium border - Medium gray
  static const Color borderMedium = Color(0xFFD1D5DB);

  /// Dark border - Dark gray
  static const Color borderDark = Color(0xFF9CA3AF);

  // ============================================
  // Shadow & Overlay Colors
  // ============================================

  /// Default shadow - Black with 10% opacity
  static const Color shadow = Color(0x1A000000);

  /// Light shadow - Black with 5% opacity
  static const Color shadowLight = Color(0x0D000000);

  /// Medium shadow - Black with 15% opacity
  static const Color shadowMedium = Color(0x26000000);

  /// Modal/Drawer overlay - Black with 50% opacity
  static const Color overlay = Color(0x80000000);

  /// Light overlay - Black with 25% opacity
  static const Color overlayLight = Color(0x40000000);

  // ============================================
  // Icon Colors
  // ============================================

  /// Primary icon - Dark gray
  static const Color iconPrimary = Color(0xFF1F2937);

  /// Secondary icon - Medium gray
  static const Color iconSecondary = Color(0xFF6B7280);

  /// Tertiary icon - Light gray
  static const Color iconTertiary = Color(0xFF9CA3AF);

  /// Icon on dark backgrounds - White
  static const Color iconOnDark = Color(0xFFFFFFFF);

  // ============================================
  // Divider Colors
  // ============================================

  /// Default divider - Light gray
  static const Color divider = Color(0xFFE5E7EB);

  /// Light divider - Very light gray
  static const Color dividerLight = Color(0xFFF3F4F6);

  // ============================================
  // Chart Colors (for data visualization)
  // ============================================

  /// Chart color palette matching the design
  static const List<Color> chartColors = [
    Color(0xFF2D3142), // Dark navy
    Color(0xFF4F5D75), // Medium blue-gray
    Color(0xFFBFC0C0), // Light gray
    Color(0xFFEF8354), // Coral/orange
    Color(0xFF9B72AA), // Purple
  ];

  // ============================================
  // Base Colors
  // ============================================

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  /// Pure black
  static const Color black = Color(0xFF000000);

  /// Dark - Dark Navy (alias for consistency)
  static const Color dark = Color(0xFF2D3142);

  /// Transparent
  static const Color transparent = Colors.transparent;

  // ============================================
  // Gradient Colors
  // ============================================

  /// Primary gradient - Dark navy to medium gray
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D3142), Color(0xFF4F5D75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient - Coral to orange
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFEF8354), Color(0xFFE76F51)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Purple gradient
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9B72AA), Color(0xFF8B5FA8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
