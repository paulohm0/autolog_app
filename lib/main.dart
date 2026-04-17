import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AutoLogApp());
}

class AutoLogApp extends StatelessWidget {
  const AutoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'AutoLog', theme: AppTheme.theme);
  }
}
