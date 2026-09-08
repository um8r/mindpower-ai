import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';

class SafetyAlertsScreen extends StatefulWidget {
  const SafetyAlertsScreen({Key? key}) : super(key: key);

  @override
  State<SafetyAlertsScreen> createState() => _SafetyAlertsScreenState();
}

class _SafetyAlertsScreenState extends State<SafetyAlertsScreen> {
  List<dynamic> alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSafetyAlerts();
  }

  Future<void> _fetchSafetyAlerts() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/safety-alerts"));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          alerts = data['alerts'] ?? data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching safety alerts: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Safety Alerts",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : alerts.isEmpty
              ? Center(
                  child: Text(
                    "No safety alerts recorded.",
                    style: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Theme.of(context).cardColor,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "HIGH RISK ALERT",
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  alert['timestamp'] ?? 'Just now',
                                  style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'User Prompt:',
                              style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alert['user_message'] ?? alert['prompt'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context), fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Automated AI Response:',
                              style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              alert['bot_response'] ?? alert['response'] ?? '',
                              style: TextStyle(color: AppTheme.getDeepSlate(context), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}