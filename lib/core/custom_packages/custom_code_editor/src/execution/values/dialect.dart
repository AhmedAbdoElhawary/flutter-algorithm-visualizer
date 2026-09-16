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
    this.wholeFloatsPrintAsIntegers = false,
    this.singleNumberType = false,
    this.propertyAccessReadsMapKeys = false,
    this.outOfRangeIndexIsUndefined = false,
    this.sequenceRepetition = false,
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

  /// Whether a float that happens to be whole prints without its fraction.
  /// JavaScript has one number type, so `4 / 2` is `2`, not `2.0`. Dart and
  /// Python both keep the distinction visible.
  final bool wholeFloatsPrintAsIntegers;

  /// Whether the language has one number type rather than separate integers
  /// and floats. True for JavaScript, where `total / 2` is simply a number and
  /// `xs[total / 2]` is an ordinary index. Dart and Python both reject a
  /// fractional value there, and so must this engine.
  final bool singleNumberType;

  /// Whether `a.b` on a map reads the entry under `"b"`.
  ///
  /// True for JavaScript only, where an object literal *is* a map and `.b`
  /// and `["b"]` are the same lookup. Leaving it false elsewhere keeps
  /// `someMap.foo` an error in Dart and Python, where it is a genuine
  /// mistake rather than the ordinary way to read a field.
  final bool propertyAccessReadsMapKeys;

  /// Whether reading past the end of a list gives `undefined` instead of
  /// failing. JavaScript alone says yes — `[1, 2][9]` is `undefined`, not an
  /// error — which is why a JavaScript off-by-one shows up as a strange
  /// answer rather than as a crash.
  final bool outOfRangeIndexIsUndefined;

  /// Whether `*` repeats a list or a string. Python alone says yes: `[0] * n`
  /// is how you build a zeroed list and `"-" * 20` how you draw a rule.
  /// Elsewhere multiplying a sequence is a type error, and should stay one.
  final bool sequenceRepetition;
  final StringIndexResult stringIndexYields;
  final bool arbitraryPrecisionInts;
  final bool negativeIndexing;
}
