import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/theme/app_theme.dart';

class SessionPlayerScreen extends StatefulWidget {
  final String title;
  final String category;
  final int durationMinutes;
  final List<String> steps;

  const SessionPlayerScreen({
    super.key,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.steps,
  });

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPlaying = false;
  int _currentStepIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45); // Calm & slow pace for meditation
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speakCurrentStep() async {
    await _flutterTts.stop();
    if (widget.steps.isNotEmpty) {
      await _flutterTts.speak(widget.steps[_currentStepIndex]);
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _timer?.cancel();
      _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _speakCurrentStep(); // Speak initial instruction

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          if (!mounted) return;
          setState(() {
            _remainingSeconds--;
            
            final totalSecs = widget.durationMinutes * 60;
            final elapsed = totalSecs - _remainingSeconds;
            final stepDuration = totalSecs / (widget.steps.isEmpty ? 1 : widget.steps.length);
            final newIndex = (elapsed / stepDuration).floor().clamp(0, widget.steps.isEmpty ? 0 : widget.steps.length - 1);

            // Announce new instruction when step changes
            if (newIndex != _currentStepIndex) {
              _currentStepIndex = newIndex;
              _speakCurrentStep();
            }
          });
        } else {
          _timer?.cancel();
          _flutterTts.stop();
          if (!mounted) return;
          setState(() => _isPlaying = false);
          _showCompletionDialog();
        }
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _flutterTts.stop();
    setState(() {
      _remainingSeconds = widget.durationMinutes * 60;
      _isPlaying = false;
      _currentStepIndex = 0;
    });
  }

  void _showCompletionDialog() {
    _flutterTts.speak("Session completed. Well done.");
    showDialog(
      context: context,
      builder: (context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 28),
              const SizedBox(width: 8),
              Text('Session Completed!', style: TextStyle(color: AppTheme.getDeepSlate(context))),
            ],
          ),
          content: Text(
            'Great job completing the ${widget.title} session. You have taken a vital step toward mental clarity.',
            style: TextStyle(color: AppTheme.getTextMuted(context)),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = 1.0 - (_remainingSeconds / (widget.durationMinutes * 60));
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.category.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, fontSize: 12),
              ),
            ),
            const SizedBox(height: 30),

            // Progress & Timer Display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPlaying ? 'AUDIO GUIDANCE ACTIVE' : 'PAUSED',
                      style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Player Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 36,
                  icon: Icon(Icons.refresh_rounded, color: AppTheme.getDeepSlate(context)),
                  onPressed: _resetTimer,
                  tooltip: 'Reset Session',
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  backgroundColor: AppTheme.primaryTeal,
                  onPressed: _togglePlayPause,
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.volume_up_rounded, color: AppTheme.primaryTeal),
                  onPressed: _speakCurrentStep,
                  tooltip: 'Replay Instruction',
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Instructions Box
            Expanded(
              child: Card(
                color: Theme.of(context).cardColor,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Guided Instructions',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.getDeepSlate(context)),
                          ),
                          Text(
                            'Step ${_currentStepIndex + 1} of ${widget.steps.isEmpty ? 1 : widget.steps.length}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Expanded(
                        child: Center(
                          child: Text(
                            widget.steps.isNotEmpty ? widget.steps[_currentStepIndex] : 'No instructions available.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppTheme.getDeepSlate(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}