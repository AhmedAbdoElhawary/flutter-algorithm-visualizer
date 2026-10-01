import 'dart:io';

import 'package:algorithm_visualizer/config/routes/route_app.dart';
import 'package:algorithm_visualizer/core/material_app/splash_gate.dart';
import 'package:algorithm_visualizer/core/storage/storage_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

const projectId = 'demo-algodive';

/// The Android emulator reaches the host machine through 10.0.2.2.
final emulatorHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';

/// Wipes the emulators and everything saved on the device, so each journey starts like a fresh install.
Future<void> resetAll() async {
  await emulatorRequest('DELETE', 9099, '/emulator/v1/projects/$projectId/accounts');
  await emulatorRequest('DELETE', 8080, '/emulator/v1/projects/$projectId/databases/(default)/documents');
  await resetDevice();
}

/// The offline run can't reach the emulators, so it only wipes the device.
Future<void> resetDevice() async {
  await FirebaseAuth.instance.signOut();
  await GetStorage().erase();
  await GetStorage(appSettingsContainer).erase();
}

/// "Bearer owner" lets the emulator skip its security rules for these admin calls.
Future<String> emulatorRequest(String method, int port, String path) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(method, Uri.parse('http://$emulatorHost:$port$path'));
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    final response = await request.close();
    final body = await response.transform(const SystemEncoding().decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('$method $path: ${response.statusCode} $body');
    }
    return body;
  } finally {
    client.close();
  }
}

/// Starts the app the way `bootstrap` does. Unmounting first means a second call is a real relaunch.
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  AppRoutes.debugReset();
  await tester.pumpWidget(const ProviderScope(child: SplashGate()));
}

/// For waits on a Firebase emulator call, which can take seconds on a busy machine.
const networkTimeout = Duration(seconds: 30);

/// Some screens keep an animation looping, so `pumpAndSettle` would never return.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('Timed out waiting for $finder\nOn screen: ${_screenText()}');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// What a failed wait saw, since a CI run has no screen to look at.
List<String> _screenText() => [
  for (final text in find.byType(Text).evaluate().map((element) => element.widget as Text))
    if (text.data case final data? when data.trim().isNotEmpty) data,
];
