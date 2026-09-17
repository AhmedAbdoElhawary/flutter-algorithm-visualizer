import 'package:algorithm_visualizer/core/resources/strings_manager.dart';

enum ProblemStatus { solved, attempted, none }

enum ProblemDifficulty { none, easy, medium, hard }

/// Both labels used to be built by capitalising the enum's own `name`
/// (`easy` -> `Easy`). That produced the right English word and **no
/// translation at all**: the app's Arabic table is keyed by the exact English
/// text declared in [StringsManager], and a string assembled at runtime from
/// an identifier is not that string — nothing would have matched, and the
/// chips would have stayed English on an otherwise Arabic screen.
///
/// Naming the constant makes the label a first-class translatable string, and
/// makes it greppable: searching for `StringsManager.hard` now finds this.
extension ProblemDifficultyX on ProblemDifficulty {
  String get difficultyString => switch (this) {
        ProblemDifficulty.none => StringsManager.all,
        ProblemDifficulty.easy => StringsManager.easy,
        ProblemDifficulty.medium => StringsManager.medium,
        ProblemDifficulty.hard => StringsManager.hard,
      };
}

extension ProblemStatusXX on ProblemStatus {
  String get difficultyString => switch (this) {
        ProblemStatus.none => StringsManager.notSolved,
        ProblemStatus.solved => StringsManager.solvedMoment,
        ProblemStatus.attempted => StringsManager.attempted,
      };
}
