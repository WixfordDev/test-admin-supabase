import 'package:deenhub/config/routes/routes.dart';

import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/auth/presentation/widgets/auth_button.dart';
import 'package:deenhub/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:deenhub/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:deenhub/features/auth/presentation/widgets/apple_sign_in_button.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' show pi, cos, sin;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      getIt<AuthBloc>().add(
        AuthEvent.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        ),
      );
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = context.primaryColor;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: _navigateBack,
        ),
        title: Text(
          'Create Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: getIt<AuthBloc>(),
        listener: (context, state) {
          state.maybeMap(
            error: (state) {
              // Check if this is a signup success message
              if (state.message == 'SIGNUP_SUCCESS_VERIFY_EMAIL') {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account created successfully! Please check your email and verify your account before signing in.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.1,
                      left: 16,
                      right: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                
                // Navigate to login screen after a delay
                Future.delayed(Duration(milliseconds: 1500), () {
                  context.pushReplacementNamed(Routes.login.name);
                });
              } else {
                // Show regular error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
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
              // This should not happen anymore since we don't authenticate on signup
              debugPrint('Warning: User was authenticated during signup - this should not happen');
            },
            orElse: () {},
          );
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
                    patternColor: primaryColor.withValues(alpha: 0.04),
                  ),
                ),
              ),
              
              // Bottom decorative element
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        primaryColor.withValues(alpha: 0.15),
                        primaryColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: CustomPaint(
                    painter: IslamicBorderPainter(color: primaryColor.withValues(alpha: 0.1)),
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
                            // Bismillah
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
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
                            
                            // Welcome text
                            Text(
                              'Join Our Community',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Create an account to connect with a global Islamic community',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name field
                            AuthInputField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'Enter your full name',
                              prefix: Icon(Icons.person_outline, color: primaryColor),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Email field
                            AuthInputField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Enter your email',
                              prefix: Icon(Icons.email_outlined, color: primaryColor),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password field
                            AuthInputField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Enter your password',
                              prefix: Icon(Icons.lock_outline, color: primaryColor),
                              obscureText: _obscurePassword,
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
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm password field
                            AuthInputField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Confirm your password',
                              prefix: Icon(Icons.lock_outline, color: primaryColor),
                              obscureText: _obscureConfirmPassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: primaryColor,
                                ),
                                onPressed: _toggleConfirmPasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _handleSignUp,
                            ),
                            const SizedBox(height: 32),

                            // Sign up button
                            AuthButton(
                              text: 'Create Account',
                              onPressed: _handleSignUp,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 32),

                            // OR divider
                            _buildIslamicDivider(theme, primaryColor),
                            const SizedBox(height: 32),

                            // Google sign in button
                            GoogleSignInButton(
                              onPressed: isLoading ? () {} : () {
                                debugPrint('Google sign-in button pressed from signup');
                                getIt<AuthBloc>().add(
                                      const AuthEvent.signInWithGoogle(),
                                    );
                              },
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),

                            // Apple sign in button (iOS only)
                            AppleSignInButton(
                              onPressed: isLoading ? () {} : () {
                                debugPrint('Apple sign-in button pressed from signup');
                                getIt<AuthBloc>().add(
                                      const AuthEvent.signInWithApple(),
                                    );
                              },
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 32),

                            // Sign in link
                            _buildSignInContainer(theme, primaryColor),
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

  Widget _buildSignInContainer(ThemeData theme, Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 22, color: primaryColor.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Text(
              "Already have an account? ",
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            GestureDetector(
              onTap: _navigateBack,
              child: Text(
                'Sign In',
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
          _drawGeometricFlower(canvas, paint, centerX, centerY, tileWidth * 0.2);
        }
      }
    }
  }

  void _drawOctagonalStar(
      Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
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
      Canvas canvas, Paint paint, double centerX, double centerY, double radius) {
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

// Islamic border painter for decorative elements
class IslamicBorderPainter extends CustomPainter {
  final Color color;

  IslamicBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;
    
    // Draw decorative arches at the top
    final archCount = 7;
    final archWidth = width / archCount;
    
    for (int i = 0; i < archCount; i++) {
      final startX = i * archWidth;
      final endX = (i + 1) * archWidth;
      final controlX = (startX + endX) / 2;
      final controlY = height * 0.2;
      
      path.moveTo(startX, 0);
      path.quadraticBezierTo(controlX, controlY, endX, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(IslamicBorderPainter oldDelegate) => 
      oldDelegate.color != color;
}
