import 'package:autolog_app/core/constants/app_strings.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/firebase_options.dart';
import 'package:autolog_app/ui/routes/home/home_screen.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_screen.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/register_service': (context) => RegisterServiceScreen(),
        '/register_vehicle': (context) => RegisterVehicleScreen(),
      },
    );
  }
}
