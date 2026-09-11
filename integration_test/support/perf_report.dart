import 'perf_models.dart';

/// Schema version of `contracts/perf-report.schema.json`. Bump only if the
/// contract itself changes.
const String perfReportSchemaVersion = '1.0.0';

/// Which side of the before/after comparison a [PerformanceBaseline] is.
enum BaselineLabel { before, after }

/// Which of the five main tab screens a [ScenarioReport] targets.
enum TargetScreen { home, visualize, code, practice, profile }

/// A build mode a gating run may be captured in. `debug` is intentionally
/// absent — constructing a report with that value must throw (FR-001).
enum ReportBuildMode { profile, release }

/// Whether the device was cold or soaked for 10 minutes before capture
/// (SC-008). Defaults to `cold` per the schema.
enum ThermalState { cold, warm }

final RegExp _gitShaPattern = RegExp(r'^[0-9a-f]{7,40}$');

/// The result of driving one screen or animation scenario once.
class ScenarioReport {
  ScenarioReport({
    required this.scenarioId,
    required this.screen,
    required this.steadyState,
    required this.warmup,
    this.tabSwitchMs,
    this.samples,
  }) : assert(tabSwitchMs == null || tabSwitchMs >= 0);

  final String scenarioId;
  final TargetScreen screen;

  /// The ONLY phase that gates pass/fail.
  final FrameStats steadyState;

  /// Reported against the SC-011 allowance. Never silently discarded (FR-020).
  final FrameStats warmup;

  /// Present only for tab-switch scenarios. Gate: < 300ms (SC-006).
  final double? tabSwitchMs;

  /// Optional raw per-frame data. Useful for diagnosis; not required for the gate.
  final List<FrameSample>? samples;

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'screen': screen.name,
        'steadyState': steadyState.toJson(),
        'warmup': warmup.toJson(),
        if (tabSwitchMs != null) 'tabSwitchMs': tabSwitchMs,
        if (samples != null) 'samples': samples!.map((s) => s.toJson()).toList(),
      };

  factory ScenarioReport.fromJson(Map<String, dynamic> json) => ScenarioReport(
        scenarioId: json['scenarioId'] as String,
        screen: TargetScreen.values.byName(json['screen'] as String),
        steadyState: FrameStats.fromJson(json['steadyState'] as Map<String, dynamic>),
        warmup: FrameStats.fromJson(json['warmup'] as Map<String, dynamic>),
        tabSwitchMs: (json['tabSwitchMs'] as num?)?.toDouble(),
        samples: (json['samples'] as List<dynamic>?)
            ?.map((s) => FrameSample.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

/// A committed [ScenarioReport] set that later runs are compared against
/// (FR-016, FR-017). Matches `contracts/perf-report.schema.json` exactly.
///
/// **Critical constraint**: the `before` baseline must be captured on an
/// unmodified tree — once rendering code changes, the original numbers are
/// unrecoverable.
class PerformanceBaseline {
  PerformanceBaseline({
    required this.label,
    required this.device,
    required this.buildMode,
    required this.gitSha,
    required this.capturedAt,
    required this.reports,
    this.thermalState = ThermalState.cold,
  }) : assert(_gitShaPattern.hasMatch(gitSha), 'gitSha must match ^[0-9a-f]{7,40}\$'),
       assert(reports.isNotEmpty, 'reports must contain at least one entry');

  final String schemaVersion = perfReportSchemaVersion;
  final BaselineLabel label;

  /// Must read `oppo-a5i` for a gating run.
  final String device;

  final ReportBuildMode buildMode;
  final String gitSha;
  final DateTime capturedAt;
  final List<ScenarioReport> reports;
  final ThermalState thermalState;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'label': label.name,
        'device': device,
        'buildMode': buildMode.name,
        'gitSha': gitSha,
        'capturedAt': capturedAt.toIso8601String(),
        'thermalState': thermalState.name,
        'reports': reports.map((r) => r.toJson()).toList(),
      };

  factory PerformanceBaseline.fromJson(Map<String, dynamic> json) {
    final buildMode = json['buildMode'] as String;
    if (buildMode == 'debug') {
      throw ArgumentError('buildMode "debug" invalidates the run (FR-001) — use profile or release');
    }
    return PerformanceBaseline(
      label: BaselineLabel.values.byName(json['label'] as String),
      device: json['device'] as String,
      buildMode: ReportBuildMode.values.byName(buildMode),
      gitSha: json['gitSha'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      thermalState: json['thermalState'] == null
          ? ThermalState.cold
          : ThermalState.values.byName(json['thermalState'] as String),
      reports: (json['reports'] as List<dynamic>)
          .map((r) => ScenarioReport.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
