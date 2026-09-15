/// One per language. Makes every semantic divergence an explicit, testable
/// policy instead of an accident (research decision 3).
/// See `specs/007-multi-language-interpreter/data-model.md` §4.
library;

/// What `/` on two whole numbers yields.
enum IntDivisionMode {
  /// Dart: always a `double`.
  alwaysDouble,

  /// Python: `/` yields a float; `//` floors.
  floorFloat,

  /// JavaScript: one number type — `/` yields a number, possibly fractional.
  singleNumber,
}

enum TruthinessMode {
  /// Dart: only an actual `bool` is truthy/falsy.
  boolOnly,

  /// Python: `0`, `""`, `[]`, `{}`, `None` are falsy.
  pythonic,

  /// JavaScript: `0`, `""`, `null`, `undefined`, `NaN` are falsy.
  jsLike,
}

enum SortOrder { natural, lexicographic }

enum StringIndexResult { codeUnit, oneCharString }

class Dialect {
  const Dialect({
    required this.intDivisionYields,
    required this.truthiness,
    required this.equalityCoerces,
    required this.defaultSortOrder,
    required this.hasUndefined,
    required this.printsTrueAs,
    required this.printsFalseAs,
    this.printsNullAs = 'null',
    required this.stringIndexYields,
    required this.arbitraryPrecisionInts,
    required this.negativeIndexing,
  });

  final IntDivisionMode intDivisionYields;
  final TruthinessMode truthiness;
  final bool equalityCoerces;
  final SortOrder defaultSortOrder;
  final bool hasUndefined;
  final String printsTrueAs;
  final String printsFalseAs;

  /// How the absent value prints: `null` in Dart and JavaScript, `None` in
  /// Python. Defaulted, since only Python differs.
  final String printsNullAs;
  final StringIndexResult stringIndexYields;
  final bool arbitraryPrecisionInts;
  final bool negativeIndexing;
}
