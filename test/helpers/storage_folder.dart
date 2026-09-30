import 'dart:io';

/// GetStorage writes its backup file in the background with nothing to await, so a delete can race it.
Future<void> deleteStorageFolder(Directory folder) async {
  for (var tries = 1; ; tries++) {
    try {
      folder.deleteSync(recursive: true);
      return;
    } on FileSystemException {
      if (tries == 5) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }
}
