// lib/models/function_signature.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'function_signature.freezed.dart';
part 'function_signature.g.dart';

@freezed
class FunctionSignature with _$FunctionSignature {
  const factory FunctionSignature({
    required String generic,
    required String dart,
  }) = _FunctionSignature;

  factory FunctionSignature.fromJson(Map<String, dynamic> json) => _$FunctionSignatureFromJson(json);
}