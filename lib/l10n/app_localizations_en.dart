// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpeakRight';

  @override
  String get appName => 'SpeakRight';

  @override
  String get settings => 'Settings';

  @override
  String get preferences => 'Preferences';

  @override
  String get practicePreferences => 'Practice Preferences';

  @override
  String get practicePreferencesDesc => 'Daily goals and reminders';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceDesc => 'Dark theme';

  @override
  String get audioAndSpeech => 'Audio & Speech';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get audioSettingsDesc => 'Auto-stop and noise suppression';

  @override
  String get speechRecognition => 'Speech Recognition';

  @override
  String get speechModels => 'Speech Models';

  @override
  String get speechModelsDesc => 'Manage offline transcription models';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get version => 'Version';

  @override
  String get dailyPracticeGoal => 'Daily Practice Goal';

  @override
  String get dailyPracticeGoalDesc =>
      'Set how many minutes you want to practice per day.';

  @override
  String get dailyReminders => 'Daily Reminders';

  @override
  String get dailyRemindersDesc =>
      'We will send you a push notification so you don\'t lose your streak.';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get selectTime => 'Select Time';

  @override
  String get min => 'min';

  @override
  String get autoStopVAD => 'Auto-Stop (VAD)';

  @override
  String get autoStopVADDesc =>
      'Automatically stop recording when you stop speaking.';

  @override
  String get noiseSuppression => 'Noise Suppression';

  @override
  String get noiseSuppressionDesc =>
      'Filter out background noise. May slightly delay processing.';

  @override
  String get language => 'Language';

  @override
  String get languageDesc => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get streaming => 'Streaming';

  @override
  String get active => 'Active';

  @override
  String get activate => 'Activate';

  @override
  String get delete => 'Delete';

  @override
  String get download => 'Download';

  @override
  String get downloading => 'Downloading';

  @override
  String get practiceMode => 'Practice Mode';

  @override
  String get tapToSpeak => 'Tap to speak...';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get practiceSentenceTitle => 'PRACTICE SENTENCE';

  @override
  String get startPracticeMessage => 'Press the microphone to start practicing';

  @override
  String get speakClearlyMessage => 'Speak clearly into your microphone';

  @override
  String get evaluatingMessage => 'Evaluating pronunciation...';

  @override
  String get greatPronunciation => 'Great Pronunciation!';

  @override
  String get keepPracticing => 'Keep Practicing!';

  @override
  String scoreDetail(int correct, int total) {
    return 'You pronounced $correct out of $total words correctly.';
  }

  @override
  String get errorMessage => 'Error';

  @override
  String get evaluate => 'Evaluate';
}
