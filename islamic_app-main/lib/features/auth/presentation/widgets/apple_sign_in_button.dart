import 'dart:io';
import 'package:flutter/material.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Only show on iOS
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: isLoading ? null : () {
            // Show a quick feedback
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connecting to Apple...'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                behavior: SnackBarBehavior.floating,
              ),
            );
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apple logo (using Material Design Apple icon)
                    Icon(
                      Icons.apple,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),

                    // Button text
                    Text(
                      'Continue with Apple',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    // Add Islamic decorative element
                    const SizedBox(width: 10),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 10),
                    _buildIslamicDecorator(primaryColor),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildIslamicDecorator(Color color) {
    return Icon(
      Icons.star,
      size: 16,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }
}
