enum PlaybackSpeed { slow, normal, fast3, fast5, fast10 }

extension PlaybackSpeedX on PlaybackSpeed {
  Duration get stepSearchingDuration => switch (this) {
        PlaybackSpeed.slow => const Duration(milliseconds: 300),
        PlaybackSpeed.normal => const Duration(milliseconds: 150),
        PlaybackSpeed.fast3 => const Duration(milliseconds: 55),
        PlaybackSpeed.fast5 => const Duration(milliseconds: 16),
        PlaybackSpeed.fast10 => const Duration(milliseconds: 10),
      };
  Duration get stepSortingDuration => switch (this) {
        PlaybackSpeed.slow => const Duration(milliseconds: 900),
        PlaybackSpeed.normal => const Duration(milliseconds: 300),
        PlaybackSpeed.fast3 => const Duration(milliseconds: 150),
        PlaybackSpeed.fast5 => const Duration(milliseconds: 100),
        PlaybackSpeed.fast10 => const Duration(milliseconds: 50),
      };

  int get level => switch (this) {
        PlaybackSpeed.slow => 1,
        PlaybackSpeed.normal => 2,
        PlaybackSpeed.fast3 => 3,
        PlaybackSpeed.fast5 => 5,
        PlaybackSpeed.fast10 => 10,
      };
}
