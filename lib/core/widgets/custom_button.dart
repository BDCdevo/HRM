import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

/// Button Type Enum
enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  error,
}

/// Button Size Enum
enum ButtonSize {
  small,
  medium,
  large,
}

/// Custom Button
///
/// Reusable button widget with different types and sizes
/// Supports loading state and icon buttons
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: (enabled && !isLoading) ? onPressed : null,
        style: _getButtonStyle(),
        child: _buildContent(),
      ),
    );
  }

  /// Get button height based on size
  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  /// Get button style based on type
  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.borderDark,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        );

      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.borderMedium,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        );

      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.backgroundLight,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        );

      case ButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.transparent,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shadowColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        );

      case ButtonType.error:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.borderDark,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _getHorizontalPadding(),
            vertical: _getVerticalPadding(),
          ),
        );
    }
  }

  /// Get horizontal padding based on size
  double _getHorizontalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 32;
    }
  }

  /// Get vertical padding based on size
  double _getVerticalPadding() {
    switch (size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  /// Get text style based on size
  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTextStyles.buttonSmall;
      case ButtonSize.medium:
      case ButtonSize.large:
        return AppTextStyles.button;
    }
  }

  /// Build button content
  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? AppColors.primary
                : AppColors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: _getTextStyle().copyWith(
              color: type == ButtonType.outline || type == ButtonType.text
                  ? AppColors.primary
                  : null,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: _getTextStyle().copyWith(
        color: type == ButtonType.outline || type == ButtonType.text
            ? AppColors.primary
            : null,
      ),
    );
  }
}
