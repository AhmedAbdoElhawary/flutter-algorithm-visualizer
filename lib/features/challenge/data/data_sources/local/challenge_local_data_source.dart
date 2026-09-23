import 'dart:convert';

import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _problemsAssetsPath = 'assets/problems.json';

/// Arabic prose for the same 100 problems, keyed by `problem_id`.
///
/// An **overlay**, not a second dataset: it carries only the fields a reader
/// reads, and every other field — `test_cases`, `expected_output`,
/// `function_signature`, `default_code` — is served from
/// [_problemsAssetsPath] untouched. The offline grader therefore checks
/// answers against exactly the same bytes in either language, which is the
/// whole reason the translation lives in its own file instead of as extra
/// columns in the original.
/// TODO: add arabic overlay
const _problemsArabicAssetsPath = 'assets/problems.json';

const String _problemsKey = 'problems';

/// The whole parse, run on a background isolate via `compute`.
///
/// Everything it touches is top-level, because the worker isolate gets a fresh
/// copy of the program and cannot reach an instance method's receiver.
///
/// [payload] carries the already-loaded asset text: the English dataset, and
/// the Arabic overlay when there is one.
Dataset _parseDataset(({String english, String? arabic}) payload) {
  final Map<String, dynamic> jsonMap = json.decode(payload.english);

  var problems = jsonMap["problems"] as List<dynamic>;

  final arabic = payload.arabic;
  if (arabic != null) problems = _withArabicProse(problems, arabic);

  final adaptiveJson = <String, dynamic>{...jsonMap["dataset"], "problems": problems};
  return Dataset.fromJson(adaptiveJson);
}

/// Merges the Arabic overlay over [problems], field by field.
///
/// Anything the overlay does not mention keeps its English value, so the file
/// can be filled in a problem at a time without the app ever showing a blank.
/// A malformed overlay leaves the English list untouched.
List<dynamic> _withArabicProse(List<dynamic> problems, String raw) {
  final Map<String, dynamic> overlay;
  try {
    overlay = (json.decode(raw) as Map<String, dynamic>)["problems"] as Map<String, dynamic>;
  } catch (_) {
    return problems;
  }

  return [
    for (final problem in problems)
      _mergeProblem(
        Map<String, dynamic>.from(problem as Map),
        overlay['${problem["problem_id"]}'],
      ),
  ];
}

Map<String, dynamic> _mergeProblem(Map<String, dynamic> english, Object? arabic) {
  if (arabic is! Map) return english;

  final merged = Map<String, dynamic>.from(english);

  final description = arabic['description'];
  if (description is String && description.isNotEmpty) merged['description'] = description;

  final hints = arabic['hints'];
  if (hints is List) merged['hints'] = _overlayStrings(english['hints'], hints);

  // Examples are matched by position, and only their prose `explanation` is
  // replaced — `input` and `output` are literals the learner compares
  // against their own output, so they stay exactly as written.
  final explanations = arabic['example_explanations'];
  if (explanations is List && english['examples'] is List) {
    merged['examples'] = [
      for (final (index, example) in (english['examples'] as List).indexed)
        _mergeExample(
          Map<String, dynamic>.from(example as Map),
          index < explanations.length ? explanations[index] : null,
        ),
    ];
  }

  return merged;
}

Map<String, dynamic> _mergeExample(Map<String, dynamic> english, Object? explanation) {
  if (explanation is! String || explanation.isEmpty) return english;
  return <String, dynamic>{...english, 'explanation': explanation};
}

/// Positional overlay: a null or empty entry leaves that line in English.
List<dynamic> _overlayStrings(Object? english, List<dynamic> arabic) {
  final source = english is List ? english : const <dynamic>[];
  return [
    for (final (index, line) in source.indexed)
      (index < arabic.length && arabic[index] is String && (arabic[index] as String).isNotEmpty)
          ? arabic[index]
          : line,
  ];
}

/// i saved in local storage only the problems that user make any interaction with (solved it, bookmarked it, etc.)
/// Except [loadProblemsAssets] it has all problems
class ProblemLocalDataSource {
  ProblemLocalDataSource(this._storage);

  final LocalStorage _storage;

  /// Loads the dataset, in Arabic when [arabic] is set.
  ///
  /// A missing or malformed overlay is not an error: the English dataset is
  /// returned as-is. A learner reading a problem statement in English is a
  /// small disappointment; a crash on the challenges tab is not.
  /// Reads the asset bytes here, then parses them on a background isolate.
  ///
  /// `problems.json` is 784 KB and expands into 100 [Dataset] problems, each
  /// with test cases, examples, hints, signatures and default code for three
  /// languages. Decoding and modelling that is several hundred milliseconds of
  /// straight-line work, and it used to run on the UI isolate — so the first
  /// open of the Challenges tab froze the app mid-animation.
  ///
  /// Only the parse moves. [rootBundle] has to stay here because asset loading
  /// goes through the binding, which lives on the main isolate.
  Future<Dataset> loadProblemsAssets({bool arabic = false}) async {
    final String jsonString = await rootBundle.loadString(_problemsAssetsPath);

    /// A missing or malformed overlay is not an error, see [loadProblemsAssets]
    /// — the English dataset is parsed on its own.
    String? arabicJson;
    if (arabic) {
      try {
        arabicJson = await rootBundle.loadString(_problemsArabicAssetsPath);
      } catch (_) {
        arabicJson = null;
      }
    }

    return compute(
      _parseDataset,
      (english: jsonString, arabic: arabicJson),
    );
  }

  Future<void> saveProblem(ProblemStorageDTO problem) async {
    if (problem.problemId == null) throw StateError('Problem id cannot be nullable');

    final problems = getProblems();

    final exists = problems.any((item) => item.problemId == problem.problemId);

    if (exists) return await updateProblem(problem);

    problems.add(problem);

    await _saveProblems(problems);
  }

  Future<void> updateProblem(ProblemStorageDTO problem) async {
    final problems = getProblems();

    final index = problems.indexWhere((item) => item.problemId == problem.problemId);

    if (index == -1) return await saveProblem(problem);

    problems[index] = problem;

    await _saveProblems(problems);
  }

  Future<void> deleteProblem(int problemId) async {
    final problems = getProblems();

    problems.removeWhere((problem) => problem.problemId == problemId);

    await _saveProblems(problems);
  }

  List<ProblemStorageDTO> getProblems() {
    final data = _storage.read<List<dynamic>>(_problemsKey);

    if (data == null) return [];

    return data.map((json) => ProblemStorageDTO.fromJson(Map<String, dynamic>.from(json as Map))).toList();
  }

  ProblemStorageDTO? getProblem(int problemId) {
    final problems = getProblems();

    for (final problem in problems) {
      if (problem.problemId == problemId) return problem;
    }

    return null;
  }

  Future<void> overwriteProblems(List<ProblemStorageDTO> problems) => _saveProblems(problems);

  Future<void> _saveProblems(List<ProblemStorageDTO> problems) async {
    final List<Map<String, dynamic>> json = [];

    for (final problem in problems) {
      if (problem.problemId == null) continue;

      json.add(problem.toJson());
    }
    await _storage.write(_problemsKey, json);
  }
}
