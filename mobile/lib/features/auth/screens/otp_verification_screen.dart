import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../navigation/main_navigation_screen.dart';
import '../../therapist/screens/therapist_dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;
  final String role;

  const OtpVerificationScreen({
    Key? key,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRegister() async {
    String enteredOtp = _controllers.map((c) => c.text).join();

    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Baraye meharbani mukammal 6-digit OTP enter karein.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final List<String> endpoints = [
      "http://127.0.0.1:8000/api/v1/auth/verify-otp",
      "http://localhost:8000/api/v1/auth/verify-otp",
      "http://127.0.0.1:8080/api/v1/auth/verify-otp",
      "http://localhost:8080/api/v1/auth/verify-otp"
    ];

    bool isVerified = false;

    // Step 1: Verify OTP from Backend
    for (String urlStr in endpoints) {
      try {
        final response = await http.post(
          Uri.parse(urlStr),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": widget.email,
            "otp": enteredOtp,
          }),
        );

        if (response.statusCode == 200) {
          isVerified = true;
          break;
        }
      } catch (e) {
        debugPrint("Verify OTP Error ($urlStr): $e");
      }
    }

    if (!isVerified) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ghalat ya expired OTP hai! Dobara koshish karein.")),
      );
      return;
    }

    // Step 2: If OTP is verified, register the user to backend database/system
    final List<String> signupEndpoints = [
      "http://127.0.0.1:8000/api/v1/auth/signup",
      "http://localhost:8000/api/v1/auth/signup",
      "http://127.0.0.1:8080/api/v1/auth/signup",
      "http://localhost:8080/api/v1/auth/signup"
    ];

    for (String urlStr in signupEndpoints) {
      try {
        await http.post(
          Uri.parse(urlStr),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "full_name": widget.fullName,
            "email": widget.email,
            "password": widget.password,
            "role": widget.role.toLowerCase(),
          }),
        );
      } catch (e) {
        debugPrint("Final Signup Error: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Step 3: Redirect based on Role (Patient vs Therapist)
      if (widget.role.toLowerCase() == "therapist") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TherapistDashboardScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Email OTP Verification",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_unread_rounded, size: 48, color: AppTheme.primaryTeal),
            ),
            const SizedBox(height: 20),
            Text(
              "Verification Code Enter Karein",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Hum ne aap ki email (${widget.email}) par 6-digit ka OTP code bhej diya hai.",
              style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLoading ? null : _verifyAndRegister,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Verify & Complete Registration",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}