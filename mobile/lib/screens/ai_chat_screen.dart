import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoadingHistory = true;
  bool _isSending = false;

  final String baseUrl = "http://127.0.0.1:8080/api/v1/chat";

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
  }

  // Fetch past messages on initial load
  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/history/1'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> history = data['history'] ?? [];

        setState(() {
          _messages.clear();
          for (var item in history) {
            _messages.add({
              'sender': item['sender'].toString(),
              'message': item['message'].toString(),
            });
          }
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      debugPrint("History load error: $e");
      if (!mounted) return;
      setState(() => _isLoadingHistory = false);
    }
  }

  // Send message to FastAPI Backend
  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'message': text});
      _isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': 1, 'message': text}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final reply = data['response'] ?? "No response received.";
        setState(() {
          _messages.add({'sender': 'bot', 'message': reply});
        });
      } else {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': "Server connection error (${response.statusCode})."
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'message': "Network error: Unable to reach backend."
        });
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MindPower AI Therapy",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
                : _messages.isEmpty
                    ? Center(
                        child: Text(
                          "Start a conversation...",
                          style: TextStyle(color: AppTheme.getTextMuted(context)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['sender'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppTheme.primaryTeal
                                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['message'] ?? '',
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppTheme.getDeepSlate(context),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_isSending)
            const LinearProgressIndicator(color: AppTheme.primaryTeal),
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: AppTheme.getDeepSlate(context)),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: AppTheme.getTextMuted(context)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryTeal),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}