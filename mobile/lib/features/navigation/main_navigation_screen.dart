import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../patient/screens/patient_dashboard_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../mood_tracker_screen.dart'; // Apne folder path ke mutabiq adjust kar lein agar zaroorat ho
import '../breathing_screen.dart';   // Apne folder path ke mutabiq adjust kar lein agar zaroorat ho

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PatientDashboardScreen(onNavigate: _onTabTapped),
      const AIChatScreen(),
      const MoodTrackerScreen(),
      const BreathingScreen(),
      const Center(child: Text("Safety Alerts")),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: "AI Therapy",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            label: "Moods",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_rounded),
            label: "Breathe",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            label: "Alerts",
          ),
        ],
      ),
    );
  }
}