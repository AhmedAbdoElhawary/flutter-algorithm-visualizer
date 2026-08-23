import 'package:json_annotation/json_annotation.dart';

part 'function_signature.g.dart';

@JsonSerializable()
class FunctionSignature {
  const FunctionSignature({required this.generic, required this.dart});

  final String? generic;
  final String? dart;

  factory FunctionSignature.fromJson(Map<String, dynamic> json) => _$FunctionSignatureFromJson(json);

  Map<String, dynamic> toJson() => _$FunctionSignatureToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionSignature &&
          runtimeType == other.runtimeType &&
          generic == other.generic &&
          dart == other.dart;

  @override
  int get hashCode => Object.hash(runtimeType, generic, dart);
}
