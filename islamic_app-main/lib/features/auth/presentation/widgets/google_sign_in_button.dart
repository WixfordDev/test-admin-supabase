import 'package:deenhub/config/gen/assets.gen.dart';
import 'package:deenhub/core/widgets/image_view.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                content: Text('Connecting to Google...'),
                duration: Duration(seconds: 2),
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.8),
                behavior: SnackBarBehavior.floating,
              ),
            );
            onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google logo
                    ImageView(
                      imagePath: Assets.imagesIcGoogle,
                      height: 28,
                      width: 28,
                    ),
                    const SizedBox(width: 12),

                    // Button text
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    // Add Islamic decorative element
                    const SizedBox(width: 10),
                    Container(
                      height: 24,
                      width: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
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
      color: color.withValues(alpha: 0.6),
    );
  }
}
