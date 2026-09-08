import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/app_theme.dart';

class DatabaseLogsScreen extends StatefulWidget {
  const DatabaseLogsScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseLogsScreen> createState() => _DatabaseLogsScreenState();
}

class _DatabaseLogsScreenState extends State<DatabaseLogsScreen> {
  List<dynamic> logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDatabaseLogs();
  }

  Future<void> _fetchDatabaseLogs() async {
    try {
      final response = await http.get(Uri.parse("http://127.0.0.1:8080/api/v1/logs"));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          logs = data['logs'] ?? data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching logs: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Database Logs",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : logs.isEmpty
              ? Center(
                  child: Text(
                    "No logs recorded.",
                    style: TextStyle(color: AppTheme.getTextMuted(context)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    bool isFlagged = log['is_flagged'] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Theme.of(context).cardColor,
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          'User: ${log['user_message'] ?? ''}',
                          style: TextStyle(
                            color: isFlagged ? Colors.redAccent : AppTheme.primaryDarkTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bot: ${log['bot_response'] ?? ''}',
                                style: TextStyle(color: AppTheme.getDeepSlate(context), fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                log['timestamp'] ?? '',
                                style: TextStyle(fontSize: 11, color: AppTheme.getTextMuted(context)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}