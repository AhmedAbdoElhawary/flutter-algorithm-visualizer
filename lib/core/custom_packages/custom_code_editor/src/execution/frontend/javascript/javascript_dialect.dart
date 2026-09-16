/// JavaScript's semantic divergences, as data rather than as special cases
/// scattered through the runtime (research decision 3).
/// See `specs/007-multi-language-interpreter/data-model.md` §4, JavaScript
/// column.
library;

import '../../values/dialect.dart';

const javascriptDialect = Dialect(
  /// One number type. `4 / 2` is `2` and `5 / 2` is `2.5`; there is no
  /// separate integer division operator.
  intDivisionYields: IntDivisionMode.singleNumber,

  /// `0`, `""`, `null`, `undefined` and `NaN` are falsy. Note that `[]` and
  /// `{}` are **truthy**, which is the opposite of Python and the single
  /// most common cross-language surprise.
  truthiness: TruthinessMode.jsLike,

  /// `false` here means the shared `==` opcode is **strict**, which is what
  /// `===` needs. Loose `==` is not a dialect setting because it is not a
  /// variation on equality so much as a different operator: the frontend
  /// lowers it to its own builtin, which implements the coercion rules
  /// properly rather than approximating them.
  equalityCoerces: false,

  /// `[10, 9, 1].sort()` gives `[1, 10, 9]`, because the default comparison
  /// is between the *strings*. Catching people out since 1995.
  defaultSortOrder: SortOrder.lexicographic,

  /// `undefined` (never assigned) is distinct from `null` (assigned nothing)
  /// at runtime, though grading collapses both (data-model.md §3 rule 2).
  hasUndefined: true,
  printsTrueAs: 'true',
  printsFalseAs: 'false',
  printsNullAs: 'null',

  /// `"abc"[0]` is `"a"` — JavaScript has no char type.
  stringIndexYields: StringIndexResult.oneCharString,
  arbitraryPrecisionInts: false,

  /// `xs[-1]` is `undefined`, not the last element.
  negativeIndexing: false,

  /// One number type, so a whole result prints whole.
  wholeFloatsPrintAsIntegers: true,

  /// One number type, so `xs[total / 2]` is an ordinary index.
  singleNumberType: true,

  /// An object literal is a map, and `o.b` is `o["b"]`.
  propertyAccessReadsMapKeys: true,

  /// `[1, 2][9]` is `undefined`, not an error.
  outOfRangeIndexIsUndefined: true,
);
