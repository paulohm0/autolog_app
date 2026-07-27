sealed class VehicleCheckState {}

class VehicleCheckLoading extends VehicleCheckState {}

class VehicleCheckHasVehicles extends VehicleCheckState {}

class VehicleCheckNoVehicles extends VehicleCheckState {}

class VehicleCheckError extends VehicleCheckState {
  final String message;
  VehicleCheckError({required this.message});
}
