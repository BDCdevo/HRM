import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/styles/app_theme.dart';
import 'features/auth/logic/cubit/auth_cubit.dart';
import 'features/auth/logic/cubit/auth_state.dart';
import 'core/routing/app_router.dart';
import 'core/navigation/main_navigation_screen.dart';
import 'features/auth/ui/screens/user_type_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit()..checkAuthStatus(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'HRM App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,

            // Initial Route based on Authentication Status
            initialRoute: state is AuthAuthenticated
                ? AppRouter.mainNavigation
                : AppRouter.userTypeSelection,

            // Route Generator
            onGenerateRoute: AppRouter.onGenerateRoute,

            // Home Screen (fallback)
            home: state is AuthAuthenticated
                ? const MainNavigationScreen()
                : const UserTypeSelectionScreen(),
          );
        },
      ),
    );
  }
}
