import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class RegisterVehicleState {}

class InitialState extends RegisterVehicleState {}

class LoadingState extends RegisterVehicleState {}

class SuccessState extends RegisterVehicleState {}

class VehicleListLoadedState extends RegisterVehicleState {
  final List<VehicleEntity> vehicles;
  VehicleListLoadedState({required this.vehicles});
}

class ErrorState extends RegisterVehicleState {
  final String message;
  ErrorState({required this.message});
}
