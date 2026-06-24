import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/l10n/app_localizations.dart';
import 'package:speak_right/presentation/practice/views/practice_screen.dart';
import 'package:speak_right/presentation/practice/views/free_practice_screen.dart';
import 'package:speak_right/presentation/settings/views/settings_screen.dart';

final currentMainTabProvider = StateProvider<int>((ref) => 0);

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = ref.watch(currentMainTabProvider);

    const bgDark = Color(0xFF0F0F13);
    const surfaceDark = Color(0xFF181822);
    const primaryAccent = Color(0xFF6C5DD3);
    const textMuted = Color(0xFF8A8A9D);
    const borderColor = Color(0xFF282835);

    final screens = [
      const FreePracticeScreen(),
      const PracticeScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: bgDark,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryAccent,
          unselectedItemColor: textMuted,
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(currentMainTabProvider.notifier).state = index;
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.mic_none),
              activeIcon: const Icon(Icons.mic),
              label: l10n.freePractice,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: l10n.guidedPractice,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
