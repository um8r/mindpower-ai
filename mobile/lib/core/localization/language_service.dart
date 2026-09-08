import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  // false = English, true = Roman Urdu
  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    notifyListeners();
  }

  // Dictionary for UI Translations
  String get(String key) {
    if (_isUrdu) {
      switch (key) {
        case 'welcome':
          return "Khush Amdeed 👋";
        case 'how_feeling':
          return "Aaj aap kaisa mehsoos kar rahe hain?";
        case 'quick_access':
          return "Fوري رسائی (Quick Access)";
        case 'services':
          return "Mind Power Healing Services";
        case 'healing_audio':
          return "Shifa Bakhsh Awazain";
        case 'progress_log':
          return "Tariqcha & Progress";
        case 'appointment':
          return "Waqt-e-Mulaqat Book Karein";
        default:
          return key;
      }
    } else {
      switch (key) {
        case 'welcome':
          return "Welcome Back 👋";
        case 'how_feeling':
          return "How are you feeling today?";
        case 'quick_access':
          return "Quick Access";
        case 'services':
          return "Mind Power Artists Services";
        case 'healing_audio':
          return "Healing Audio";
        case 'progress_log':
          return "Progress Log";
        case 'appointment':
          return "Book Appointment";
        default:
          return key;
      }
    }
  }
}

// Global instance for simple usage across screens
final languageService = LanguageService();