import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../main.dart'; 
import 'login_screen.dart';
import 'settings_screen.dart';

class WelcomeIntroScreen extends StatefulWidget {
  const WelcomeIntroScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeIntroScreen> createState() => _WelcomeIntroScreenState();
}

class _WelcomeIntroScreenState extends State<WelcomeIntroScreen> {
  bool _isHovered = false;

  Future<void> _launchOfficialWebsite() async {
    final Uri url = Uri.parse('https://mindpowerartists.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            return Stack(
              children: [
                // Main Content Scrollable Area
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? constraints.maxWidth * 0.15 : 20.0,
                    vertical: isDesktop ? 40.0 : 70.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      
                      // 🖼️ Perfectly Cropped Circular Logo Container (Top/Bottom black edges removed)
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(isDark ? 0.05 : 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.55, // Top aur bottom ke black edges ko completely crop karne ke liye scale barha diya hai
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              width: 105,
                              height: 105,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.psychology_rounded,
                                size: 50,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      
                      // Official Studio Name
                      Text(
                        "Mind Power Artists",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getDeepSlate(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Official Mind Care & Subconscious Healing Platform",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // About Official Studio Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome to Mind Power Artists",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getDeepSlate(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Mind Power Artists is a premier institute dedicated to mental transformation, alpha frequency mind control, aura energy cleansing, and remote psychological healing under the expert supervision of spiritual and mind science mentors.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.getTextMuted(context),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            // Core Specialized Services
                            const _ServiceItem(
                              icon: Icons.psychology_rounded,
                              title: "Mind Science & Aura Cleansing",
                              subtitle: "Heal your inner energy, balance chakras & remove negative vibrations.",
                            ),
                            const SizedBox(height: 12),
                            const _ServiceItem(
                              icon: Icons.video_call_rounded,
                              title: "Remote Tele-Health & Video Sessions",
                              subtitle: "Get one-on-one video consultations directly from expert practitioners.",
                            ),
                            const SizedBox(height: 12),
                            const _ServiceItem(
                              icon: Icons.play_circle_fill_rounded,
                              title: "Exclusive Therapy Library",
                              subtitle: "Access guided meditations, courses, wazifa attunements & mind power playlists.",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Official Contact & Location Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal.withOpacity(isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "📍 Islamabad Headquarters",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Lower Ground Floor The Plazzo, Below Askari Bank, Gulberg Greens, Islamabad",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.getDeepSlate(context),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "📞 +92 3103 338452 / 53  |  📧 info@mindpowerartists.com",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _launchOfficialWebsite,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryTeal),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              ),
                              icon: const Icon(Icons.language_rounded, size: 16, color: AppTheme.primaryTeal),
                              label: const Text(
                                "Visit mindpowerartists.com",
                                style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Top-Right Controls (Comprehensive Settings Button & Sign In Button)
                Positioned(
                  top: 16,
                  right: 20,
                  child: Row(
                    children: [
                      // Comprehensive App Settings Button
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.settings_rounded, color: AppTheme.primaryTeal, size: 20),
                          tooltip: "App Settings",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingsScreen(
                                  currentThemeMode: Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
                                  onThemeChanged: (newMode) {
                                    themeNotifier.setTheme(newMode);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Sign In Button
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHovered ? AppTheme.primaryDarkTeal : AppTheme.primaryTeal,
                              foregroundColor: Colors.white,
                              elevation: _isHovered ? 6 : 2,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceItem({Key? key, required this.icon, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getDeepSlate(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.getTextMuted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}