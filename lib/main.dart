import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/routes/app_routes.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupDependencyInjection();
  runApp(const AutoLogApp());
}

class AutoLogApp extends StatelessWidget {
  const AutoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appBrandName,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
