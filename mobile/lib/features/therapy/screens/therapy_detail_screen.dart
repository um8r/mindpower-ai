import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'session_player_screen.dart';

class TherapyDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const TherapyDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Default meditation guided steps if none are explicitly provided
    final List<String> defaultSteps = [
      "Find a comfortable seated position, close your eyes, and take a deep, calming breath.",
      "Bring your awareness to your breath. Notice the cool air entering and warm air leaving.",
      "Allow all tension to melt away from your shoulders, neck, and face.",
      "As thoughts arise, acknowledge them gently and let them drift away like clouds.",
      "Rest deeply in this state of peace and inner clarity. You are safe and centered.",
      "Slowly bring your awareness back to the room, wiggle your fingers and toes, and open your eyes."
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
        ),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 64, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Guided Practice Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 15, height: 1.5, color: AppTheme.getDeepSlate(context)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SessionPlayerScreen(
                        title: title,
                        category: subtitle,
                        durationMinutes: 5,
                        steps: defaultSteps,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text('Start Guided Session', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}