import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/styles/app_colors.dart';

/// Voice Message Player Widget
///
/// Plays voice messages with WhatsApp-style UI
class VoiceMessagePlayer extends StatefulWidget {
  final String audioUrl;
  final bool isMine;
  final bool isDark;

  const VoiceMessagePlayer({
    super.key,
    required this.audioUrl,
    required this.isMine,
    required this.isDark,
  });

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() {
    // Listen to player state
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Listen to player completion
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      print('🎵 Attempting to play/pause audio from: ${widget.audioUrl}');

      if (_isPlaying) {
        print('⏸️ Pausing audio...');
        await _audioPlayer.pause();
      } else {
        if (_position == Duration.zero || _position >= _duration) {
          // Start from beginning
          print('▶️ Starting audio from beginning...');
          await _audioPlayer.play(UrlSource(widget.audioUrl));
          print('✅ Audio player started');
        } else {
          // Resume from current position
          print('▶️ Resuming audio...');
          await _audioPlayer.resume();
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error playing audio: $e');
      print('❌ Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.isDark ? AppColors.darkPrimary : AppColors.primary;
    final accentColor = widget.isDark ? AppColors.darkAccent : AppColors.accent;
    final playButtonColor = widget.isMine ? accentColor : primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button
        GestureDetector(
          onTap: _togglePlayPause,
          child: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: playButtonColor,
            size: 36,
          ),
        ),

        const SizedBox(width: 8),

        // Waveform + Progress
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              SizedBox(
                height: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds / _duration.inMilliseconds
                        : 0,
                    backgroundColor: widget.isMine
                        ? accentColor.withOpacity(0.2)
                        : primaryColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(playButtonColor),
                    minHeight: 24,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Duration
              Text(
                _isPlaying || _position > Duration.zero
                    ? _formatDuration(_position)
                    : _formatDuration(_duration),
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF667781),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
