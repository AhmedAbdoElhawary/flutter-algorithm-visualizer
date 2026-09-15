/// Dart's semantic divergences, per data-model.md §4's Dart column.
library;

import '../../values/dialect.dart';

const Dialect dartDialect = Dialect(
  intDivisionYields: IntDivisionMode.alwaysDouble,
  truthiness: TruthinessMode.boolOnly,
  equalityCoerces: false,
  defaultSortOrder: SortOrder.natural,
  hasUndefined: false,
  printsTrueAs: 'true',
  printsFalseAs: 'false',
  // data-model.md's table says `codeUnit` (real Dart has no `String.[]`
  // operator at all). This repo's 100-problem bank was written against the
  // legacy interpreter's convenience `s[i]` -> one-character-string
  // behavior, and T038's grading-parity gate is the tiebreaker: matching
  // established, working solutions beats matching the aspirational table.
  stringIndexYields: StringIndexResult.oneCharString,
  arbitraryPrecisionInts: false,
  negativeIndexing: false,
);
