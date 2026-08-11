enum ProblemStatus { solved, attempted, todo }

enum ProblemDifficulty { all, easy, medium, hard }

class Problem {
  final int id;
  final int num;
  final String name;
  final ProblemDifficulty difficulty;
  final ProblemStatus status;
  final double acceptance;
  final List<String> tags;

  const Problem({
    required this.id,
    required this.num,
    required this.name,
    required this.difficulty,
    required this.status,
    required this.acceptance,
    required this.tags,
  });
}

extension ProblemStatusX on Problem {
  bool get isSolved => status == ProblemStatus.solved;
}

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
