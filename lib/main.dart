import 'package:algorithm_visualizer/core/material_app/my_app.dart';
import 'package:algorithm_visualizer/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Future.wait([
      GetStorage.init(),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);
  } catch (_) {}

  runApp(const ProviderScope(child: MyApp()));
}
