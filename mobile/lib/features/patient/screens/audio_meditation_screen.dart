import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mindpower_ai/core/theme/app_theme.dart';

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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: meditationTracks.length,
        itemBuilder: (context, index) {
          final track = meditationTracks[index];
          final bool isCurrentTrack = _currentIndex == index;
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isDark ? 2 : 1,
            child: ListTile(
              title: Text(
                track['title']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getDeepSlate(context),
                ),
              ),
              subtitle: Text(
                track['subtitle']!,
                style: TextStyle(color: AppTheme.getTextMuted(context)),
              ),
              trailing: IconButton(
                icon: Icon(
                  (isCurrentTrack && _isPlaying) ? Icons.pause_circle_filled : Icons.play_circle_fill,
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
    );
  }
}