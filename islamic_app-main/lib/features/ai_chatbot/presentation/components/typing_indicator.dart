import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    required Animation<double> animation1,
    required Animation<double> animation2,
    required Animation<double> animation3,
  })  : _animation1 = animation1,
        _animation2 = animation2,
        _animation3 = animation3;

  final Animation<double> _animation1;
  final Animation<double> _animation2;
  final Animation<double> _animation3;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7A8C), Color(0xFF3A8A9C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2A7A8C).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // Typing indicator bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: const Radius.circular(4),
                bottomRight: const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFEAEFF0),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TypingIndicatorAnimatedDot(animation: _animation1),
                const SizedBox(width: 4),
                TypingIndicatorAnimatedDot(animation: _animation2),
                const SizedBox(width: 4),
                TypingIndicatorAnimatedDot(animation: _animation3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated dot for typing indicator using AnimatedBuilder
class TypingIndicatorAnimatedDot extends StatelessWidget {
  const TypingIndicatorAnimatedDot({
    super.key,
    required this.animation,
  });

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -6 * animation.value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF2A7A8C).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
