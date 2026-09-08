import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mindpower_ai/core/theme/app_theme.dart';
import 'package:mindpower_ai/core/models/user_session.dart';
import 'package:mindpower_ai/core/widgets/app_empty_state.dart';
import 'package:mindpower_ai/core/services/notification_service.dart';
import 'package:mindpower_ai/features/auth/screens/login_screen.dart';
import 'package:mindpower_ai/features/patient/screens/book_appointment_screen.dart';
import 'package:mindpower_ai/features/patient/screens/audio_meditation_screen.dart';
import 'ai_chat_screen.dart';
import 'mood_tracker_screen.dart';
import 'breathing_screen.dart';

class ServiceModel {
  final String title;
  final String description;
  final String category;

  ServiceModel({required this.title, required this.description, required this.category});
}

// Direct Therapy Library Screen inside Dashboard file
class DirectTherapyLibraryScreen extends StatelessWidget {
  const DirectTherapyLibraryScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> channelVideos = const [
    {
      "title": "Mind Power Artists Official Playlists & Sessions",
      "description": "Explore all specialized mind science healing, aura cleansing, and subconscious empowerment playlists.",
      "category": "OFFICIAL PLAYLISTS",
      "duration": "Playlist",
      "url": "https://www.youtube.com/@mindpowerartists/playlists",
    },
    {
      "title": "6 Mind Sciences Courses in ONE Membership",
      "description": "6 months access with certificates, LMS user guide, and complete mind science training modules.",
      "category": "MEMBERSHIP & COURSES",
      "duration": "8 mins",
      "url": "https://www.youtube.com/watch?v=6arfMc9Aj4k",
    },
    {
      "title": "5 Techniques for Alpha Frequency Mind Control",
      "description": "Master Alpha brainwave induction for deep mental clarity, subconscious programming, and focus.",
      "category": "MIND CONTROL & FOCUS",
      "duration": "45 mins",
      "url": "https://www.youtube.com/watch?v=3sxdVXIqu7M",
    },
    {
      "title": "Alpha State of Mind - Guided Audio (Lecture 3)",
      "description": "Guided audio session for deep subconscious mind relaxation, meditation, and inner peace.",
      "category": "GUIDED MEDITATION",
      "duration": "4 mins",
      "url": "https://www.youtube.com/watch?v=By_J8vojcKs",
    },
    {
      "title": "Benefits of Wazifa - Spiritual Attunement (Lecture 14)",
      "description": "Spiritual attunement techniques to cleanse inner energy and boost spiritual growth.",
      "category": "SPIRITUAL CALM",
      "duration": "7 mins",
      "url": "https://www.youtube.com/watch?v=pU80BEm43JM",
    },
    {
      "title": "Live Aura Energy Analysis By Sufi Awaisi",
      "description": "Watch live energy readings and expert aura cleansing sessions by Sufi Awaisi.",
      "category": "ENERGY HEALING",
      "duration": "4 mins",
      "url": "https://www.youtube.com/watch?v=4vpQNYthrIc",
    },
    {
      "title": "How to Manifest Your Ideal Life Partner",
      "description": "Unlock the power of your subconscious mind and law of attraction secrets to attract positive relationships.",
      "category": "RELATIONSHIP HEALING",
      "duration": "45 mins",
      "url": "https://www.youtube.com/watch?v=AhEmlNKj_Ck",
    },
  ];

  Future<void> openVideoUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mind Power Therapy Library",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? constraints.maxWidth * 0.15 : 16.0,
              vertical: isDesktop ? 30.0 : 16.0,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: channelVideos.length,
              itemBuilder: (context, index) {
                final item = channelVideos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Theme.of(context).cardColor,
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['category']!,
                                style: const TextStyle(
                                  color: AppTheme.primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              item['duration']!,
                              style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title']!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDeepSlate(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['description']!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.getTextMuted(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => openVideoUrl(item['url']!),
                            icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              "Watch on YouTube",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Inline Progress Log Screen
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
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== PATIENT DASHBOARD SCREEN ====================
class PatientDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const PatientDashboardScreen({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  String selectedMood = "Happy";
  List<dynamic> _notifications = [];
  bool _isLoadingNotifications = false;

  final List<ServiceModel> services = [
    ServiceModel(title: "Aura Cleansing", description: "Restore positive energy flow through deep aura healing therapy.", category: "Energy Healing"),
    ServiceModel(title: "Behavioral Transformation", description: "Shift your mindset and create lasting positive behavioral change.", category: "Mindset"),
    ServiceModel(title: "Relationship Healing", description: "Strengthen emotional bonds and build harmony through therapy.", category: "Emotional"),
    ServiceModel(title: "Disease Healing", description: "Activate your inner power to support mind body healing.", category: "Holistic Health"),
    ServiceModel(title: "Hypno Therapy", description: "Access your subconscious mind to release stress and anxiety.", category: "Therapy"),
    ServiceModel(title: "Business Boost Service", description: "Boost focus confidence and leadership with mind power.", category: "Business"),
    ServiceModel(title: "Consultation with Sufi Awaisi", description: "Avail personal customized guidance for your problems.", category: "Consultation"),
    ServiceModel(title: "Hormonal Imbalance Treatment", description: "Remote mind power healing regulates your hormones & enzymes and heals hormonal disbalance.", category: "Medical Mind Care"),
    ServiceModel(title: "Remote Psychological Healing", description: "Psychological problems are healed with remote mind programing.", category: "Psychology"),
    ServiceModel(title: "Fertility Enhancement", description: "Inner energy healing of reproductive system boosts fertility and increases the probability of conceiving.", category: "Specialized Care"),
    ServiceModel(title: "Business & Luck Boost", description: "Sales are increased by Energy Boosting & Telepathic Marketing.", category: "Business Growth"),
    ServiceModel(title: "Daily Mind Strengthening", description: "Avail remote energy cleansing and mind boosting sessions for better mind performance.", category: "Daily Wellness"),
    ServiceModel(title: "Psychological Counseling", description: "Connect with a professional Psychologist for emotional management to respond better towards life challenges.", category: "Counseling"),
    ServiceModel(title: "Skin & Hair Enhancement", description: "Remote mind power healing cures skin problems, stops hair fall and enhances skin & hair health.", category: "Aesthetic Care"),
    ServiceModel(title: "Rohani Tawajo", description: "Get daily spiritual boost and ruhani tawajoh from Sufi Awaisi to boost inner awakening and spiritual growth.", category: "Spiritual"),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPatientNotifications();
  }

  Future<void> _fetchPatientNotifications() async {
    final email = UserSession.email;
    if (email.isEmpty) return;

    setState(() {
      _isLoadingNotifications = true;
    });

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8080/api/v1/notifications/$email"),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifications = data['notifications'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _sendReplyToTherapist(String therapistEmail, String replyMessage) async {
    if (replyMessage.trim().isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/v1/notifications/reply"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "patient_email": UserSession.email,
          "patient_name": UserSession.fullName.isNotEmpty ? UserSession.fullName : "Umar Habib",
          "therapist_email": therapistEmail,
          "reply_message": replyMessage,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message successfully sent to the doctor!")),
        );
        _fetchPatientNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send message.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _openVideoCall(String videoUrl) async {
    final Uri uri = Uri.parse(videoUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleLogout() async {
    await UserSession.clearSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showSafetyAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.shield_rounded, color: Color(0xFFE65100), size: 26),
              const SizedBox(width: 8),
              Text(
                "Emergency & Safety Support",
                style: TextStyle(color: AppTheme.getDeepSlate(context), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We at Mindpower Artists understand that sometimes life feels too heavy. You don’t have to face it alone. Reach out immediately for expert guidance and crisis healing.\n",
                style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
              ),
              const Text("📞 Phone: +92 3103 338452 / 53", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              const SizedBox(height: 6),
              Text("📧 Email: info@mindpowerartists.com", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
              const SizedBox(height: 6),
              const Text("📍 Address: Lower Ground Floor The Plazzo, Below Askari Bank, Gulberg Greens, Islamabad", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context, String serviceName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Get Service: $serviceName",
            style: TextStyle(color: AppTheme.getDeepSlate(context), fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "We at Mindpower Artists are always here to guide, heal, and support you. Reach out today for mind healing, aura cleansing, and personalised mind science consultation.\n",
                style: TextStyle(color: AppTheme.getTextMuted(context)),
              ),
              const Text("📞 Phone: +92 3103 338452/53", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              const SizedBox(height: 6),
              Text("📧 Email: info@mindpowerartists.com", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
              const SizedBox(height: 6),
              const Text("📍 Address: Lower Ground Floor The Plazzo, Below Askari Bank, Gulberg Greens, Islamabad", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: AppTheme.primaryTeal)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodCard(BuildContext context, String emoji, String label) {
    final bool isSelected = selectedMood == label;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryTeal : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.primaryTeal.withOpacity(0.3) : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.getDeepSlate(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlamCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color themeColor,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: themeColor.withOpacity(0.2),
                    child: Center(
                      child: Icon(icon, color: themeColor, size: 40),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.85),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
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
                  // 🔔 Therapist Messages Section with Empty State Integration
                  if (_isLoadingNotifications)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(color: AppTheme.primaryTeal)))
                  else if (_notifications.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const AppEmptyState(
                        icon: Icons.notifications_off_rounded,
                        title: "No Therapist Messages",
                        subtitle: "You don't have any active notifications or messages from doctors right now.",
                      ),
                    )
                  else ...[
                    Text(
                      "Therapist Messages & Live Sessions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                    ),
                    const SizedBox(height: 8),
                    ..._notifications.map((notif) {
                      final title = notif['title'] ?? 'Update';
                      final message = notif['message'] ?? '';
                      final doctorName = notif['therapist_name'] ?? 'Dr. Sufi Awaisi';
                      final therapistEmail = notif['therapist_email'] ?? 'drsufiawaisi@mindpower.com';
                      final videoLink = notif['video_link'];
                      final TextEditingController chatController = TextEditingController();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        color: Theme.of(context).cardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppTheme.primaryTeal,
                                      child: Icon(Icons.person_rounded, color: Colors.white, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctorName,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            "Lead Mind Science & Aura Healing Expert",
                                            style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            therapistEmail,
                                            style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context), fontSize: 13)),
                                  Text(notif['timestamp'] ?? '', style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(message, style: TextStyle(fontSize: 13, color: AppTheme.getDeepSlate(context))),
                              
                              if (videoLink != null && videoLink.toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _openVideoCall(videoLink),
                                    icon: const Icon(Icons.video_call_rounded, color: Colors.white),
                                    label: const Text("Join Live Video Therapy Session", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],

                              if (therapistEmail.isNotEmpty) ...[
                                const Divider(height: 20),
                                Text("Send message to doctor:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: chatController,
                                  maxLines: 2,
                                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                                  decoration: InputDecoration(
                                    hintText: "Type your message or query here...",
                                    hintStyle: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryTeal,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      _sendReplyToTherapist(therapistEmail, chatController.text);
                                      chatController.clear();
                                    },
                                    icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                                    label: const Text("Send Message", style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryTeal, AppTheme.primaryDarkTeal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTeal.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  radius: 18,
                                  child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  UserSession.fullName.isNotEmpty ? "Welcome Back, ${UserSession.fullName} 👋" : "Welcome Back 👋",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        "5 Days",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 22),
                                  onPressed: _handleLogout,
                                  tooltip: "Logout",
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "\"Your mind is your greatest strength.\"",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryTeal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () async {
                              await NotificationService.showNotification(
                                id: 1,
                                title: "🧠 Alpha State Reminder",
                                body: "Waqt ho gaya hai apne andar positive energy aur alpha frequencies absorb karne ka!",
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Daily Alpha Reminder scheduled successfully!")),
                              );
                            },
                            icon: const Icon(Icons.notifications_active_rounded, size: 18),
                            label: const Text("Set Daily Alpha Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    "How are you feeling today?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getDeepSlate(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMoodCard(context, '😊', 'Happy'),
                      _buildMoodCard(context, '😌', 'Calm'),
                      _buildMoodCard(context, '😔', 'Sad'),
                      _buildMoodCard(context, '😰', 'Anxious'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Quick Access",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getDeepSlate(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: isDesktop ? 3 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _buildGlamCard(
                        title: "AI Therapy",
                        subtitle: "Virtual Counselor",
                        icon: Icons.psychology_rounded,
                        themeColor: AppTheme.primaryTeal,
                        imageUrl: "https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AIChatScreen()),
                          );
                        },
                      ),
                      // Mood Tracker Card Added Safely
                      _buildGlamCard(
                        title: "Mood Tracker",
                        subtitle: "Log & Analytics",
                        icon: Icons.show_chart_rounded,
                        themeColor: Colors.blue.shade700,
                        imageUrl: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
                          );
                        },
                      ),
                      // Breathing Room Card Added Safely
                      _buildGlamCard(
                        title: "Breathing Room",
                        subtitle: "Mindful Exercises",
                        icon: Icons.self_improvement_rounded,
                        themeColor: Colors.orange.shade700,
                        imageUrl: "https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BreathingScreen()),
                          );
                        },
                      ),
                      _buildGlamCard(
                        title: "Therapy Library",
                        subtitle: "Mindful Sessions",
                        icon: Icons.play_circle_fill_rounded,
                        themeColor: const Color(0xFF0288D1),
                        imageUrl: "https://images.unsplash.com/photo-1544717305-2782549b5136?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DirectTherapyLibraryScreen()),
                          );
                        },
                      ),
                      _buildGlamCard(
                        title: "Healing Audio",
                        subtitle: "Alpha & Binaural Beats",
                        icon: Icons.headphones_rounded,
                        themeColor: const Color(0xFF00796B),
                        imageUrl: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AudioMeditationScreen()),
                          );
                        },
                      ),
                      _buildGlamCard(
                        title: "Safety Alerts",
                        subtitle: "Clinical Support",
                        icon: Icons.shield_rounded,
                        themeColor: const Color(0xFFE65100),
                        imageUrl: "https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=500&auto=format&fit=crop",
                        onTap: () {
                          _showSafetyAlertDialog(context);
                        },
                      ),
                      _buildGlamCard(
                        title: "Progress Log",
                        subtitle: "Mindfulness Journal",
                        icon: Icons.insert_chart_rounded,
                        themeColor: const Color(0xFF7B1FA2),
                        imageUrl: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProgressLogScreen()),
                          );
                        },
                      ),
                      _buildGlamCard(
                        title: "Book Appointment",
                        subtitle: "Schedule Session",
                        icon: Icons.event_available_rounded,
                        themeColor: const Color(0xFF2E7D32),
                        imageUrl: "https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=500&auto=format&fit=crop",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Mind Power Artists Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getDeepSlate(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Explore our specialized healing and consultation sessions",
                    style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Theme.of(context).cardColor,
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      service.title,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryTeal.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      service.category,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service.description,
                                style: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
                              ),
                              const SizedBox(height: 14),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showContactDialog(context, service.title),
                                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Colors.white),
                                  label: const Text("Get Service / Contact", style: TextStyle(fontSize: 12, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryTeal,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}