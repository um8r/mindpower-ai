import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/user_session.dart';
import '../../patient/screens/patient_dashboard_screen.dart';
import '../../therapist/screens/therapist_dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _selectedRole = "patient"; 
  String _selectedSpecialization = "Mind Care Specialist";

  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _specializations = [
    "Mind Care Specialist",
    "Lead Mind Science & Aura Healing Expert",
    "Senior Psychological Counselor",
    "Behavioral Transformation Expert",
  ];

  final String baseUrl = "http://127.0.0.1:8080/api/v1";

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address first.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text.trim().toLowerCase()}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification OTP sent to your email!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP. Please try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP code.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim().toLowerCase(),
          "otp": _otpController.text.trim(),
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _isOtpVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email verified successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid or expired OTP code.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signupUser() async {
    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify your email with OTP first.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim().toLowerCase();
      final fullName = _fullNameController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final response = await http.post(
          Uri.parse("$baseUrl/auth/signup"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "full_name": fullName,
            "email": email,
            "password": password,
            "role": _selectedRole,
            "specialization": _selectedRole == "therapist" ? _selectedSpecialization : "Patient",
          }),
        );

        if (!mounted) return;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final user = data['user'];

          UserSession.email = email;
          UserSession.fullName = fullName;

          if (_selectedRole == 'therapist') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TherapistDashboardScreen(
                  therapistEmail: email,
                  therapistName: fullName,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PatientDashboardScreen(),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup failed. Please try again.")),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection Error: $e")),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFE0F2F1), const Color(0xFFF1F8F6), const Color(0xFFE8F4F8)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(isDark ? 0.9 : 0.94),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(isDark ? 0.05 : 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Create MindPower Account",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDeepSlate(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Register as a Patient or Certified Therapist",
                          style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("Patient")),
                                selected: _selectedRole == "patient",
                                selectedColor: AppTheme.primaryTeal,
                                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: _selectedRole == "patient" ? Colors.white : AppTheme.getDeepSlate(context),
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (selected) {
                                  setState(() => _selectedRole = "patient");
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text("Therapist / Doctor")),
                                selected: _selectedRole == "therapist",
                                selectedColor: AppTheme.primaryTeal,
                                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: _selectedRole == "therapist" ? Colors.white : AppTheme.getDeepSlate(context),
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (selected) {
                                  setState(() => _selectedRole = "therapist");
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _fullNameController,
                          style: TextStyle(color: AppTheme.getDeepSlate(context)),
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryTeal),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _emailController,
                                enabled: !_isOtpVerified,
                                style: TextStyle(color: AppTheme.getDeepSlate(context)),
                                decoration: InputDecoration(
                                  labelText: "Email Address",
                                  labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryTeal),
                                  filled: true,
                                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                ),
                                validator: (value) => value!.isEmpty ? "Enter email" : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isOtpVerified ? Colors.green : AppTheme.primaryTeal,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isOtpVerified ? null : _sendOtp,
                                child: Text(
                                  _isOtpVerified ? "Verified ✓" : (_isOtpSent ? "Resend OTP" : "Send OTP"),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_isOtpSent && !_isOtpVerified) ...[
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                                  decoration: InputDecoration(
                                    labelText: "Enter 6-Digit OTP",
                                    labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                                    prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppTheme.primaryTeal),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  onPressed: _verifyOtp,
                                  child: const Text("Verify", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (_selectedRole == "therapist") ...[
                          DropdownButtonFormField<String>(
                            value: _selectedSpecialization,
                            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                            style: TextStyle(color: AppTheme.getDeepSlate(context)),
                            decoration: InputDecoration(
                              labelText: "Specialization",
                              labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            ),
                            items: _specializations.map((spec) {
                              return DropdownMenuItem(value: spec, child: Text(spec, style: const TextStyle(fontSize: 13)));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSpecialization = val!),
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: AppTheme.getDeepSlate(context)),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primaryTeal),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FBFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          ),
                          validator: (value) => value!.isEmpty ? "Please enter a password" : null,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isLoading ? null : _signupUser,
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Complete Registration", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Already have an account? Sign In",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}