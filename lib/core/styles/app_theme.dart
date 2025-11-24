import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// App Theme
///
/// Centralized theme configuration for the HRM app
/// Implements the minimalist black & white design system
/// from the UI reference designs
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
        // ============================================
        // General
        // ============================================
        useMaterial3: true,
        brightness: Brightness.light,

        // ============================================
        // Color Scheme
        // ============================================
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentPurple,
          tertiary: AppColors.accentGray,
          error: AppColors.error,
          errorContainer: AppColors.errorLight,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceVariant,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.white,
          onError: AppColors.white,
          onSurface: AppColors.textPrimary,
          outline: AppColors.border,
          outlineVariant: AppColors.borderLight,
          shadow: AppColors.shadow,
        ),

        // ============================================
        // Scaffold
        // ============================================
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // ============================================
        // App Bar Theme
        // ============================================
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.iconPrimary,
            size: 24,
          ),
        ),

        // ============================================
        // Card Theme
        // ============================================
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(0),
        ),

        // ============================================
        // Elevated Button Theme
        // ============================================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.borderMedium,
            disabledForegroundColor: AppColors.textDisabled,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(120, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        // ============================================
        // Text Button Theme
        // ============================================
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            minimumSize: const Size(80, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ============================================
        // Outlined Button Theme
        // ============================================
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(120, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ============================================
        // Floating Action Button Theme
        // ============================================
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          highlightElevation: 8,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // ============================================
        // Icon Button Theme
        // ============================================
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.iconPrimary,
            disabledForegroundColor: AppColors.iconTertiary,
            highlightColor: AppColors.primary.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // ============================================
        // Input Decoration Theme
        // ============================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
          ),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          errorStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.error,
          ),
          prefixIconColor: AppColors.iconSecondary,
          suffixIconColor: AppColors.iconSecondary,
        ),

        // ============================================
        // Checkbox Theme
        // ============================================
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.white;
          }),
          checkColor: WidgetStateProperty.all(AppColors.white),
          side: const BorderSide(color: AppColors.border, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // ============================================
        // Radio Theme
        // ============================================
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.textSecondary;
          }),
        ),

        // ============================================
        // Switch Theme
        // ============================================
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }
            return AppColors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.borderMedium;
          }),
        ),

        // ============================================
        // Slider Theme
        // ============================================
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.borderLight,
          thumbColor: AppColors.primary,
          overlayColor: AppColors.primary.withOpacity(0.2),
          valueIndicatorColor: AppColors.primary,
        ),

        // ============================================
        // Progress Indicator Theme
        // ============================================
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.borderLight,
          circularTrackColor: AppColors.borderLight,
        ),

        // ============================================
        // Bottom Navigation Bar Theme
        // ============================================
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.iconSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),

        // ============================================
        // Navigation Bar Theme
        // ============================================
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          height: 80,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            );
          }),
        ),

        // ============================================
        // Divider Theme
        // ============================================
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ============================================
        // Dialog Theme
        // ============================================
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        // ============================================
        // Bottom Sheet Theme
        // ============================================
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: AppColors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
        ),

        // ============================================
        // Snackbar Theme
        // ============================================
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.white,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ============================================
        // Chip Theme
        // ============================================
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.primary,
          disabledColor: AppColors.borderLight,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
          ),
          secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // ============================================
        // Tooltip Theme
        // ============================================
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),

        // ============================================
        // List Tile Theme
        // ============================================
        listTileTheme: ListTileThemeData(
          tileColor: AppColors.white,
          selectedTileColor: AppColors.primary.withOpacity(0.1),
          iconColor: AppColors.iconPrimary,
          selectedColor: AppColors.primary,
          textColor: AppColors.textPrimary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // ============================================
        // Text Selection Theme
        // ============================================
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primary.withOpacity(0.3),
          selectionHandleColor: AppColors.primary,
        ),

        // ============================================
        // Icon Theme
        // ============================================
        iconTheme: const IconThemeData(
          color: AppColors.iconPrimary,
          size: 24,
        ),
      );

  /// Dark theme configuration
  /// Currently not implemented - using light theme
  /// TODO: Implement dark theme if needed
  static ThemeData get darkTheme => lightTheme;
}
