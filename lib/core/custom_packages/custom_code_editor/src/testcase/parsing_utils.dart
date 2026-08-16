/// Low-level helpers for splitting a string by a top-level delimiter while
/// respecting nested brackets and quoted strings.
library;

int topLevelOpenParen(String s, [int offset = 0]) {
  for (var i = offset; i < s.length; i++) {
    if (s[i] == '(') return i;
  }
  return -1;
}

int matchingParen(String s, int openIndex) {
  var depth = 0;
  var inSingle = false;
  var inDouble = false;
  for (var i = openIndex; i < s.length; i++) {
    final c = s[i];
    if (c == "'" && !inDouble) {
      inSingle = !inSingle;
      continue;
    }
    if (c == '"' && !inSingle) {
      inDouble = !inDouble;
      continue;
    }
    if (inSingle || inDouble) continue;
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}

/// Splits [s] on [delimiter] ignoring any that appear inside brackets `()[]{}`
/// or inside quoted strings.
List<String> splitTopLevel(
  String s, [
  String delimiter = ',',
]) {
  if (s.isEmpty) return const [];

  final parts = <String>[];
  var depth = 0;
  var inSingle = false;
  var inDouble = false;
  var current = StringBuffer();
  var i = 0;
  while (i < s.length) {
    final c = s[i];
    if (c == "'" && !inDouble) {
      inSingle = !inSingle;
      current.write(c);
      i++;
      continue;
    }
    if (c == '"' && !inSingle) {
      inDouble = !inDouble;
      current.write(c);
      i++;
      continue;
    }
    if (inSingle || inDouble) {
      current.write(c);
      i++;
      continue;
    }
    switch (c) {
      case '(' || '[' || '{':
        depth++;
      case ')' || ']' || '}':
        depth--;
      default:
        if (depth == 0 && s.startsWith(delimiter, i)) {
          parts.add(current.toString().trim());
          current = StringBuffer();
          i += delimiter.length;
          continue;
        }
    }
    current.write(c);
    i++;
  }
  parts.add(current.toString().trim());
  return parts;
}
