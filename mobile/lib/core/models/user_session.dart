import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSession {
  static const _storage = FlutterSecureStorage();
  
  static String email = "";
  static String fullName = "";
  static String role = "patient";

  static Future<void> saveSession(String userEmail, String name, String userRole) async {
    email = userEmail;
    fullName = name;
    role = userRole;
    
    await _storage.write(key: 'email', value: userEmail);
    await _storage.write(key: 'full_name', value: name);
    await _storage.write(key: 'role', value: userRole);
  }

  static Future<bool> loadSession() async {
    final savedEmail = await _storage.read(key: 'email');
    final savedName = await _storage.read(key: 'full_name');
    final savedRole = await _storage.read(key: 'role');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      email = savedEmail;
      fullName = savedName ?? "User";
      role = savedRole ?? "patient";
      return true;
    }
    return false;
  }

  static Future<void> clearSession() async {
    email = "";
    fullName = "";
    role = "patient";
    await _storage.deleteAll();
  }
}