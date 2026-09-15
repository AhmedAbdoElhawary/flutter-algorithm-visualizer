/// Python's semantic divergences, as data rather than as special cases
/// scattered through the runtime (research decision 3).
/// See `specs/007-multi-language-interpreter/data-model.md` §4, Python column.
library;

import '../../values/dialect.dart';

const pythonDialect = Dialect(
  /// `/` always produces a float, even for two whole numbers; `//` is the
  /// floor-division operator, and it floors toward negative infinity rather
  /// than truncating toward zero (`-7 // 2 == -4`, not `-3`).
  intDivisionYields: IntDivisionMode.floorFloat,

  /// `0`, `""`, `[]`, `{}`, `set()` and `None` are all falsy, so
  /// `if not queue:` is the idiomatic empty check.
  truthiness: TruthinessMode.pythonic,

  /// `1 == "1"` is `False`. Python does not coerce across types for `==`.
  equalityCoerces: false,
  defaultSortOrder: SortOrder.natural,

  /// Python has only `None`.
  hasUndefined: false,
  printsTrueAs: 'True',
  printsFalseAs: 'False',
  printsNullAs: 'None',

  /// `"abc"[0]` is `"a"`, a one-character string — Python has no char type.
  stringIndexYields: StringIndexResult.oneCharString,

  /// Declared for completeness. The VM stores whole numbers in Dart's 64-bit
  /// `int`, so a Python program that genuinely exceeds 2^63 will wrap rather
  /// than grow — out of scope for the problem bank, which stays well inside
  /// 64 bits.
  arbitraryPrecisionInts: true,

  /// `xs[-1]` is the last element.
  negativeIndexing: true,
);
