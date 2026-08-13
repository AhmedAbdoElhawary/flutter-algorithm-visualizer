// lib/models/example.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example.freezed.dart';
part 'example.g.dart';

@freezed
class Example with _$Example {
  const factory Example({
    required Map<String, dynamic> input,
    required dynamic output,
    required String explanation,
  }) = _Example;

  factory Example.fromJson(Map<String, dynamic> json) => _$ExampleFromJson(json);
}