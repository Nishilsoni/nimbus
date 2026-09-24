import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/app/app.dart';
import 'package:nimbus/app/dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the system bars; each screen picks readable bar icons for
  // its palette with an AnnotatedRegion.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final dependencies = await AppDependencies.create();
  runApp(NimbusApp(dependencies: dependencies));
}
