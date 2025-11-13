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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
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

                // Initial Route based on Authentication Status
                initialRoute: authState is AuthAuthenticated
                    ? AppRouter.mainNavigation
                    : AppRouter.login,

                // Route Generator
                onGenerateRoute: AppRouter.onGenerateRoute,

                // Home Screen (fallback)
                home: authState is AuthAuthenticated
                    ? const MainNavigationScreen()
                    : const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
