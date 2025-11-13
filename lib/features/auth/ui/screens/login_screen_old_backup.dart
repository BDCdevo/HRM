import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/navigation/main_navigation_screen.dart';
import '../../logic/cubit/auth_cubit.dart';
import '../../logic/cubit/auth_state.dart';
import 'register_screen.dart';


/// Login Screen
///
/// Enhanced modern login screen with animations and better UX
/// Figma Reference: https://www.figma.com/design/mO0XvE4zIjUFO7xv6Tioxo/Cutframe.in---wireframe-kit---Community-?node-id=439-5989
///
/// Features:
/// - Gradient background
/// - Elevated card design
/// - Smooth animations
/// - Remember Me functionality
/// - Better visual hierarchy
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
        child: Container(
          // Gradient Background
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D3142), // Primary Dark
                Color(0xFF4F5D75), // Primary Light
                Color(0xFF2D3142), // Primary Dark
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // Clear errors
              setState(() {
                _emailError = null;
                _passwordError = null;
              });

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Welcome back, ${state.user.fullName}!'),
                  backgroundColor: AppColors.success,
                ),
              );

              // Navigate to main navigation
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            } else if (state is AuthError) {
              // Show error message
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

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Logo with Glow Effect
                        _buildHeroLogo(),

                        const SizedBox(height: 48),

                        // Login Card Container
                        Container(
                          constraints: const BoxConstraints(maxWidth: 450),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                blurRadius: 60,
                                offset: const Offset(0, 20),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Welcome Text
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Welcome Back',
                                          style: AppTextStyles.headlineMedium.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Sign in to continue to HRM',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      error: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.iconSecondary,
                      ),
                      enabled: !isLoading,
                      onChanged: (_) {
                        // Clear error when user types
                        if (_emailError != null) {
                          setState(() {
                            _emailError = null;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      error: _passwordError,
                      obscureText: true,
                      showPasswordToggle: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.iconSecondary,
                      ),
                      enabled: !isLoading,
                      onChanged: (_) {
                        // Clear error when user types
                        if (_passwordError != null) {
                          setState(() {
                            _passwordError = null;
                          });
                        }
                      },
                      onSubmitted: (_) {
                        if (!isLoading) {
                          _handleLogin();
                        }
                      },
                    ),

                                  const SizedBox(height: 16),

                                  // Remember Me & Forgot Password Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Remember Me Checkbox
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: isLoading
                                                  ? null
                                                  : (value) {
                                                      setState(() {
                                                        _rememberMe = value ?? false;
                                                      });
                                                    },
                                              activeColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Remember Me',
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Forgot Password Link
                                      TextButton(
                                        onPressed: isLoading ? null : _handleForgotPassword,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 32),

                                  // Login Button with Enhanced Shadow
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: CustomButton(
                                      text: 'Login',
                                      onPressed: _handleLogin,
                                      isLoading: isLoading,
                                      type: ButtonType.primary,
                                      size: ButtonSize.large,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderLight,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          'OR',
                                          style: AppTextStyles.labelSmall.copyWith(
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: AppColors.borderLight,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Register Link
                                  Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: isLoading ? null : _handleRegister,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            'Register',
                                            style: AppTextStyles.labelLarge.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
            ),
          ),
        ),
      ),
    );
  }

  /// Build Hero Logo
  Widget _buildHeroLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.8),
            blurRadius: 20,
            offset: const Offset(0, 0),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.business_center,
            size: 36,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// Handle Login
  void _handleLogin() {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    // Call login method from AuthCubit
    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  /// Validate Inputs
  bool _validateInputs() {
    bool isValid = true;

    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      isValid = false;
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      isValid = false;
    }

    // Validate password
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    }

    return isValid;
  }

  /// Email Validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Handle Forgot Password
  void _handleForgotPassword() {
    // TODO: Navigate to Forgot Password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot Password feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Handle Register
  void _handleRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }
}
