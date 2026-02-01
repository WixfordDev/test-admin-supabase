import 'package:deenhub/core/di/app_injections.dart';
import 'package:deenhub/core/utils/view_utils.dart';
import 'package:deenhub/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:deenhub/features/auth/presentation/widgets/auth_button.dart';
import 'package:deenhub/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' show pi, cos, sin;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;
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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      getIt<AuthBloc>().add(
        AuthEvent.resetPassword(_emailController.text.trim()),
      );
      setState(() {
        _isEmailSent = true;
      });
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
          'Reset Password',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: getIt<AuthBloc>(),
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              context.showErrorSnackBar(message);
              setState(() {
                _isEmailSent = false;
              });
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          return Stack(
            children: [
              // Background with Islamic pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: IslamicPatternPainter(
                    patternColor: primaryColor.withValues(alpha: 0.04),
                    isVerticalGradient: true,
                  ),
                ),
              ),

              // Decorative element
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: IslamicArchPainter(
                      color: primaryColor.withValues(alpha: 0.1)),
                  size: const Size(double.infinity, 60),
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
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(
                                fontFamily: 'ScheherazadeNew',
                                fontSize: 24,
                                height: 1.5,
                                color: primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Icon
                            Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isEmailSent
                                    ? primaryColor.withValues(alpha: 0.1)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: _buildAnimatedIcon(primaryColor),
                            ),
                            const SizedBox(height: 24),

                            // Title and description
                            Text(
                              _isEmailSent ? 'Email Sent' : 'Forgot Password?',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _isEmailSent
                                    ? 'Please check your email for instructions to reset your password.'
                                    : 'Enter your email and we\'ll send you instructions to reset your password.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            if (!_isEmailSent) ...[
                              // Email field
                              AuthInputField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                prefix: Icon(Icons.email_outlined,
                                    color: primaryColor),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                                onEditingComplete: _handleResetPassword,
                              ),
                              const SizedBox(height: 32),

                              // Reset button
                              AuthButton(
                                text: 'Send Reset Link',
                                onPressed: _handleResetPassword,
                                isLoading: isLoading,
                                icon: Icons.send_outlined,
                              ),
                            ] else ...[
                              // Back to login button
                              AuthButton(
                                text: 'Back to Login',
                                onPressed: _navigateBack,
                                isLoading: false,
                                isOutlined: true,
                                icon: Icons.arrow_back,
                              ),
                            ],

                            // Islamic decoration at bottom
                            if (_isEmailSent) ...[
                              const SizedBox(height: 40),
                              CustomPaint(
                                painter: IslamicDividerPainter(
                                  color: primaryColor.withValues(alpha: 0.3),
                                ),
                                size: const Size(200, 20),
                              ),
                            ],
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

  Widget _buildAnimatedIcon(Color primaryColor) {
    if (_isEmailSent) {
      return Icon(
        Icons.check_circle,
        size: 80,
        color: primaryColor,
      );
    } else {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Icon(
          Icons.lock_reset,
          size: 80,
          color: Colors.white,
        ),
      );
    }
  }
}

// Islamic pattern painter for background decoration
class IslamicPatternPainter extends CustomPainter {
  final Color patternColor;
  final bool isVerticalGradient;

  IslamicPatternPainter(
      {required this.patternColor, this.isVerticalGradient = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
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

        // Calculate alpha for gradient effect
        double alpha = isVerticalGradient
            ? 0.02 + (i / rows) * 0.05 // Vertical gradient
            : 0.05;

        paint.color = patternColor.withValues(alpha: alpha);

        if ((i + j) % 2 == 0) {
          // Draw octagonal star
          _drawOctagonalStar(canvas, paint, centerX, centerY, tileWidth * 0.3);
        } else {
          // Draw geometric flower
          _drawGeometricFlower(
              canvas, paint, centerX, centerY, tileWidth * 0.2);
        }
      }
    }
  }

  void _drawOctagonalStar(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
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

  void _drawGeometricFlower(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
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
      oldDelegate.patternColor != patternColor ||
      oldDelegate.isVerticalGradient != isVerticalGradient;
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

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Create a central arch
    path.moveTo(width * 0.3, height);
    path.quadraticBezierTo(width * 0.5, 0, width * 0.7, height);

    // Add small arches on either side
    path.moveTo(width * 0.15, height);
    path.quadraticBezierTo(width * 0.25, height * 0.5, width * 0.35, height);

    path.moveTo(width * 0.65, height);
    path.quadraticBezierTo(width * 0.75, height * 0.5, width * 0.85, height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(IslamicArchPainter oldDelegate) =>
      oldDelegate.color != color;
}

// Islamic divider painter
class IslamicDividerPainter extends CustomPainter {
  final Color color;

  IslamicDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final width = size.width;
    final height = size.height;
    final center = width / 2;

    // Draw the main line
    canvas.drawLine(
      Offset(0, height / 2),
      Offset(width, height / 2),
      paint,
    );

    // Draw the central diamond
    final path = Path();
    path.moveTo(center - 10, height / 2);
    path.lineTo(center, height / 2 - 10);
    path.lineTo(center + 10, height / 2);
    path.lineTo(center, height / 2 + 10);
    path.close();
    canvas.drawPath(path, paint);

    // Draw small dots
    for (var i = 1; i < 5; i++) {
      // Left side
      canvas.drawCircle(
        Offset(center - (i * 20), height / 2),
        2,
        paint,
      );

      // Right side
      canvas.drawCircle(
        Offset(center + (i * 20), height / 2),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(IslamicDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
