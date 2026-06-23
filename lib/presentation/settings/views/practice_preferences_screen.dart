import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speak_right/presentation/settings/viewmodels/preferences_viewmodel.dart';

class PracticePreferencesScreen extends ConsumerWidget {
  const PracticePreferencesScreen({super.key});

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
          l10n.practicePreferences,
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
          // Daily Goal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flag_outlined, color: primaryAccent),
                    SizedBox(width: 12),
                    Text(
                      l10n.dailyPracticeGoal,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dailyPracticeGoalDesc,
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      '${state.dailyGoal} ${l10n.min}',
                      style: const TextStyle(
                        color: primaryAccent,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: state.dailyGoal.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        activeColor: primaryAccent,
                        inactiveColor: borderColor,
                        onChanged: (val) {
                          viewModel.setDailyGoal(val.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Reminders
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active_outlined, color: primaryAccent),
                        SizedBox(width: 12),
                        Text(
                          l10n.dailyReminders,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: state.remindersEnabled,
                      activeColor: primaryAccent,
                      onChanged: (val) => viewModel.toggleReminders(val),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.dailyRemindersDesc,
                  style: TextStyle(color: textMuted, fontSize: 13),
                ),
                if (state.remindersEnabled) ...[
                  const SizedBox(height: 24),
                  const Divider(color: borderColor),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.reminderTime,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.reminderTime != null 
                          ? state.reminderTime!.format(context)
                          : l10n.selectTime,
                        style: const TextStyle(
                          color: primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: state.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
                      );
                      if (time != null) {
                        viewModel.setReminderTime(time);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
