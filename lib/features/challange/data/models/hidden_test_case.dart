// lib/models/hidden_test_case.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hidden_test_case.freezed.dart';
part 'hidden_test_case.g.dart';

@freezed
class HiddenTestCase with _$HiddenTestCase {
  const factory HiddenTestCase({
    required Map<String, dynamic> input,
    required dynamic expectedOutput,
    required String reason,
  }) = _HiddenTestCase;

  factory HiddenTestCase.fromJson(Map<String, dynamic> json) => _$HiddenTestCaseFromJson(json);
}
