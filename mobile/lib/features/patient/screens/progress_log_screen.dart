import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProgressLogScreen extends StatefulWidget {
  const ProgressLogScreen({Key? key}) : super(key: key);

  @override
  State<ProgressLogScreen> createState() => _ProgressLogScreenState();
}

class _ProgressLogScreenState extends State<ProgressLogScreen> {
  String selectedMood = "😊 Happy";
  final TextEditingController _journalController = TextEditingController();
  final List<String> journalEntries = [];

  final List<String> moods = ["😊 Happy", "😌 Calm", "😔 Sad", "😰 Anxious", "⚡ Energetic"];

  void _saveJournalEntry() {
    if (_journalController.text.trim().isNotEmpty) {
      setState(() {
        journalEntries.insert(0, "$selectedMood: ${_journalController.text.trim()}");
        _journalController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Progress & Journal saved successfully!")),
      );
    }
  }

  Widget _buildBadge(BuildContext context, String title, String subtitle, IconData icon, Color color, bool unlocked) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(isDark ? 0.2 : 0.1) : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: unlocked ? color : Colors.grey, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: unlocked ? AppTheme.getDeepSlate(context) : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: unlocked ? AppTheme.getTextMuted(context) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Progress Log & Journal",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak & Motivation Banner
            Container(
              padding: const EdgeInsets.all(18),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Healing Streak 🔥", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("5 Days Active", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Keep going! Consistency brings inner peace.", style: TextStyle(color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 32),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Mood & Emotion Tracking
            Text(
              "1. Today's Emotional State",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  final isSelected = selectedMood == mood;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMood = mood),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mood,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.getDeepSlate(context),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Mindfulness Journaling Prompt Box
            Text(
              "2. Mindfulness Journaling Prompt",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 4),
            Text(
              "Aaj sab se achi baat kya lagi, ya kis cheez ne stress diya?",
              style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _journalController,
              maxLines: 3,
              style: TextStyle(color: AppTheme.getDeepSlate(context)),
              decoration: InputDecoration(
                hintText: "Write your thoughts here...",
                hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _saveJournalEntry,
                icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                label: const Text("Save Entry", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Weekly & Monthly Analytics Visual Bar Chart representation
            Text(
              "3. Weekly Stress & Energy Analytics",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Stress Level Dropping",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                      ),
                      const Text(
                        "This Week",
                        style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar("Mon", 0.8, Colors.redAccent),
                      _buildBar("Tue", 0.6, Colors.orangeAccent),
                      _buildBar("Wed", 0.5, Colors.orangeAccent),
                      _buildBar("Thu", 0.3, AppTheme.primaryTeal),
                      _buildBar("Fri", 0.2, AppTheme.primaryTeal),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Milestones & Achievements Badges
            Text(
              "4. Achievements & Badges",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBadge(context, "Calm Master", "5 Days Meditation", Icons.psychology_rounded, AppTheme.primaryTeal, true),
                  const SizedBox(width: 12),
                  _buildBadge(context, "Consistency", "Daily Journaling", Icons.local_fire_department_rounded, Colors.orange, true),
                  const SizedBox(width: 12),
                  _buildBadge(context, "Inner Peace", "10 Sessions Done", Icons.self_improvement_rounded, Colors.purple, false),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Past Entries Log List
            Text(
              "5. Past Journal Entries",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
            ),
            const SizedBox(height: 10),
            journalEntries.isEmpty
                ? Text(
                    "No entries yet. Start writing your thoughts above!",
                    style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: journalEntries.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Theme.of(context).cardColor,
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text(
                            journalEntries[index],
                            style: TextStyle(fontSize: 13, color: AppTheme.getDeepSlate(context)),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 90 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}