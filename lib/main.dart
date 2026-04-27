import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/home/view/home_screen.dart';
import 'package:autolog_app/ui/register_service/view/register_service_screen.dart';
import 'package:autolog_app/ui/register_vehicle/view/register_vehicle_screen.dart';
import 'package:flutter/material.dart';

void main() {
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
      initialRoute: '/register_vehicle',
      routes: {
        '/': (context) => HomeScreen(),
        '/register_service': (context) => RegisterServiceScreen(),
        '/register_vehicle': (context) => RegisterVehicleScreen(),
      },
    );
  }
}
