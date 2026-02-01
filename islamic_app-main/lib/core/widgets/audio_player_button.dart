import 'dart:async';
import 'package:flutter/material.dart';
import 'package:deenhub/config/themes/theme_colors.dart';
import 'package:deenhub/core/services/shared_audio_service.dart';

// Enhanced Audio Player Button Widget with beautiful UI
class AudioPlayerButton extends StatefulWidget {
  final String audioKey;
  final String label;
  final Color? color;
  final double? size;
  final bool showLabel;
  final bool isCompact;

  const AudioPlayerButton({
    super.key,
    required this.audioKey,
    required this.label,
    this.color,
    this.size,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  State<AudioPlayerButton> createState() => _AudioPlayerButtonState();
}

class _AudioPlayerButtonState extends State<AudioPlayerButton>
    with TickerProviderStateMixin {
  final SharedAudioService _audioService = SharedAudioService.instance;
  late StreamSubscription<bool> _playingSubscription;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _playingSubscription = _audioService.playingStateStream
        .listen((isPlaying) {
      if (mounted) {
        // Only update if this button's audio is currently playing
        final isMyAudio = _audioService.currentContext == 'prayer_guide' && isPlaying;
        setState(() {
          _isPlaying = isMyAudio;
        });
        if (_isPlaying) {
          _animationController.repeat(reverse: true);
        } else {
          _animationController.stop();
          _animationController.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _playingSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    try {
      // If currently playing this audio, stop it
      if (_audioService.currentContext == 'prayer_guide' && _audioService.isPlaying) {
        await _audioService.stop();
      } else {
        // Play this audio
        await _audioService.playPrayerAudio(widget.audioKey);
      }
    } catch (e) {
      debugPrint('Error playing prayer audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? ThemeColors.blue;
    
    if (widget.isCompact) {
      return _buildCompactButton(color);
    }
    
    return _buildFullButton(color);
  }

  Widget _buildCompactButton(Color color) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: _isPlaying ? 8 : 4,
                    spreadRadius: _isPlaying ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
                color: ThemeColors.white,
                size: 18,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullButton(Color color) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: _isPlaying ? 12 : 6,
                    spreadRadius: _isPlaying ? 2 : 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(_isPlaying),
                      color: ThemeColors.white,
                      size: 20,
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(width: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: ThemeColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        shadows: _isPlaying ? [
                          const Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                          ),
                        ] : [],
                      ),
                      child: Text(_isPlaying ? 'Stop' : widget.label),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enhanced Compact Audio Button
class CompactAudioButton extends StatelessWidget {
  final String audioKey;
  final Color? color;

  const CompactAudioButton({
    super.key,
    required this.audioKey,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AudioPlayerButton(
      audioKey: audioKey,
      label: '',
      color: color,
      showLabel: false,
      isCompact: true,
    );
  }
}

// Beautiful Audio Section Widget
class AudioSection extends StatelessWidget {
  final String title;
  final String audioKey;
  final Color? color;
  final IconData? icon;
  final String? description;

  const AudioSection({
    super.key,
    required this.title,
    required this.audioKey,
    this.color,
    this.icon,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final sectionColor = color ?? ThemeColors.green;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            sectionColor.withValues(alpha: 0.08),
            sectionColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sectionColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sectionColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon!,
                color: sectionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: sectionColor,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.darkGray.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AudioPlayerButton(
            audioKey: audioKey,
            label: 'Listen',
            color: sectionColor,
          ),
        ],
      ),
    );
  }
} 