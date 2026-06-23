// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SpeakRight';

  @override
  String get appName => 'SpeakRight';

  @override
  String get settings => 'Ajustes';

  @override
  String get preferences => 'Preferencias';

  @override
  String get practicePreferences => 'Preferencias de Práctica';

  @override
  String get practicePreferencesDesc => 'Metas diarias y recordatorios';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceDesc => 'Tema oscuro';

  @override
  String get audioAndSpeech => 'Audio y Voz';

  @override
  String get audioSettings => 'Ajustes de Audio';

  @override
  String get audioSettingsDesc => 'Parada automática y supresión de ruido';

  @override
  String get speechRecognition => 'Reconocimiento de Voz';

  @override
  String get speechModels => 'Modelos de Voz';

  @override
  String get speechModelsDesc =>
      'Gestiona los modelos de transcripción offline';

  @override
  String get about => 'Acerca de';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get version => 'Versión';

  @override
  String get dailyPracticeGoal => 'Meta Diaria de Práctica';

  @override
  String get dailyPracticeGoalDesc =>
      'Establece cuántos minutos deseas practicar al día.';

  @override
  String get dailyReminders => 'Recordatorios Diarios';

  @override
  String get dailyRemindersDesc =>
      'Te enviaremos una notificación para que no pierdas tu racha.';

  @override
  String get reminderTime => 'Hora de Recordatorio';

  @override
  String get selectTime => 'Seleccionar Hora';

  @override
  String get min => 'min';

  @override
  String get autoStopVAD => 'Parada Automática (VAD)';

  @override
  String get autoStopVADDesc =>
      'Detener automáticamente la grabación cuando dejes de hablar.';

  @override
  String get noiseSuppression => 'Supresión de Ruido';

  @override
  String get noiseSuppressionDesc =>
      'Filtra el ruido de fondo. Puede retrasar ligeramente el procesamiento.';

  @override
  String get language => 'Idioma';

  @override
  String get languageDesc => 'Elige tu idioma preferido';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get streaming => 'En tiempo real';

  @override
  String get active => 'Activo';

  @override
  String get activate => 'Activar';

  @override
  String get delete => 'Eliminar';

  @override
  String get download => 'Descargar';

  @override
  String get downloading => 'Descargando';

  @override
  String get practiceMode => 'Modo Práctica';

  @override
  String get tapToSpeak => 'Toca para hablar...';

  @override
  String get comingSoon => '¡Próximamente!';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get dismiss => 'Ocultar';

  @override
  String get practiceSentenceTitle => 'ORACIÓN DE PRÁCTICA';

  @override
  String get startPracticeMessage => 'Presiona el micrófono para comenzar';

  @override
  String get speakClearlyMessage => 'Habla claramente al micrófono';

  @override
  String get evaluatingMessage => 'Evaluando pronunciación...';

  @override
  String get greatPronunciation => '¡Excelente Pronunciación!';

  @override
  String get keepPracticing => '¡Sigue Practicando!';

  @override
  String scoreDetail(int correct, int total) {
    return 'Pronunciaste $correct de $total palabras correctamente.';
  }

  @override
  String get errorMessage => 'Error';

  @override
  String get evaluate => 'Evaluar';

  @override
  String get freePractice => 'Práctica Libre';

  @override
  String get guidedPractice => 'Práctica Guiada';

  @override
  String get typePromptOptional => 'Escribe una oración objetivo (Opcional)...';

  @override
  String get noPromptHint => 'O simplemente habla libremente...';

  @override
  String get transcription => 'Transcripción';
}
