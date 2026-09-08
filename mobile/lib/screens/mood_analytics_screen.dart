import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';

class MoodAnalyticsScreen extends StatefulWidget {
  const MoodAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<MoodAnalyticsScreen> createState() => _MoodAnalyticsScreenState();
}

class _MoodAnalyticsScreenState extends State<MoodAnalyticsScreen> {
  // Weekly Mood History (1: Sad/Anxious, 2: Neutral, 3: Calm, 4: Happy, 5: Ecstatic/Energetic)
  final List<FlSpot> weeklyMoodSpots = const [
    FlSpot(1, 2.0), // Mon
    FlSpot(2, 3.0), // Tue
    FlSpot(3, 2.5), // Wed
    FlSpot(4, 4.0), // Thu
    FlSpot(5, 3.5), // Fri
    FlSpot(6, 4.5), // Sat
    FlSpot(7, 5.0), // Sun
  ];

  final List<Map<String, String>> recentLogs = [
    {"day": "Sunday", "mood": "😊 Happy", "note": "Felt deeply relaxed after alpha breathing sessions."},
    {"day": "Saturday", "mood": "😌 Calm", "note": "Managed work stress successfully using mindfulness."},
    {"day": "Friday", "mood": "⚡ Energetic", "note": "High focus during morning mind science lecture."},
    {"day": "Thursday", "mood": "😊 Happy", "note": "Great aura healing results observed."},
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mood Analytics & Progress",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? constraints.maxWidth * 0.15 : 20.0,
              vertical: isDesktop ? 30.0 : 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryTeal, AppTheme.primaryDarkTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Weekly Mental Health Status 📊", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          SizedBox(height: 4),
                          Text("Steady Positive Growth", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Your emotional resilience has improved by 25% this week.", style: TextStyle(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                      const Icon(Icons.insights_rounded, color: Colors.white, size: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Weekly Mood Trend (Last 7 Days)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                ),
                const SizedBox(height: 14),

                // Line Chart Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalValue: (value) => 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 1:
                                        return Text("Sad", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 3:
                                        return Text("Calm", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 5:
                                        return Text("Happy", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    switch (value.toInt()) {
                                      case 1:
                                        return Text("Mon", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 2:
                                        return Text("Tue", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 3:
                                        return Text("Wed", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 4:
                                        return Text("Thu", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 5:
                                        return Text("Fri", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 6:
                                        return Text("Sat", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                      case 7:
                                        return Text("Sun", style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)));
                                    }
                                    return const Text("");
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 1,
                            maxX: 7,
                            minY: 1,
                            maxY: 5,
                            lineBarsData: [
                              LineChartBarData(
                                spots: weeklyMoodSpots,
                                isCurved: true,
                                color: AppTheme.primaryTeal,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.primaryTeal.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Recent Journal Notes & Emotional Logs",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentLogs.length,
                  itemBuilder: (context, index) {
                    final log = recentLogs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Theme.of(context).cardColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                          child: const Icon(Icons.mood_rounded, color: AppTheme.primaryTeal),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(log['day']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.getDeepSlate(context))),
                            Text(log['mood']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryTeal)),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(log['note']!, style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context))),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}