import 'package:speak_right/domain/entities/practice_level.dart';
import 'package:speak_right/domain/entities/practice_text.dart';

const List<PracticeText> practiceTexts = [
  // Nivel Básico
  PracticeText(
    level: PracticeLevel.basic,
    text: "My cat loves to sleep on the keyboard while I work.",
  ),
  PracticeText(
    level: PracticeLevel.basic,
    text: "The coffee is too hot to drink right now.",
  ),
  PracticeText(
    level: PracticeLevel.basic,
    text: "I need to update my to-do list for tomorrow.",
  ),

  // Nivel Intermedio
  PracticeText(
    level: PracticeLevel.intermediate,
    text: "Deploying the new microservice architecture improved system performance.",
  ),
  PracticeText(
    level: PracticeLevel.intermediate,
    text: "We need to refactor the frontend components using modern frameworks.",
  ),
  PracticeText(
    level: PracticeLevel.intermediate,
    text: "Understanding compound interest is crucial for long-term investment portfolios.",
  ),
  PracticeText(
    level: PracticeLevel.intermediate,
    text: "The stock market showed high volatility during the morning trading session.",
  ),

  // Nivel Avanzado
  PracticeText(
    level: PracticeLevel.advanced,
    text: "Hiking up a steep volcano requires immense stamina, proper gear, and careful hydration.",
  ),
  PracticeText(
    level: PracticeLevel.advanced,
    text: "Asynchronous programming can introduce subtle bugs if race conditions aren't handled properly.",
  ),
  PracticeText(
    level: PracticeLevel.advanced,
    text: "The platform requires strict role-based access control to secure sensitive user data.",
  ),

  // Trabalenguas
  PracticeText(
    level: PracticeLevel.tongueTwisters,
    text: "How can a clam cram in a clean cream can?",
  ),
  PracticeText(
    level: PracticeLevel.tongueTwisters,
    text: "I saw a kitten eating chicken in the kitchen.",
  ),
];
