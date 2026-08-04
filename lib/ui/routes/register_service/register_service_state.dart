import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class RegisterServiceState {}

class RegisterServiceInitial extends RegisterServiceState {}

class RegisterServiceLoading extends RegisterServiceState {}

class RegisterServiceVehiclesLoaded extends RegisterServiceState {
  final List<VehicleEntity> vehicles;
  RegisterServiceVehiclesLoaded({required this.vehicles});
}

class RegisterServiceError extends RegisterServiceState {
  final String message;
  RegisterServiceError({required this.message});
}
