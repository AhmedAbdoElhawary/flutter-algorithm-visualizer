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
/// container, see [appSettingsStorageProvider], because they are device level
/// and must survive signing in and out.
final localStorageProvider = Provider<LocalStorage>((ref) => GetStorageService(GetStorage()));

/// The named container holding device-level preferences.
///
/// `GetStorage` will happily hand back a container that has never been read
/// off disk — every `read` then returns `null` and every saved preference
/// looks like it was never there. So this name must also be passed to
/// `GetStorage.init` in `bootstrap.dart`; the two belong together.
const String appSettingsContainer = 'AppSettings';

/// Device-level preferences, behind the same [LocalStorage] interface as
/// everything else so a test can swap in an in-memory box.
final appSettingsStorageProvider =
    Provider<LocalStorage>((ref) => GetStorageService(GetStorage(appSettingsContainer)));
