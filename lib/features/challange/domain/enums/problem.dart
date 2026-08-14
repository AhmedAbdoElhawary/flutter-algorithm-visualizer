enum ProblemStatus { solved, attempted, none }

enum ProblemDifficulty { easy, medium, hard, none }

extension ProblemDifficultyX on ProblemDifficulty {
  String get difficultyString => _capitalizeFirstLetter(name);
}

extension ProblemStatusXX on ProblemStatus {
  String get difficultyString => _capitalizeFirstLetter(name);
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;

  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}
