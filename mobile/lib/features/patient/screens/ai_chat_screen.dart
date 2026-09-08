import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:mindpower_ai/core/theme/app_theme.dart';
import 'package:mindpower_ai/core/models/user_session.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _speechEnabled = false;
  
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "message": "Hello! I am your Mind Power AI Counselor. Aap English, Urdu ya Roman Urdu mein baat kar sakte hain. How are you feeling today?",
      "time": _getCurrentTime(),
    }
  ];
  
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();
    
    // Urdu / Roman Urdu support ke liye TTS language set karna
    try {
      await _flutterTts.setLanguage("ur-PK");
    } catch (_) {
      await _flutterTts.setLanguage("en-US");
    }

    await _flutterTts.setSpeechRate(0.42); // Calm therapeutic pace
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isSpeaking = false));
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => setState(() => _isListening = false),
    );
    setState(() {});
  }

  void _listen() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available on this device.")),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: "ur_PK", // Urdu aur Roman Urdu voice recognition ke liye
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            if (_messageController.text.trim().isNotEmpty) {
              _sendMessage();
            }
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak(text);
    }
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Future<void> _sendMessage([String? customText]) async {
    final text = customText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    if (customText != null) {
      _messageController.text = customText;
    }

    final userTime = _getCurrentTime();
    setState(() {
      _messages.add({"sender": "user", "message": text, "time": userTime});
      _isGenerating = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8080/api/v1/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": text,
          "history": _messages,
        }),
      );

      if (!mounted) return;
      
      final aiTime = _getCurrentTime();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply = data['response'] ?? data['reply'] ?? data['message'] ?? "I am here to support you on your healing journey.";
        
        setState(() {
          _messages.add({"sender": "ai", "message": aiReply, "time": aiTime});
        });
        
        // AI therapist ka response automatic voice mein sunana
        _speakText(aiReply);
      } else {
        setState(() {
          _messages.add({
            "sender": "ai",
            "message": "Server error (${response.statusCode}): Please ensure your FastAPI backend is running properly.",
            "time": aiTime
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          "sender": "ai",
          "message": "Network error: Unable to reach backend server at http://127.0.0.1:8080.",
          "time": _getCurrentTime()
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildQuickChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: TextStyle(fontSize: 12, color: Colors.teal.shade800)),
        backgroundColor: Colors.teal.shade50,
        elevation: 0,
        pressElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.teal.shade200, width: 1),
        ),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppTheme.primaryTeal,
              radius: 16,
              child: Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "Mind Power AI Counselor",
              style: TextStyle(
                color: AppTheme.getDeepSlate(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_off, color: AppTheme.primaryTeal),
            tooltip: _isSpeaking ? "Mute Voice" : "Enable Voice Readout",
            onPressed: () {
              if (_isSpeaking) {
                _flutterTts.stop();
                setState(() => _isSpeaking = false);
              } else if (_messages.isNotEmpty) {
                _speakText(_messages.last['message']!);
              }
            },
          )
        ],
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: Colors.amber.shade50,
            child: Text(
              "⚠️ MindPower AI is a wellness assistant, not a clinical medical substitute.",
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppTheme.primaryTeal
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isUser
                                ? Text(
                                    msg['message']!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      height: 1.4,
                                    ),
                                  )
                                : MarkdownBody(
                                    data: msg['message']!,
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.getDeepSlate(context),
                                        height: 1.4,
                                      ),
                                      strong: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                            if (!isUser) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () => _speakText(msg['message']!),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.volume_up_rounded, size: 14, color: Colors.teal.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Listen",
                                        style: TextStyle(fontSize: 10, color: Colors.teal.shade700, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: isUser ? 0 : 4,
                        right: isUser ? 4 : 0,
                        bottom: 8,
                      ),
                      child: Text(
                        msg['time'] ?? '',
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isGenerating)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryTeal),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "AI Counselor is reflecting...",
                    style: TextStyle(fontSize: 12, color: AppTheme.getTextMuted(context), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          
          if (_isListening)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mic, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Listening (English / Urdu)... Speak now.",
                    style: TextStyle(color: Colors.teal.shade900, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildQuickChip("Main bohat pareshan hoon 😔"),
                _buildQuickChip("Mujhe sakoon ki saans leni hai 🫁"),
                _buildQuickChip("I feel overwhelmed ✨"),
                _buildQuickChip("Aj ka din kaisa guzra 📝"),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _isListening ? Colors.red.shade400 : Colors.teal.shade50,
                  child: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none_rounded,
                      color: _isListening ? Colors.white : AppTheme.primaryTeal,
                      size: 20,
                    ),
                    onPressed: _listen,
                    tooltip: "Tap to Speak (Urdu/English)",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(color: AppTheme.getDeepSlate(context)),
                    decoration: InputDecoration(
                      hintText: "Type or speak in Urdu/English...",
                      hintStyle: TextStyle(fontSize: 13, color: AppTheme.getTextMuted(context)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}