import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/navigation/main_navigation_screen.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/app_loading_screen.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';

/// Login Screen - Clean Uber-style Design
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final inputFillColor = isDark ? AppColors.darkInput : AppColors.fieldBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.borderSoft;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
              ? [
                  AppColors.darkBackground,
                  AppColors.darkCard,
                  AppColors.darkBackground,
                ]
              : [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
          ),
        ),
        child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.displayMessage),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Stack(
              children: [
                // Main Content
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section
                        Column(
                      children: [
                        // Logo with glow effect
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: SvgPicture.asset(
                            'assets/images/logo/bdc_logo.svg',
                            colorFilter: const ColorFilter.mode(
                              AppColors.primaryDark,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Login Card
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Welcome Back',
                            style: AppTextStyles.headlineLarge.copyWith(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue to HRM',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Email Label
                          Text(
                            'Email',
                            style: AppTextStyles.inputLabel.copyWith(
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Email Field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: AppTextStyles.inputText.copyWith(
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: AppTextStyles.inputHint.copyWith(
                                color: secondaryTextColor.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: secondaryTextColor,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password Label
                          Text(
                            'Password',
                            style: AppTextStyles.inputLabel.copyWith(
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTextStyles.inputText.copyWith(
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: AppTextStyles.inputHint.copyWith(
                                color: secondaryTextColor.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: secondaryTextColor,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: secondaryTextColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remember Me
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: isDark ? AppColors.primary : AppColors.primaryDark,
                                      checkColor: AppColors.white,
                                      side: BorderSide(
                                        color: borderColor,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember Me',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 13,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),

                              // Forgot Password
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontSize: 13,
                                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.primary : AppColors.primaryDark,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shadowColor: isDark ? AppColors.primary : AppColors.primaryDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

                // Loading Overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5), // خلفية شفافة
                    child: Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,

                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
          email: email,
          password: password,
        );
  }
}
