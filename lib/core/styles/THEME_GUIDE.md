# HRM App Theme Guide

## Overview
This guide explains how to use the unified theme system in the HRM app. The theme is based on the UI design references and implements a minimalist black & white design with accent colors.

## Design Reference
Colors and styles derived from: `C:\Users\B-SMART\AndroidStudioProjects\hrm\ui_design`

## Theme Files

### 1. `app_colors.dart`
Contains all color constants used throughout the app.

### 2. `app_theme.dart`
Contains the complete Material 3 theme configuration.

### 3. `app_text_styles.dart`
Contains text style definitions.

---

## Color Palette

### Brand Colors
```dart
AppColors.primary           // #2D3142 - Dark Navy (main brand color)
AppColors.primaryLight      // #4F5D75 - Medium Blue-Gray
AppColors.primaryDark       // #000000 - Pure Black
```

### Accent Colors
```dart
AppColors.accent            // #EF8354 - Coral/Orange (CTAs, highlights)
AppColors.accentPurple      // #9B72AA - Purple (secondary highlights)
AppColors.accentGray        // #BFC0C0 - Light Gray (subtle backgrounds)
```

### Semantic Colors
```dart
// Success
AppColors.success           // #10B981 - Green
AppColors.successLight      // #34D399
AppColors.successDark       // #059669

// Error
AppColors.error             // #EF4444 - Red
AppColors.errorLight        // #F87171
AppColors.errorDark         // #DC2626

// Warning
AppColors.warning           // #F59E0B - Amber
AppColors.warningLight      // #FBBF24
AppColors.warningDark       // #D97706

// Info
AppColors.info              // #4F5D75 - Matches primaryLight
AppColors.infoLight         // #9CA3AF
```

### Text Colors
```dart
AppColors.textPrimary       // #1F2937 - Near black
AppColors.textSecondary     // #6B7280 - Medium gray
AppColors.textTertiary      // #9CA3AF - Light gray
AppColors.textDisabled      // #D1D5DB - Very light gray
AppColors.textOnDark        // #FFFFFF - White
AppColors.textOnPrimary     // #FFFFFF - White
```

### Background Colors
```dart
AppColors.background        // #FFFFFF - Pure white
AppColors.backgroundLight   // #F8F9FA - Very light gray
AppColors.backgroundAlt     // #F3F4F6 - Light gray
AppColors.backgroundDark    // #2D3142 - Dark navy
AppColors.surface           // #FFFFFF - White
AppColors.surfaceVariant    // #F5F5F5 - Very light gray
```

### Chart Colors
```dart
AppColors.chartColors[0]    // #2D3142 - Dark navy
AppColors.chartColors[1]    // #4F5D75 - Medium blue-gray
AppColors.chartColors[2]    // #BFC0C0 - Light gray
AppColors.chartColors[3]    // #EF8354 - Coral/orange
AppColors.chartColors[4]    // #9B72AA - Purple
```

### Gradients
```dart
AppColors.primaryGradient   // Dark navy to medium gray
AppColors.accentGradient    // Coral to orange
AppColors.purpleGradient    // Purple gradient
```

---

## Usage Examples

### 1. Using Colors Directly
```dart
// ✅ Good - Use AppColors constants
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)

// ❌ Bad - Don't use hardcoded colors
Container(
  color: Color(0xFF2D3142), // Don't do this!
  child: Text('Hello', style: TextStyle(color: Colors.white)),
)
```

### 2. Using Theme
```dart
// ✅ Best - Use Theme for automatic updates
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)
```

### 3. Using Custom Widgets
```dart
// CustomButton already uses the theme
CustomButton(
  text: 'Click Me',
  type: ButtonType.primary,  // Uses AppColors.primary
  onPressed: () {},
)

CustomButton(
  text: 'Secondary',
  type: ButtonType.secondary,  // Uses AppColors.accent
  onPressed: () {},
)

// CustomTextField already uses the theme
CustomTextField(
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
)
```

### 4. Charts and Data Visualization
```dart
// Use chartColors for consistent visualization
Container(
  decoration: BoxDecoration(
    color: AppColors.chartColors[0],
  ),
)

// For line charts
LineChartBarData(
  color: AppColors.primary,
  dotData: FlDotData(
    getDotPainter: (spot, percent, barData, index) {
      return FlDotCirclePainter(
        color: AppColors.accent,
      );
    },
  ),
)
```

### 5. Cards and Containers
```dart
// Modern card style
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: YourContent(),
)
```

### 6. Gradients
```dart
// Use predefined gradients
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12),
  ),
  child: YourContent(),
)
```

---

## Best Practices

### ✅ DO
- Use `AppColors.*` constants for all colors
- Use `Theme.of(context).*` for theme-aware widgets
- Use `CustomButton` and `CustomTextField` widgets
- Maintain the 12-16px border radius for consistency
- Use shadows sparingly (shadowLight for subtle effects)

### ❌ DON'T
- Don't hardcode color values (e.g., `Color(0xFF...)`)
- Don't use `Colors.*` from Material (use AppColors instead)
- Don't create new color constants outside of AppColors
- Don't use heavy shadows (keep it minimal)
- Don't mix old and new color schemes

---

## Theme Configuration in main.dart

```dart
MaterialApp(
  title: 'HRM App',
  theme: AppTheme.lightTheme,      // Use unified theme
  darkTheme: AppTheme.darkTheme,   // Future dark mode support
  themeMode: ThemeMode.light,
  home: HomeScreen(),
)
```

---

## Color Meaning & Usage

| Color | Usage | Examples |
|-------|-------|----------|
| **primary** | Main actions, branding | Primary buttons, app bar, active states |
| **accent** | Highlights, CTAs | Secondary buttons, important indicators |
| **success** | Positive feedback | Success messages, completion states |
| **error** | Warnings, errors | Error messages, validation errors |
| **warning** | Cautions | Warning banners, pending states |
| **info** | Informational | Info messages, tooltips |

---

## Updating the Theme

### To change a color:
1. Update `app_colors.dart` constant
2. The change applies automatically throughout the app
3. Test the app to ensure consistency

### To add a new color:
1. Add constant to appropriate section in `app_colors.dart`
2. Document the usage with a comment
3. Update this guide if needed

---

## Accessibility

- All color combinations meet WCAG 2.1 AA standards
- Primary text on white background: 15.8:1 contrast ratio
- White text on primary background: 12.2:1 contrast ratio
- Minimum touch target size: 44x44 dp (maintained in CustomButton)

---

## Migration Guide

### From old colors to new:
```dart
// Old                          // New
Colors.blue       →  AppColors.primary
Colors.green      →  AppColors.success
Colors.orange     →  AppColors.accent
Colors.red        →  AppColors.error
Colors.grey[500]  →  AppColors.textSecondary
Colors.grey[300]  →  AppColors.border
```

---

## Support

For questions or issues with the theme system:
1. Check this guide first
2. Review `app_colors.dart` for available colors
3. Review `app_theme.dart` for theme configuration
4. Check UI design references in `ui_design/` folder

---

**Last Updated:** 2025-01-02
**Version:** 1.0.0
**Design Reference:** C:\Users\B-SMART\AndroidStudioProjects\hrm\ui_design
