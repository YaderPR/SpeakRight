import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/l10n/app_localizations.dart';
import 'package:speak_right/presentation/settings/views/speech_models_screen.dart';
import 'package:speak_right/presentation/settings/views/practice_preferences_screen.dart';
import 'package:speak_right/presentation/settings/views/audio_settings_screen.dart';
import 'package:speak_right/presentation/settings/viewmodels/preferences_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final preferencesState = ref.watch(preferencesViewModelProvider);
    final preferencesViewModel = ref.read(preferencesViewModelProvider.notifier);

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
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        children: [
          _buildCategoryHeader(l10n.preferences.toUpperCase(), primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle: preferencesState.languageCode == 'es' ? l10n.spanish : l10n.english,
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {
              _showLanguageDialog(context, preferencesState.languageCode, preferencesViewModel, l10n);
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.flag_outlined,
            title: l10n.practicePreferences,
            subtitle: l10n.practicePreferencesDesc,
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PracticePreferencesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          _buildCategoryHeader(l10n.audioAndSpeech.toUpperCase(), primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.mic_none_outlined,
            title: l10n.audioSettings,
            subtitle: l10n.audioSettingsDesc,
            surfaceDark: surfaceDark,
            borderColor: borderColor,
            primaryAccent: primaryAccent,
            textMuted: textMuted,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AudioSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            context,
            icon: Icons.record_voice_over_outlined,
            title: l10n.speechModels,
            subtitle: l10n.speechModelsDesc,
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
          
          _buildCategoryHeader(l10n.about.toUpperCase(), primaryAccent),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: '${l10n.about} SpeakRight',
            subtitle: '${l10n.version} 1.0.0',
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

  void _showLanguageDialog(BuildContext context, String currentLanguage, PreferencesViewModel viewModel, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181822),
          title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.english, style: const TextStyle(color: Colors.white)),
                value: 'en',
                groupValue: currentLanguage,
                activeColor: const Color(0xFF6C5DD3),
                onChanged: (value) {
                  if (value != null) viewModel.setLanguage(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.spanish, style: const TextStyle(color: Colors.white)),
                value: 'es',
                groupValue: currentLanguage,
                activeColor: const Color(0xFF6C5DD3),
                onChanged: (value) {
                  if (value != null) viewModel.setLanguage(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
