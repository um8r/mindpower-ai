import 'package:flutter/material.dart';
import 'package:mindpower_ai/core/theme/app_theme.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({Key? key}) : super(key: key);

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _instruction = "Tap Start to Begin Breathing";
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 100.0, end: 200.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (!_isRunning) return;
      if (status == AnimationStatus.completed) {
        setState(() => _instruction = "Hold Breath...");
        Future.delayed(const Duration(seconds: 4), () {
          if (_isRunning) _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _instruction = "Exhale Slowly...");
        Future.delayed(const Duration(seconds: 4), () {
          if (_isRunning) _controller.forward();
        });
      }
    });
  }

  void _toggleBreathing() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _instruction = "Inhale Deeply...";
        _controller.forward();
      } else {
        _controller.stop();
        _instruction = "Session Paused";
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mindful Breathing Room")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_instruction, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
            const SizedBox(height: 50),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: _animation.value,
                  height: _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryTeal.withOpacity(0.3),
                    border: Border.all(color: AppTheme.primaryTeal, width: 3),
                  ),
                  child: const Center(
                    child: Icon(Icons.self_improvement, size: 40, color: AppTheme.primaryTeal),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _toggleBreathing,
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
              label: Text(_isRunning ? "Pause Exercise" : "Start Breathing", style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}