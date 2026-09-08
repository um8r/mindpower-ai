import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_theme.dart';

class AudioMeditationScreen extends StatefulWidget {
  const AudioMeditationScreen({Key? key}) : super(key: key);

  @override
  State<AudioMeditationScreen> createState() => _AudioMeditationScreenState();
}

class _AudioMeditationScreenState extends State<AudioMeditationScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentIndex;

  final List<Map<String, String>> meditationTracks = [
    {
      "title": "Alpha Brainwave Frequency (Deep Focus)",
      "subtitle": "10Hz Alpha Waves for Subconscious Mind Activation",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
    {
      "title": "Aura Cleansing & Chakra Healing Audio",
      "subtitle": "Solfeggio Frequencies for Energy Field Balance",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    },
    {
      "title": "Deep Sleep & Anxiety Relief Session",
      "subtitle": "Delta Waves for Absolute Inner Peace",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playTrack(String url, int index) async {
    try {
      setState(() {
        _isLoading = true;
        _currentIndex = index;
      });
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _currentIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error playing audio: $e")),
      );
    }
  }

  Future<void> _pauseTrack() async {
    await _audioPlayer.pause();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "In-App Healing Frequencies",
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
                      const Icon(Icons.headphones_rounded, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Binaural Beats & Alpha Audio",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Listen directly inside the app with background support for deep meditation.",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Available Healing Sessions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.getDeepSlate(context)),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meditationTracks.length,
                  itemBuilder: (context, index) {
                    final track = meditationTracks[index];
                    final bool isCurrentTrack = _currentIndex == index;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      color: Theme.of(context).cardColor,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                          child: const Icon(Icons.music_note_rounded, color: AppTheme.primaryTeal),
                        ),
                        title: Text(
                          track['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.getDeepSlate(context)),
                        ),
                        subtitle: Text(
                          track['subtitle']!,
                          style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                        ),
                        trailing: IconButton(
                          icon: (_isLoading && isCurrentTrack)
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal))
                              : Icon(
                                  (isCurrentTrack && _isPlaying) ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                  color: AppTheme.primaryTeal,
                                  size: 36,
                                ),
                          onPressed: () {
                            if (isCurrentTrack && _isPlaying) {
                              _pauseTrack();
                            } else {
                              _playTrack(track['url']!, index);
                            }
                          },
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