import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

/// Theme Cubit
///
/// Manages theme mode (light/dark) with persistence
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);

      if (themeIndex != null) {
        final themeMode = ThemeMode.values[themeIndex];
        emit(state.copyWith(themeMode: themeMode));
      }
    } catch (e) {
      // Use system default if loading fails
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      emit(state.copyWith(themeMode: mode));
    } catch (e) {
      // Silently fail, keep current theme
    }
  }

  /// Toggle between light and dark
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if current theme is dark
  bool get isDarkMode {
    return state.themeMode == ThemeMode.dark;
  }

  /// Check if using system theme
  bool get isSystemMode {
    return state.themeMode == ThemeMode.system;
  }
}
