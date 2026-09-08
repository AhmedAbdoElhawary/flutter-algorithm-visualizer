# Changelog

## [1.0.0] - 2026-09-08

First tracked release, and the start of automated delivery.

- The algorithm visualizer ships with its initial set of problems and the
  CoreDive UI.
- Three separate builds — dev, staging, and production — each talking to its own
  Firebase project so test data never mixes with real data.
- Merging to a branch now builds that flavor and pushes it straight to Firebase
  App Distribution, so testers always have the latest without anyone running a
  local build.
