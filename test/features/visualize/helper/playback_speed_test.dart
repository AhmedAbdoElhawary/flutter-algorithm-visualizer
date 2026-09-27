import 'package:algorithm_visualizer/features/visualize/helper/playback_speed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each speed has its level and step times', () {
    final expected = {
      PlaybackSpeed.slow: (1, 900, 900),
      PlaybackSpeed.normal: (2, 300, 300),
      PlaybackSpeed.fast3: (3, 70, 150),
      PlaybackSpeed.fast5: (5, 20, 100),
      PlaybackSpeed.fast10: (10, 10, 50),
    };

    expect(expected.keys, PlaybackSpeed.values);
    for (final MapEntry(key: speed, value: (level, searchMs, sortMs)) in expected.entries) {
      expect(speed.level, level, reason: speed.name);
      expect(speed.stepSearchingDuration, Duration(milliseconds: searchMs), reason: speed.name);
      expect(speed.stepSortingDuration, Duration(milliseconds: sortMs), reason: speed.name);
    }
  });

  test('every faster speed has shorter steps', () {
    for (var i = 1; i < PlaybackSpeed.values.length; i++) {
      final slower = PlaybackSpeed.values[i - 1];
      final faster = PlaybackSpeed.values[i];

      expect(faster.stepSortingDuration, lessThan(slower.stepSortingDuration));
      expect(faster.stepSearchingDuration, lessThan(slower.stepSearchingDuration));
    }
  });
}
