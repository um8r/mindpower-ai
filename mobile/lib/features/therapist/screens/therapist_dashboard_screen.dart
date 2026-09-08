import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../auth/screens/login_screen.dart';

class TherapistDashboardScreen extends StatefulWidget {
  final String therapistEmail;
  final String therapistName;

  const TherapistDashboardScreen({
    Key? key,
    this.therapistEmail = "drsufiawaisi@mindpower.com",
    this.therapistName = "Dr. Sufi Awaisi",
  }) : super(key: key);

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  int _currentIndex = 0;

  // Therapist Profile Controllers
  late final TextEditingController _nameController = TextEditingController(text: widget.therapistName);
  final TextEditingController _titleController = TextEditingController(text: "Lead Mind Science & Aura Healing Expert");
  final TextEditingController _bioController = TextEditingController(text: "Specialized in remote energy cleansing, alpha brainwave induction, and subconscious psychological transformation with over 10 years of clinical experience.");
  final TextEditingController _feeController = TextEditingController(text: "PKR 5,000 / Session");
  final TextEditingController _imageUrlController = TextEditingController(text: "https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=500&auto=format&fit=crop");
  
  bool _isEditingProfile = false;
  bool _isLoadingData = false;

  List<dynamic> _realPatientsList = [];
  List<dynamic> _patientRepliesList = [];
  List<dynamic> _patientRisksList = [];

  @override
  void initState() {
    super.initState();
    _fetchTherapistData();
  }

  Future<void> _fetchTherapistData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final patResponse = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/therapist/patients/${widget.therapistEmail}"));
      if (patResponse.statusCode == 200) {
        final data = jsonDecode(patResponse.body);
        _realPatientsList = data['patients'] ?? [];
      }

      final msgResponse = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/therapist/messages/${widget.therapistEmail}"));
      if (msgResponse.statusCode == 200) {
        final data = jsonDecode(msgResponse.body);
        _patientRepliesList = data['messages'] ?? [];
      }

      // Fetch AI Patient Sentiment & Crisis Risk Analysis
      final riskResponse = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/therapist/patient-risk-analysis/${widget.therapistEmail}"));
      if (riskResponse.statusCode == 200) {
        final data = jsonDecode(riskResponse.body);
        _patientRisksList = data['patients_risk'] ?? [];
      }
    } catch (e) {
      debugPrint("Fetch Therapist Data Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  // --- FREE OPEN-SOURCE JITSI VIDEO SESSION LAUNCHER ---
  Future<void> _startLiveVideoSession(String patientEmail, String patientName) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/v1/therapist/start-video-session"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "therapist_name": _nameController.text,
          "therapist_email": widget.therapistEmail,
          "patient_email": patientEmail,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videoLink = data['video_link'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🔴 Live video session started and link sent to $patientName!")),
        );

        final Uri uri = Uri.parse(videoLink);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to start video session.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // --- SOAP SESSION NOTES DIALOG ---
  void _showSessionNotesDialog(String patientEmail, String patientName) {
    final TextEditingController symptomsController = TextEditingController();
    final TextEditingController diagnosisController = TextEditingController();
    final TextEditingController planController = TextEditingController();
    List<dynamic> pastNotes = [];
    bool isLoadingNotes = true;

    Future<void> fetchNotes(StateSetter setStateModal) async {
      try {
        final res = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/therapist/notes/${widget.therapistEmail}/$patientEmail"));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setStateModal(() {
            pastNotes = data['notes'] ?? [];
            isLoadingNotes = false;
          });
        }
      } catch (_) {
        setStateModal(() => isLoadingNotes = false);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateModal) {
          if (isLoadingNotes) {
            fetchNotes(setStateModal);
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text("SOAP Notes: $patientName", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
            content: SizedBox(
              width: 500,
              height: 450,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add New Clinical Note", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: symptomsController,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: const InputDecoration(labelText: "Symptoms / Observations", border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: diagnosisController,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: const InputDecoration(labelText: "Diagnosis", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: planController,
                      style: TextStyle(color: AppTheme.getDeepSlate(context)),
                      decoration: const InputDecoration(labelText: "Treatment Plan", border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                        onPressed: () async {
                          if (symptomsController.text.trim().isEmpty) return;
                          await http.post(
                            Uri.parse("http://127.0.0.1:8080/api/v1/therapist/notes/save"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({
                              "therapist_email": widget.therapistEmail,
                              "patient_email": patientEmail,
                              "symptoms": symptomsController.text,
                              "diagnosis": diagnosisController.text,
                              "treatment_plan": planController.text,
                            }),
                          );
                          symptomsController.clear();
                          diagnosisController.clear();
                          planController.clear();
                          fetchNotes(setStateModal);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Clinical notes saved!")));
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Save Clinical Note", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const Divider(height: 30),
                    const Text("Past Session History", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    isLoadingNotes
                        ? const Center(child: CircularProgressIndicator())
                        : pastNotes.isEmpty
                            ? const Text("No prior notes recorded.", style: TextStyle(color: Colors.grey, fontSize: 12))
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pastNotes.length,
                                itemBuilder: (context, index) {
                                  final n = pastNotes[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("📅 ${n['timestamp']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                          Text("Symptoms: ${n['symptoms']}", style: const TextStyle(fontSize: 12)),
                                          Text("Diagnosis: ${n['diagnosis']}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          Text("Plan: ${n['treatment_plan']}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          );
        },
      ),
    );
  }

  // --- 💬 THERAPIST TO PATIENT DIRECT MESSAGE / NOTIFICATION DIALOG ---
  void _showSendMessageDialog(String patientEmail, String patientName) {
    final TextEditingController messageController = TextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Send Message to $patientName",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("To: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
              Text(patientEmail, style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context))),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                style: TextStyle(color: AppTheme.getDeepSlate(context)),
                decoration: InputDecoration(
                  hintText: "Type guidance, session note or reminder...",
                  hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _sendCustomMessageToPatient(patientEmail, messageController.text);
            },
            icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
            label: const Text("Send Notification", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendCustomMessageToPatient(String patientEmail, String messageText) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/v1/therapist/reply-patient"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "therapist_name": _nameController.text,
          "therapist_email": widget.therapistEmail,
          "patient_email": patientEmail,
          "reply_message": messageText,
        }),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message successfully sent to patient's dashboard!")),
        );
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

  void _saveProfile() {
    setState(() {
      _isEditingProfile = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Therapist Profile & Picture updated successfully!")),
    );
  }

  void _showChangeImageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Change Profile Picture", style: TextStyle(color: AppTheme.getDeepSlate(context))),
        content: TextField(
          controller: _imageUrlController,
          style: TextStyle(color: AppTheme.getDeepSlate(context)),
          decoration: InputDecoration(
            labelText: "Enter Image URL (Unsplash / Network Image)",
            labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile picture updated!")));
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      _buildAppointmentsTab(),
      _buildPatientsTab(),
      _buildPatientMessagesTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Therapist Management Portal",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryTeal),
            onPressed: _fetchTherapistData,
            tooltip: "Refresh Data",
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 900 : double.infinity),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 30.0 : 16.0,
                    vertical: isDesktop ? 20.0 : 12.0,
                  ),
                  child: screens[_currentIndex],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryTeal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).cardColor,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_rounded),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: "Patients",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: "Patient Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "My Profile",
          ),
        ],
      ),
    );
  }

  // Tab 1: Appointments & Live Video / Messaging Options with AI Crisis Risk Analyzer
  Widget _buildAppointmentsTab() {
    return ListView(
      children: [
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
            children: [
              const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome Back, Doctor", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_nameController.text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // --- NEW FEATURE: AI Patient Sentiment & Crisis Risk Analyzer ---
        Row(
          children: const [
            Icon(Icons.psychology_rounded, color: AppTheme.primaryTeal, size: 22),
            SizedBox(width: 8),
            Text(
              "AI Patient Sentiment & Crisis Risk Analyzer",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _patientRisksList.isEmpty
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const Text("No patient emotional logs or sentiment records found yet.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _patientRisksList.length,
                itemBuilder: (context, index) {
                  final p = _patientRisksList[index];
                  Color badgeColor = p['badge_color'] == 'red'
                      ? Colors.red
                      : p['badge_color'] == 'orange'
                          ? Colors.orange
                          : Colors.green;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(p['patient_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: badgeColor),
                                ),
                                child: Text(
                                  p['risk_level'],
                                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Email: ${p['patient_email']}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "🤖 AI Summary: ${p['ai_summary']}",
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 24),
        Text(
          "Booked Patients & Live Sessions",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
        ),
        const SizedBox(height: 12),
        _isLoadingData
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
            : _realPatientsList.isEmpty
                ? const AppEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: "No Appointments Found",
                    subtitle: "There are no booked patient appointment requests at the moment.",
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _realPatientsList.length,
                    itemBuilder: (context, index) {
                      final appt = _realPatientsList[index];
                      final pName = appt['patient_name'] ?? 'Patient';
                      final pEmail = appt['patient_email'] ?? '';
                      final apptDate = appt['appointment_date'] ?? 'Upcoming';
                      final status = appt['status'] ?? 'Pending';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
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
                                  Text(
                                    pName,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.getDeepSlate(context)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: status == 'Confirmed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: status == 'Confirmed' ? Colors.green : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("Email: $pEmail", style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text("Date: $apptDate", style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context))),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppTheme.primaryTeal),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _showSendMessageDialog(pEmail, pName),
                                      icon: const Icon(Icons.message_rounded, color: AppTheme.primaryTeal, size: 18),
                                      label: const Text("Send Msg", style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _showSessionNotesDialog(pEmail, pName),
                                      icon: const Icon(Icons.note_alt_rounded, color: Colors.white, size: 18),
                                      label: const Text("SOAP Notes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _startLiveVideoSession(pEmail, pName),
                                      icon: const Icon(Icons.video_call_rounded, color: Colors.white, size: 18),
                                      label: const Text("Live Video", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  // Tab 2: Registered Patients Directory
  Widget _buildPatientsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Registered Patients Directory",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
        ),
        const SizedBox(height: 4),
        Text("View active patients, send messages or initiate video consultations.", style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context))),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: [
              Card(
                color: Theme.of(context).cardColor,
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Umar Habib",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                      ),
                      const SizedBox(height: 4),
                      const Text("umarhab8b231@gmail.com", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryTeal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => _showSendMessageDialog("umarhab8b231@gmail.com", "Umar Habib"),
                              icon: const Icon(Icons.message_rounded, size: 16, color: AppTheme.primaryTeal),
                              label: const Text("Send Message", style: TextStyle(color: AppTheme.primaryTeal)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                              onPressed: () => _startLiveVideoSession("umarhab8b231@gmail.com", "Umar Habib"),
                              icon: const Icon(Icons.video_call_rounded, color: Colors.white, size: 16),
                              label: const Text("Video Call", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tab 3: Patient Messages & Replies Viewer
  Widget _buildPatientMessagesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Patient Replies & Inquiries",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
        ),
        const SizedBox(height: 4),
        Text("Messages sent back by patients regarding their therapy sessions.", style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context))),
        const SizedBox(height: 16),
        Expanded(
          child: _patientRepliesList.isEmpty
              ? const AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "No Patient Replies",
                  subtitle: "No patient inquiries or messages received yet.",
                )
              : ListView.builder(
                  itemCount: _patientRepliesList.length,
                  itemBuilder: (context, index) {
                    final msg = _patientRepliesList[index];
                    final pName = msg['patient_name'] ?? 'Patient';
                    final pEmail = msg['patient_email'] ?? '';
                    final message = msg['message'] ?? '';
                    final TextEditingController replyController = TextEditingController();
                    final bool isDark = Theme.of(context).brightness == Brightness.dark;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
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
                                Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryTeal)),
                                Text(msg['timestamp'] ?? '', style: TextStyle(fontSize: 10, color: AppTheme.getTextMuted(context))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text("Email: $pEmail", style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context))),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(message, style: TextStyle(fontSize: 13, color: AppTheme.getDeepSlate(context))),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: replyController,
                              maxLines: 2,
                              style: TextStyle(color: AppTheme.getDeepSlate(context)),
                              decoration: InputDecoration(
                                hintText: "Type response to patient...",
                                hintStyle: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                onPressed: () {
                                  _sendCustomMessageToPatient(pEmail, replyController.text);
                                  replyController.clear();
                                },
                                child: const Text("Send Response", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Tab 4: Therapist Profile
  Widget _buildProfileTab() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _showChangeImageDialog,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_imageUrlController.text),
                  onBackgroundImageError: (_, __) {},
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppTheme.primaryTeal, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text("Tap picture to change profile photo", style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 16),
          Text(_nameController.text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context))),
          Text(_titleController.text, style: const TextStyle(fontSize: 13, color: AppTheme.primaryTeal)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Professional Details & Bio",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                    ),
                    IconButton(
                      icon: Icon(_isEditingProfile ? Icons.check_rounded : Icons.edit_rounded, color: AppTheme.primaryTeal),
                      onPressed: () {
                        if (_isEditingProfile) {
                          _saveProfile();
                        } else {
                          setState(() {
                            _isEditingProfile = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameController,
                  enabled: _isEditingProfile,
                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                  decoration: InputDecoration(
                    labelText: "Full Name & Title",
                    labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  enabled: _isEditingProfile,
                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                  decoration: InputDecoration(
                    labelText: "Specialization",
                    labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feeController,
                  enabled: _isEditingProfile,
                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                  decoration: InputDecoration(
                    labelText: "Consultation Fee",
                    labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioController,
                  enabled: _isEditingProfile,
                  maxLines: 3,
                  style: TextStyle(color: AppTheme.getDeepSlate(context)),
                  decoration: InputDecoration(
                    labelText: "Bio / About Therapist",
                    labelStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                ),
                if (_isEditingProfile) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                      onPressed: _saveProfile,
                      child: const Text("Save Profile Changes", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}