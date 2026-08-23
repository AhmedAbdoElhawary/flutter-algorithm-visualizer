import 'package:json_annotation/json_annotation.dart';

part 'example.g.dart';

@JsonSerializable()
class Example {
  const Example({required this.input, required this.output, required this.explanation});

  final String? input;
  final String? output;
  final String? explanation;

  factory Example.fromJson(Map<String, dynamic> json) => _$ExampleFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Example &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output &&
          explanation == other.explanation;

  @override
  int get hashCode => Object.hash(runtimeType, input, output, explanation);
}
