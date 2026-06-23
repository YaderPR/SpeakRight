import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speak_right/core/di/injection_container.dart' as di;
import 'package:speak_right/presentation/practice/views/practice_screen.dart';

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

class SpeakRightApp extends StatelessWidget {
  const SpeakRightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakRight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const PracticeScreen(),
    );
  }
}
