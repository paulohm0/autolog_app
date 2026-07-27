import 'package:autolog_app/ui/routes/login/login_screen.dart';
import 'package:autolog_app/ui/routes/main_navigation/main_gate.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_screen.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String registerService = '/register_service';
  static const String registerVehicle = '/register_vehicle';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    home: (context) => const MainGate(),
    registerService: (context) => const RegisterServiceScreen(),
    registerVehicle: (context) => const RegisterVehicleScreen(),
  };
}
