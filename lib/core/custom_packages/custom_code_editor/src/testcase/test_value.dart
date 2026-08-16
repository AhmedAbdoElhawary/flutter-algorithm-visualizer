/// Typed representation of a value parsed from a test-case string.
///
/// Values are parsed generically (JSON-like) from the raw test input. Custom
/// objects (e.g. `ListNode`) are represented as [ListTestValue] and later
/// turned into interpreted instances by the shape-aware object builder.
sealed class TestValue {
  const TestValue();
}

final class NullTestValue extends TestValue {
  const NullTestValue();
}

final class IntTestValue extends TestValue {
  const IntTestValue(this.value);

  final int value;
}

final class DoubleTestValue extends TestValue {
  const DoubleTestValue(this.value);

  final double value;
}

final class BoolTestValue extends TestValue {
  const BoolTestValue(this.value);

  final bool value;
}

final class StringTestValue extends TestValue {
  const StringTestValue(this.value);

  final String value;
}

final class ListTestValue extends TestValue {
  const ListTestValue(this.items);

  final List<TestValue> items;
}

/// Converts a [TestValue] into its plain Dart equivalent (ints, bools,
/// strings, nested lists and null). Useful so both the expected output and the
/// actual interpreted result can be serialized through the same code path.
dynamic testValueToRaw(TestValue value) {
  return switch (value) {
    NullTestValue() => null,
    IntTestValue(:final value) => value,
    DoubleTestValue(:final value) => value,
    BoolTestValue(:final value) => value,
    StringTestValue(:final value) => value,
    ListTestValue(:final items) => items.map(testValueToRaw).toList(),
  };
}
