import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/config/routes/routes.dart';
import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:deenhub/features/auth/presentation/widgets/auth_button.dart';
import 'package:deenhub/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:deenhub/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:deenhub/features/auth/presentation/widgets/apple_sign_in_button.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show pi, cos, sin;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Add these variables to track authentication state
  late final AuthBloc _authBloc;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _authBloc.add(
        AuthEvent.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleAuthenticated() {
    if (_isNavigating) return; // Prevent multiple navigations

    _isNavigating = true;

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome back.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Continue',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              _performNavigation();
            },
          ),
        ),
      );
    }

    // Navigate after a short delay
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted && _isNavigating) {
        _performNavigation();
      }
    });
  }

  void _performNavigation() {
    if (!mounted || !_isNavigating) return;

    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        // If can't pop, navigate to home
        context.goNamed(Routes.home.name);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback navigation
      context.goNamed(Routes.home.name);
    }
  }

  void _navigateToSignUp() {
    context.pushNamed(Routes.signup.name);
  }

  void _navigateToForgotPassword() {
    context.pushNamed(Routes.forgotPassword.name);
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = context.primaryColor;
    final onPrimaryColor = context.onPrimaryColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onPrimaryColor),
          onPressed: _navigateBack,
        ),
        title: Text(
          'Login',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: onPrimaryColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: _authBloc,
        listenWhen: (previous, current) {
          // Only listen to specific state changes to prevent loops
          return (previous != current) && !_isNavigating;
        },
        listener: (context, state) {
          state.maybeMap(
            error: (errorState) {
              // Reset navigation flag on error
              _isNavigating = false;

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorState.message),
                    backgroundColor: theme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.1,
                      left: 16,
                      right: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    action: SnackBarAction(
                      label: 'Dismiss',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            },
            authenticated: (_) {
              _handleAuthenticated();
            },
            unauthenticated: (_) {
              // Reset navigation flag when unauthenticated
              _isNavigating = false;
            },
            orElse: () {},
          );
        },
        buildWhen: (previous, current) {
          // Rebuild only when the loading state actually changes
          final previousLoading = previous.maybeMap(
            loading: (_) => true,
            orElse: () => false,
          );
          final currentLoading = current.maybeMap(
            loading: (_) => true,
            orElse: () => false,
          );

          // Also rebuild on error or unauthenticated states
          final shouldRebuild =
              previousLoading != currentLoading ||
              current.maybeMap(
                error: (_) => true,
                unauthenticated: (_) => true,
                orElse: () => false,
              );

          return shouldRebuild;
        },
        builder: (context, state) {
          final isLoading = state.maybeMap(
            loading: (_) => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              // Background with Islamic pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicPatternPainter(
                    patternColor: primaryColor.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Top decorative element - Islamic Arch
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 220,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.9),
                        primaryColor.withValues(alpha: 0.6),
                        primaryColor.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.5, 0.8, 1.0],
                    ),
                  ),
                  child: CustomPaint(
                    painter: IslamicArchPainter(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // App logo with pulsating animation
                            _buildLogoWithAnimation(theme, primaryColor),
                            const SizedBox(height: 32),

                            // Bismillah
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                style: TextStyle(
                                  fontFamily: 'ScheherazadeNew',
                                  fontSize: 24,
                                  height: 1.5,
                                  color: primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              'Welcome Back',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to continue your Islamic journey',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Email field
                            AuthInputField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                              prefix: Icon(
                                Icons.email_outlined,
                                color: primaryColor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password field
                            AuthInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              obscureText: _obscurePassword,
                              prefix: Icon(
                                Icons.lock_outlined,
                                color: primaryColor,
                              ),
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primaryColor,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _handleLogin,
                            ),
                            const SizedBox(height: 16),

                            // Forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _navigateToForgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Login button
                            AuthButton(
                              text: 'Sign In',
                              onPressed: isLoading ? () {} : _handleLogin,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 32),

                            // OR divider with Islamic decoration
                            _buildIslamicDivider(theme, primaryColor),
                            const SizedBox(height: 32),

                            // Google sign in button
                            GoogleSignInButton(
                              onPressed: isLoading
                                  ? () {}
                                  : () {
                                      debugPrint(
                                        'Google sign-in button pressed',
                                      );
                                      _authBloc.add(
                                        const AuthEvent.signInWithGoogle(),
                                      );
                                    },
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),

                            // Apple sign in button (iOS only)
                            AppleSignInButton(
                              onPressed: isLoading
                                  ? () {}
                                  : () {
                                      debugPrint(
                                        'Apple sign-in button pressed',
                                      );
                                      _authBloc.add(
                                        const AuthEvent.signInWithApple(),
                                      );
                                    },
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 40),

                            // Sign up link
                            _buildSignUpContainer(theme, primaryColor),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogoWithAnimation(ThemeData theme, Color primaryColor) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 2,
            ),
            gradient: RadialGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface,
                primaryColor.withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
          child: ImageView(
            imagePath: Assets.logoAppLogo,
            clipBehavior: Clip.hardEdge,
            backgroundShape: BoxShape.circle,
            height: 70,
            width: 70,
          ),
        ),
      ),
    );
  }

  Widget _buildIslamicDivider(ThemeData theme, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.outline.withValues(alpha: 0.1),
                  theme.colorScheme.outline.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'OR',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.star,
                size: 12,
                color: primaryColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.outline.withValues(alpha: 0.6),
                  theme.colorScheme.outline.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpContainer(ThemeData theme, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 22,
              color: primaryColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Text(
              "Don't have an account? ",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: _navigateToSignUp,
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: primaryColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Islamic pattern painter for background decoration
class IslamicPatternPainter extends CustomPainter {
  final Color patternColor;

  IslamicPatternPainter({required this.patternColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw a subtle geometric pattern
    final int rows = 10;
    final int cols = 6;

    final double tileWidth = size.width / cols;
    final double tileHeight = size.height / rows;

    // Draw geometric shapes
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final centerX = j * tileWidth + tileWidth / 2;
        final centerY = i * tileHeight + tileHeight / 2;

        if ((i + j) % 2 == 0) {
          // Draw octagonal star
          _drawOctagonalStar(canvas, paint, centerX, centerY, tileWidth * 0.3);
        } else {
          // Draw geometric flower
          _drawGeometricFlower(
            canvas,
            paint,
            centerX,
            centerY,
            tileWidth * 0.2,
          );
        }
      }
    }
  }

  void _drawOctagonalStar(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    final path = Path();

    for (int i = 0; i < 8; i++) {
      double angle = i * pi / 4;
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGeometricFlower(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double radius,
  ) {
    for (int i = 0; i < 6; i++) {
      double angle = i * pi / 3;
      double x1 = centerX + radius * cos(angle);
      double y1 = centerY + radius * sin(angle);

      double x2 = centerX + radius * cos(angle + pi);
      double y2 = centerY + radius * sin(angle + pi);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) =>
      oldDelegate.patternColor != patternColor;
}

// Islamic arch painter for decorative elements
class IslamicArchPainter extends CustomPainter {
  final Color color;

  IslamicArchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw a series of nested Islamic arches
    final width = size.width;
    final height = size.height * 0.7;

    // Main arch at the bottom
    _drawArch(canvas, paint, width * 0.5, height, width * 0.45);

    // Smaller arches
    _drawArch(canvas, paint, width * 0.2, height, width * 0.15);
    _drawArch(canvas, paint, width * 0.8, height, width * 0.15);

    // Smallest arches
    _drawArch(canvas, paint, width * 0.35, height, width * 0.1);
    _drawArch(canvas, paint, width * 0.65, height, width * 0.1);
  }

  void _drawArch(
    Canvas canvas,
    Paint paint,
    double centerX,
    double bottom,
    double radius,
  ) {
    final path = Path();
    path.moveTo(centerX - radius, bottom);

    // Draw the arch curve
    path.quadraticBezierTo(
      centerX,
      bottom - radius * 2,
      centerX + radius,
      bottom,
    );

    canvas.drawPath(path, paint);

    // Add small decoration
    canvas.drawCircle(
      Offset(centerX, bottom - radius * 1.5),
      radius * 0.1,
      paint,
    );
  }

  @override
  bool shouldRepaint(IslamicArchPainter oldDelegate) =>
      oldDelegate.color != color;
}
