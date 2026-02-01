import 'package:flutter/material.dart';
import 'dart:math' as math;

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Row(
              children: [
                _buildDecorativeElement(primaryColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: theme.colorScheme.onBackground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.transparent,
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              validator: validator,
              textInputAction: textInputAction,
              onEditingComplete: onEditingComplete,
              cursorColor: primaryColor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 18.0,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: prefix != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                        child: prefix,
                      )
                    : null,
                suffixIcon: suffix,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: _buildInputBorder(primaryColor.withValues(alpha: 0.3), 1.0),
                enabledBorder: _buildInputBorder(primaryColor.withValues(alpha: 0.3), 1.0),
                focusedBorder: _buildInputBorder(primaryColor, 2.0, hasFocus: true),
                errorBorder: _buildInputBorder(theme.colorScheme.error, 1.0),
                focusedErrorBorder: _buildInputBorder(theme.colorScheme.error, 2.0, hasFocus: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildInputBorder(Color color, double width, {bool hasFocus = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  Widget _buildDecorativeElement(Color color) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: IslamicStarPainter(color),
    );
  }
}

class IslamicStarPainter extends CustomPainter {
  final Color color;
  
  IslamicStarPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final path = Path();
    
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      
      // Add inner points for star shape
      final innerRadius = radius * 0.4;
      final innerAngle = angle + math.pi / 8;
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);
      
      path.lineTo(innerX, innerY);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 