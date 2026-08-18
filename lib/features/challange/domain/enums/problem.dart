import 'package:algorithm_visualizer/core/resources/strings_manager.dart';

enum ProblemStatus { solved, attempted, none }

enum ProblemDifficulty { none, easy, medium, hard }

extension ProblemDifficultyX on ProblemDifficulty {
  String get difficultyString =>
      this == ProblemDifficulty.none ? StringsManager.all : _capitalizeFirstLetter(name);
}

extension ProblemStatusXX on ProblemStatus {
  String get difficultyString =>
      this == ProblemStatus.none ? StringsManager.notSolved : _capitalizeFirstLetter(name);
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;

  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}
