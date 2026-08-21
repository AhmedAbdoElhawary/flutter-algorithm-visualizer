import 'dart:convert';

import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/dataset.dart';
import 'package:algorithm_visualizer/features/challenge/data/models/problem_storage.dart';
import 'package:flutter/services.dart';

const _problemsAssetsPath = 'assets/problems.json';
const String _problemsKey = 'problems';

/// [loadProblemsAssets] i saved in local storage only the problems that user make any interaction with (solved it, bookmarked it, etc.)

class ProblemLocalDataSource {
  ProblemLocalDataSource(this._storage);

  final GetStorageService _storage;


  Future<Dataset> loadProblemsAssets() async {
    final String jsonString = await rootBundle.loadString(_problemsAssetsPath);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final adaptiveJson = <String, dynamic>{...jsonMap["dataset"], "problems": jsonMap["problems"]};
    return Dataset.fromJson(adaptiveJson);
  }

  Future<void> saveProblem(ProblemStorageDTO problem) async {
    final problems = getProblems();

    final exists = problems.any((item) => item.problemId == problem.problemId);

    if (exists) throw StateError('Problem with id ${problem.problemId} already exists.');

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

  Future<void> _saveProblems(List<ProblemStorageDTO> problems) async {
    final json = problems.map((problem) => problem.toJson()).toList();

    await _storage.write(_problemsKey, json);
  }
}
