enum PracticeLevel {
  basic,
  intermediate,
  advanced,
  tongueTwisters,
}

extension PracticeLevelExtension on PracticeLevel {
  String get displayName {
    switch (this) {
      case PracticeLevel.basic:
        return 'Nivel Básico';
      case PracticeLevel.intermediate:
        return 'Nivel Intermedio';
      case PracticeLevel.advanced:
        return 'Nivel Avanzado';
      case PracticeLevel.tongueTwisters:
        return 'Trabalenguas';
    }
  }
}
