import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:mindpower_ai/core/theme/app_theme.dart';
import 'package:mindpower_ai/core/models/user_session.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<Map<String, dynamic>> _moodHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMoodHistory();
  }

  Future<void> _fetchMoodHistory() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/mood/history/${UserSession.email}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _moodHistory = List<Map<String, dynamic>>.from(data['moods']);
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logMood(int score, String name) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/v1/mood/log"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": UserSession.email,
          "mood_score": score,
          "mood_name": name,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mood '$name' logged successfully!")));
        _fetchMoodHistory();
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to log mood.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Mood Tracker & Analytics")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How are you feeling right now?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodButton(4, "Happy 😊", Colors.green),
                _buildMoodButton(3, "Calm 😌", Colors.teal),
                _buildMoodButton(2, "Stressed 😔", Colors.orange),
                _buildMoodButton(1, "Anxious 😰", Colors.red),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Your Emotional Progress Graph", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _moodHistory.isEmpty
                      ? const Center(child: Text("No mood logs yet. Select above to start tracking!"))
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            minY: 1,
                            maxY: 4,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _moodHistory.asMap().entries.map((e) {
                                  return FlSpot(e.key.toDouble(), (e.value['score'] as int).toDouble());
                                }).toList(),
                                isCurved: true,
                                color: AppTheme.primaryTeal,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(int score, String name, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
      onPressed: () => _logMood(score, name),
      child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}