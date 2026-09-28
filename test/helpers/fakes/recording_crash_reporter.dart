import 'package:algorithm_visualizer/core/monitoring/crash_reporter.dart';

/// Keeps every reported error so a test can check what reached the crash reporter.
class RecordingCrashReporter implements CrashReporter {
  final errors = <({Object error, bool fatal, Map<String, Object?>? context})>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    Map<String, Object?>? context,
  }) async =>
      errors.add((error: error, fatal: fatal, context: context));

  @override
  void addBreadcrumb(String message, {String? category}) {}

  @override
  void setUserId(String? id) {}
}
