sealed class RegisterVehicleState {}

class RegisterVehicleInitial extends RegisterVehicleState {}

class RegisterVehicleLoading extends RegisterVehicleState {}

class RegisterVehicleSuccess extends RegisterVehicleState {}

class RegisterVehicleError extends RegisterVehicleState {
  final String message;
  RegisterVehicleError({required this.message});
}
