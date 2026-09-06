import 'package:algorithm_visualizer/core/storage/get_storage_service.dart';
import 'package:algorithm_visualizer/core/storage/storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

/// The single default [GetStorage] container shared by every local data source.
///
/// Kept as one provider so the whole app writes to the same box and tests can
/// swap in an in-memory implementation with a single override.
///
/// The app settings (language / theme) deliberately live in their own named
/// container, see `AppSettingsNotifier`, because they are device level and must
/// survive signing in and out.
final localStorageProvider = Provider<LocalStorage>((ref) => GetStorageService(GetStorage()));
