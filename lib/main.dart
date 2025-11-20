import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'core/theme/cubit/theme_state.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/auth/logic/cubit/auth_state.dart';
import 'core/routing/app_router.dart';
import 'core/navigation/main_navigation_screen.dart';
import 'features/auth/ui/screens/login_screen.dart';
import 'core/widgets/app_loading_screen.dart';
import 'core/styles/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Build Home Screen based on Auth State
  ///
  /// Shows splash while checking, then navigates to appropriate screen
  Widget _buildHomeScreen(AuthState authState, bool isDark) {
    if (authState is AuthAuthenticated) {
      // User is logged in, go to main app
      return const MainNavigationScreen();
    } else {
      // Show login screen (whether checking or not logged in)
      // If checking auth, show Lottie overlay on top
      return Stack(
        children: [
          // Login Screen (always visible in background)
          const LoginScreen(),

          // Loading Overlay (only when checking authentication)
          if (authState is AuthInitial || authState is AuthLoading)
            Container(
              color: Colors.black.withOpacity(0.6), // خلفية شفافة
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.primary : AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Message

                  ],
                ),
              ),
            ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()..checkAuthStatus()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return MaterialApp(
                title: 'HRM App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.themeMode,

                // Route Generator
                onGenerateRoute: AppRouter.onGenerateRoute,

                // Home Screen based on Authentication Status
                home: _buildHomeScreen(
                  authState,
                  themeState.themeMode == ThemeMode.dark,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
