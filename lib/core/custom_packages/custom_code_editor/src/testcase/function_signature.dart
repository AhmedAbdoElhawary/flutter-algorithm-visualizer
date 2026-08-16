import 'parsing_utils.dart';

/// A single typed parameter of a parsed function signature.
class ParsedFunctionParam {
  const ParsedFunctionParam(this.type, this.name);

  final String type;
  final String name;
}

/// Parsed representation of a function signature such as
/// `List<ListNode?> mergeTwoLists(List<ListNode?> list1, List<ListNode?> list2)`.
class ParsedFunctionSignature {
  const ParsedFunctionSignature({
    required this.name,
    required this.returnType,
    required this.params,
  });

  final String name;
  final String returnType;
  final List<ParsedFunctionParam> params;

  bool get isVoid => returnType.trim() == 'void';
}

/// Parses a raw Dart-style function signature string.
ParsedFunctionSignature parseFunctionSignature(String signature) {
  final s = signature.trim();
  final open = topLevelOpenParen(s);
  final close = matchingParen(s, open);
  if (open == -1 || close == -1) {
    throw FormatException('Invalid function signature: $signature');
  }

  final before = s.substring(0, open).trim();
  final between = s.substring(open + 1, close).trim();

  final nameMatch = RegExp(r'([A-Za-z_]\w*)\s*$').firstMatch(before);
  final name = nameMatch?.group(1) ?? before;
  final returnType = nameMatch == null ? '' : before.substring(0, nameMatch.start).trim();

  final params = <ParsedFunctionParam>[];
  if (between.isNotEmpty) {
    for (final raw in splitTopLevel(between)) {
      final p = raw.trim();
      if (p.isEmpty) continue;
      final typeMatch = RegExp(r'([A-Za-z_]\w*)\s*$').firstMatch(p);
      if (typeMatch == null) continue;
      params.add(
        ParsedFunctionParam(
          p.substring(0, typeMatch.start).trim(),
          typeMatch.group(1)!,
        ),
      );
    }
  }

  return ParsedFunctionSignature(
    name: name,
    returnType: returnType,
    params: params,
  );
}
