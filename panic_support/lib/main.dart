import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController();
  await settingsController.load();
  runApp(PanicSupportApp(settingsController: settingsController));
}
