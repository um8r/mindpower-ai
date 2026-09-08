import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentThemeMode;

  const SettingsScreen({
    Key? key,
    required this.onThemeChanged,
    required this.currentThemeMode,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = "Roman Urdu / English";
  bool _soundEffects = true;
  bool _haptics = true;
  bool _moodReminders = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

  // Audio player controller for background ambient meditation sound
  late final AudioPlayer _audioPlayer;
  bool _ambientAudioPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioAsset();
  }

  Future<void> _initAudioAsset() async {
    try {
      await _audioPlayer.setAsset('assets/ambient.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e) {
      debugPrint("Error loading ambient audio asset: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAmbientAudio(bool value) async {
    setState(() {
      _ambientAudioPlaying = value;
    });
    try {
      if (value) {
        await _audioPlayer.play();
      } else {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint("Error playing/stopping audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App Settings",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.getDeepSlate(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Theme & Appearance
          _buildSectionHeader("Appearance & Theme"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text("System Default"),
                  value: ThemeMode.system,
                  groupValue: widget.currentThemeMode,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) {
                    if (val != null) widget.onThemeChanged(val);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text("Light Mode"),
                  value: ThemeMode.light,
                  groupValue: widget.currentThemeMode,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) {
                    if (val != null) widget.onThemeChanged(val);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text("Dark Mode"),
                  value: ThemeMode.dark,
                  groupValue: widget.currentThemeMode,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) {
                    if (val != null) widget.onThemeChanged(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Language & Localization
          _buildSectionHeader("Language & Localization"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  items: ["English", "Urdu", "Roman Urdu / English"].map((String lang) {
                    return DropdownMenuItem<String>(
                      value: lang,
                      child: Text(lang, style: const TextStyle(fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLanguage = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Language preference updated to $_selectedLanguage")),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Audio & Haptics / Background Sound
          _buildSectionHeader("Audio & Haptics"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("App Sound Effects"),
                  subtitle: const Text("Play subtle tones on interactions"),
                  value: _soundEffects,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _soundEffects = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Background Ambient Sound"),
                  subtitle: const Text("Play relaxing meditation audio"),
                  value: _ambientAudioPlaying,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: _toggleAmbientAudio,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Gentle Haptics / Vibration"),
                  subtitle: const Text("Vibrate slightly on button taps"),
                  value: _haptics,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _haptics = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Notifications & Reminders
          _buildSectionHeader("Notifications & Reminders"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Daily Mood Check-in Reminder"),
                  subtitle: const Text("Get reminded to log your emotional state"),
                  value: _moodReminders,
                  activeColor: AppTheme.primaryTeal,
                  onChanged: (val) => setState(() => _moodReminders = val),
                ),
                if (_moodReminders) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text("Reminder Time"),
                    trailing: Text(
                      _reminderTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _reminderTime,
                      );
                      if (picked != null) {
                        setState(() => _reminderTime = picked);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. App Info & About Section
          _buildSectionHeader("About & Support"),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal),
                  title: const Text("App Version"),
                  trailing: const Text("v26.0.0", style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.primaryTeal),
                  title: const Text("Privacy Policy & Medical Disclaimer"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Privacy & Disclaimer"),
                        content: const Text(
                          "MindPower AI is a mental wellness and AI-guided supportive platform. We do not store confidential medical records on third-party public nodes. Your emotional wellness is secure with us.",
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded, color: AppTheme.primaryTeal),
                  title: const Text("Support & Contact Us"),
                  subtitle: const Text("umarhab8b231@gmail.com"),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal, letterSpacing: 1.1),
      ),
    );
  }
}