import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterVehicleCubit extends Cubit<RegisterVehicleState> {
  final IVehicleRepository _repository;

  RegisterVehicleCubit({required IVehicleRepository repository})
    : _repository = repository,
      super(RegisterVehicleInitial());

  Future<void> saveVehicleFromForm({
    required String brand,
    required String model,
    required String licensePlate,
    required String year,
    required String color,
  }) async {
    final vehicle = VehicleEntity(
      brand: brand,
      model: model,
      licensePlate: licensePlate,
      year: int.tryParse(year),
      color: color,
    );
    await saveVehicle(vehicle);
  }

  Future<void> saveVehicle(VehicleEntity vehicle) async {
    emit(RegisterVehicleLoading());
    final result = await _repository.saveVehicle(vehicle);
    if (isClosed) return;
    result.fold(
      (failure) => emit(RegisterVehicleError(message: failure.message)),
      (success) => emit(RegisterVehicleSuccess()),
    );
  }

  Future<void> updateVehicleFromForm({
    required String id,
    required String brand,
    required String model,
    required String licensePlate,
    required String year,
    required String color,
  }) async {
    final vehicle = VehicleEntity(
      id: id,
      brand: brand,
      model: model,
      licensePlate: licensePlate,
      year: int.tryParse(year),
      color: color,
    );
    emit(RegisterVehicleLoading());
    final result = await _repository.updateVehicle(vehicle);
    if (isClosed) return;
    result.fold(
      (failure) => emit(RegisterVehicleError(message: failure.message)),
      (success) => emit(RegisterVehicleSuccess()),
    );
  }
}
