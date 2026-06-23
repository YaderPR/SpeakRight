import 'package:flutter/material.dart';
import 'package:speak_right/presentation/settings/views/speech_models_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0F0F13);
    const surfaceDark = Color(0xFF181822);
    const borderColor = Color(0xFF282835);
    const primaryAccent = Color(0xFF6C5DD3);
    const textMuted = Color(0xFF8A8A9D);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          _buildCategoryHeader('PREFERENCES', primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            subtitle: 'Dark theme',
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {
              // Placeholder for future theme settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),
          const SizedBox(height: 24),
          
          _buildCategoryHeader('SPEECH RECOGNITION', primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.record_voice_over_outlined,
            title: 'Speech Models',
            subtitle: 'Manage and download offline & streaming STT models',
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SpeechModelsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          _buildCategoryHeader('ABOUT', primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'About SpeakRight',
            subtitle: 'Version 1.0.0',
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: primaryAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color surfaceDark,
    required Color borderColor,
    required Color primaryAccent,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
