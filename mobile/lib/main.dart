import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/models/user_session.dart';
import 'features/auth/screens/welcome_intro_screen.dart';
import 'features/patient/screens/patient_dashboard_screen.dart';
import 'features/therapist/screens/therapist_dashboard_screen.dart';

// Global Theme Notifier for handling Light/Dark mode dynamically across the app
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void setTheme(ThemeMode mode) {
    value = mode;
  }
}

final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if a saved session exists locally
  bool isLoggedIn = await UserSession.loadSession();
  
  runApp(MindPowerApp(isLoggedIn: isLoggedIn));
}

class MindPowerApp extends StatelessWidget {
  final bool isLoggedIn;

  const MindPowerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Determine initial screen based on session state and user role
    Widget initialScreen;
    if (isLoggedIn) {
      if (UserSession.role == 'therapist') {
        initialScreen = TherapistDashboardScreen(
          therapistEmail: UserSession.email,
          therapistName: UserSession.fullName,
        );
      } else {
        initialScreen = const PatientDashboardScreen();
      }
    } else {
      initialScreen = const WelcomeIntroScreen();
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'MindPower AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: initialScreen,
        );
      },
    );
  }
}