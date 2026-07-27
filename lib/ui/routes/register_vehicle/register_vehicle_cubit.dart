import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterVehicleCubit extends Cubit<RegisterVehicleState> {
  final IVehicleRepository _repository;

  RegisterVehicleCubit({required IVehicleRepository repository})
    : _repository = repository,
      super(InitialState());

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
    emit(LoadingState());
    final result = await _repository.saveVehicle(vehicle);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ErrorState(message: failure.message)),
      (success) => emit(SuccessState()),
    );
  }

  Future<void> getVehicles() async {
    emit(LoadingState());
    final result = await _repository.getVehicles();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ErrorState(message: failure.message)),
      (vehicles) => emit(VehicleListLoadedState(vehicles: vehicles)),
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
    emit(LoadingState());
    final result = await _repository.updateVehicle(vehicle);
    if (isClosed) return;
    result.fold(
      (failure) => emit(ErrorState(message: failure.message)),
      (success) => emit(SuccessState()),
    );
  }
}
