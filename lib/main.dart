import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speak_right/core/di/injection_container.dart' as di;
import 'package:speak_right/presentation/practice/views/practice_screen.dart';
import 'package:speak_right/presentation/settings/viewmodels/preferences_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.initDependencies();
  
  runApp(
    const ProviderScope(
      child: SpeakRightApp(),
    ),
  );
}

class SpeakRightApp extends ConsumerWidget {
  const SpeakRightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesState = ref.watch(preferencesViewModelProvider);

    return MaterialApp(
      title: 'SpeakRight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      locale: Locale(preferencesState.languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const PracticeScreen(),
    );
  }
}
