import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_case.freezed.dart';
part 'test_case.g.dart';

@freezed
class TestCase with _$TestCase {
  const factory TestCase({
   required String? input,
   required  String? expectedOutput,
  }) = _TestCase;

  factory TestCase.fromJson(Map<String, dynamic> json) => _$TestCaseFromJson(json);
}