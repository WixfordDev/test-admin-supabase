import 'package:flutter/material.dart';
import 'dart:math' as math;

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    final bgColor = backgroundColor ?? (isOutlined ? Colors.transparent : primaryColor);
    final textColor = isOutlined ? primaryColor : theme.colorScheme.onPrimary;
    
    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: isOutlined 
            ? [] 
            : [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Islamic pattern design
            if (!isOutlined && !isLoading) ...[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CustomPaint(
                    painter: IslamicPatternPainter(
                      theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ],
            
            // Main button
            ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: isOutlined 
                      ? BorderSide(color: primaryColor, width: 2)
                      : BorderSide.none,
                ),
                disabledBackgroundColor: isOutlined 
                    ? Colors.transparent
                    : primaryColor.withValues(alpha: 0.7),
                disabledForegroundColor: isOutlined
                    ? primaryColor.withValues(alpha: 0.7)
                    : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOutlined ? primaryColor : theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Please wait...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            // Add decorative elements on the sides
            if (!isOutlined && !isLoading) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildDecorationDot(theme.colorScheme.onPrimary.withValues(alpha: 0.25)),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildDecorationDot(theme.colorScheme.onPrimary.withValues(alpha: 0.25)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDecorationDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  final Color patternColor;
  
  IslamicPatternPainter(this.patternColor);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    // Draw a subtle geometric pattern
    final patternSize = size.width / 8;
    
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        _drawGeometricElement(canvas, paint, x + patternSize/2, y + patternSize/2, patternSize/3);
      }
    }
  }
  
  void _drawGeometricElement(Canvas canvas, Paint paint, double x, double y, double size) {
    // Draw a simple octagonal shape
    final path = Path();
    
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final px = x + size * math.cos(angle);
      final py = y + size * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 