import 'package:autolog_app/ui/routes/home/home_screen.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_screen.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String registerService = '/register_service';
  static const String registerVehicle = '/register_vehicle';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    registerService: (context) => const RegisterServiceScreen(),
    registerVehicle: (context) => const RegisterVehicleScreen(),
  };
}
