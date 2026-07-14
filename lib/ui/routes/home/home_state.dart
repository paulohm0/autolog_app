import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int vehicleCount;
  final List<MaintenanceEntity> maintenances;
  final Map<String, VehicleEntity> vehiclesById;

  HomeLoaded({
    required this.vehicleCount,
    required this.maintenances,
    required this.vehiclesById,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
