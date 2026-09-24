import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbus/app/app.dart';
import 'package:nimbus/app/dependencies.dart';
import 'package:nimbus/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlayStyle);

  final dependencies = await AppDependencies.create();
  runApp(NimbusApp(dependencies: dependencies));
}
