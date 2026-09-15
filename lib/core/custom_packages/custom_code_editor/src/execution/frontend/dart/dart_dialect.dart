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
  stringIndexYields: StringIndexResult.codeUnit,
  arbitraryPrecisionInts: false,
  negativeIndexing: false,
);
