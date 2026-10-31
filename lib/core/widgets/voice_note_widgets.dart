import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

/// Interactive audio player for voice notes in Chat and Health Diary.
class VoiceNotePlayerWidget extends StatefulWidget {
  final int durationSeconds;
  final bool isDoctor;
  final bool isMe;
  final String? title;
  final bool compact;

  const VoiceNotePlayerWidget({
    super.key,
    required this.durationSeconds,
    this.isDoctor = false,
    this.isMe = false,
    this.title,
    this.compact = false,
  });

  @override
  State<VoiceNotePlayerWidget> createState() => _VoiceNotePlayerWidgetState();
}

class _VoiceNotePlayerWidgetState extends State<VoiceNotePlayerWidget> {
  bool _isPlaying = false;
  int _currentSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    HapticFeedback.selectionClick();
    if (_isPlaying) {
      _stopPlay();
    } else {
      _startPlay();
    }
  }

  void _startPlay() {
    setState(() {
      _isPlaying = true;
      if (_currentSeconds >= widget.durationSeconds) {
        _currentSeconds = 0;
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_currentSeconds < widget.durationSeconds) {
          _currentSeconds++;
        } else {
          _stopPlay();
          _currentSeconds = 0;
        }
      });
    });
  }

  void _stopPlay() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Pre-calculated pseudo audio waveform bar heights (0.2 to 1.0)
  static const List<double> _waveformHeights = [
    0.3, 0.6, 0.4, 0.8, 0.9, 0.5, 0.7, 0.4, 0.85, 1.0,
    0.6, 0.75, 0.5, 0.9, 0.65, 0.4, 0.8, 0.55, 0.9, 0.45,
    0.7, 0.85, 0.6, 0.35, 0.75, 0.5, 0.8, 0.4, 0.65, 0.3,
  ];

  @override
  Widget build(BuildContext context) {
    final progress = widget.durationSeconds > 0
        ? (_currentSeconds / widget.durationSeconds).clamp(0.0, 1.0)
        : 0.0;

    final primaryColor = widget.isMe
        ? AppColors.primary
        : (widget.isDoctor ? const Color(0xFF8B263E) : const Color(0xFF2C5E7A));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 10 : 14,
        vertical: widget.compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: widget.isMe
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isMe
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.softDustyBlush,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null) ...[
            Row(
              children: [
                Icon(Icons.mic_rounded, size: 14, color: primaryColor),
                const SizedBox(width: 4),
                Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              // Play/Pause circular button
              InkWell(
                onTap: _togglePlay,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: widget.compact ? 34 : 38,
                  height: widget.compact ? 34 : 38,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: widget.compact ? 20 : 24,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Animated Waveform Bars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: widget.compact ? 22 : 26,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(_waveformHeights.length, (idx) {
                          final barProgress = idx / _waveformHeights.length;
                          final isPassed = barProgress <= progress;
                          final baseHeight = _waveformHeights[idx];
                          final animHeight = (_isPlaying && isPassed)
                              ? (baseHeight * (widget.compact ? 18 : 22)).clamp(4.0, 26.0)
                              : (baseHeight * (widget.compact ? 14 : 18)).clamp(4.0, 22.0);

                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              height: animHeight,
                              decoration: BoxDecoration(
                                color: isPassed
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isPlaying
                              ? _formatTime(_currentSeconds)
                              : _formatTime(widget.durationSeconds),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        if (_isPlaying)
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(widget.durationSeconds),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Realistic voice recorder bar with live duration counter and controls.
class VoiceRecorderBarWidget extends StatefulWidget {
  final ValueChanged<int> onSend;
  final VoidCallback onCancel;
  final bool isDoctor;

  const VoiceRecorderBarWidget({
    super.key,
    required this.onSend,
    required this.onCancel,
    this.isDoctor = false,
  });

  @override
  State<VoiceRecorderBarWidget> createState() => _VoiceRecorderBarWidgetState();
}

class _VoiceRecorderBarWidgetState extends State<VoiceRecorderBarWidget>
    with SingleTickerProviderStateMixin {
  int _seconds = 0;
  Timer? _recordTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.powderBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          // Cancel Button (Trash)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
            tooltip: 'إلغاء التسجيل',
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.onCancel();
            },
          ),
          const SizedBox(width: 4),

          // Pulsing Red Recording Indicator
          FadeTransition(
            opacity: _pulseController,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Live Recording Timer
          Text(
            _formatTime(_seconds),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),

          const Expanded(
            child: Text(
              'جاري تسجيل فويس طبي...',
              style: TextStyle(fontSize: 11.5, color: AppColors.secondaryText),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Stop & Send Button
          InkWell(
            onTap: () {
              HapticFeedback.heavyImpact();
              widget.onSend(_seconds > 0 ? _seconds : 3);
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
