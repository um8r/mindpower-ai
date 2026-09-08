import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';

class TherapyResourceLibraryScreen extends StatefulWidget {
  const TherapyResourceLibraryScreen({Key? key}) : super(key: key);

  @override
  State<TherapyResourceLibraryScreen> createState() =>
      _TherapyResourceLibraryScreenState();
}

class _TherapyResourceLibraryScreenState
    extends State<TherapyResourceLibraryScreen> {
  List<dynamic> resources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTherapyResources();
  }

  Future<void> fetchTherapyResources() async {
    // 127.0.0.1 and localhost fallback array
    final List<String> endpoints = [
      "http://127.0.0.1:8080/api/v1/therapy/videos",
      "http://localhost:8080/api/v1/therapy/videos"
    ];

    for (String urlStr in endpoints) {
      try {
        final response = await http.get(
          Uri.parse(urlStr),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final List<dynamic> data = decoded is List ? decoded : (decoded['videos'] ?? decoded['resources'] ?? []);
          if (mounted) {
            setState(() {
              resources = data;
              isLoading = false;
            });
          }
          return; // Success, exit loop
        }
      } catch (e) {
        debugPrint("Endpoint $urlStr failed: $e");
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> openMediaUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Therapy Library",
          style: TextStyle(color: AppTheme.getDeepSlate(context), fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : resources.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No resources found.", style: TextStyle(color: AppTheme.getTextMuted(context))),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
                        onPressed: () {
                          setState(() => isLoading = true);
                          fetchTherapyResources();
                        },
                        child: const Text("Reload Library", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final item = resources[index];
                    final isEven = index % 2 == 0;

                    final categoryBgColor = isEven
                        ? const Color(0xFFE0F2F1)
                        : const Color(0xFFFFE0B2);
                    final categoryTextColor = isEven
                        ? const Color(0xFF00695C)
                        : const Color(0xFFE65100);
                    final buttonColor = isEven
                        ? const Color(0xFF00695C)
                        : const Color(0xFFEF6C00);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: categoryBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['category'] ?? 'GENERAL',
                                  style: TextStyle(
                                    color: categoryTextColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                item['duration'] ?? '10 mins',
                                style: TextStyle(
                                    color: AppTheme.getTextMuted(context), fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getDeepSlate(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['description'] ?? '',
                            style: TextStyle(
                              color: AppTheme.getTextMuted(context),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      openMediaUrl(item['video_url'] ?? ''),
                                  icon: Icon(Icons.play_circle_fill,
                                      color: buttonColor, size: 18),
                                  label: Text(
                                    "Watch Video",
                                    style: TextStyle(
                                        color: buttonColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: buttonColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      openMediaUrl(item['audio_url'] ?? ''),
                                  icon: const Icon(Icons.volume_up,
                                      color: Colors.white, size: 18),
                                  label: const Text(
                                    "Audio Guide",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}