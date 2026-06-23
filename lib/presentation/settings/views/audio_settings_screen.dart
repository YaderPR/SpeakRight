import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speak_right/presentation/settings/viewmodels/preferences_viewmodel.dart';

class AudioSettingsScreen extends ConsumerWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(preferencesViewModelProvider);
    final viewModel = ref.read(preferencesViewModelProvider.notifier);

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
          l10n.audioSettings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  icon: Icons.mic_off_outlined,
                  title: l10n.autoStopVAD,
                  subtitle: l10n.autoStopVADDesc,
                  value: state.autoStopVAD,
                  onChanged: (val) => viewModel.toggleAutoStopVAD(val),
                  primaryAccent: primaryAccent,
                  textMuted: textMuted,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: borderColor),
                ),
                _buildToggleRow(
                  icon: Icons.waves_outlined,
                  title: l10n.noiseSuppression,
                  subtitle: l10n.noiseSuppressionDesc,
                  value: state.noiseSuppression,
                  onChanged: (val) => viewModel.toggleNoiseSuppression(val),
                  primaryAccent: primaryAccent,
                  textMuted: textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color primaryAccent,
    required Color textMuted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: primaryAccent, size: 24),
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
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          activeColor: primaryAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
