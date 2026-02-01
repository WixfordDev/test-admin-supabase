import 'package:flutter/material.dart';

class AudioControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final int currentVerseId;
  final int totalVerses;
  final VoidCallback onPlayPause;
  final VoidCallback onPreviousVerse;
  final VoidCallback onNextVerse;
  final AnimationController playPauseController;

  const AudioControlsWidget({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.currentVerseId,
    required this.totalVerses,
    required this.onPlayPause,
    required this.onPreviousVerse,
    required this.onNextVerse,
    required this.playPauseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, size: 32),
            color: const Color(0xFF2E7D32),
            onPressed: currentVerseId > 1 ? onPreviousVerse : null,
          ),
          GestureDetector(
            onTap: isLoading ? null : onPlayPause,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF2E7D32),
                        ),
                      )
                    : AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: playPauseController,
                        color: const Color(0xFF2E7D32),
                        size: 36,
                      ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, size: 32),
            color: const Color(0xFF2E7D32),
            onPressed: currentVerseId < totalVerses ? onNextVerse : null,
          ),
        ],
      ),
    );
  }
}
