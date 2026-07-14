import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterServiceCubit extends Cubit<RegisterServiceState> {
  final IMaintenanceRepository _maintenanceRepository;
  final IVehicleRepository _vehicleRepository;

  RegisterServiceCubit({
    required IMaintenanceRepository maintenanceRepository,
    required IVehicleRepository vehicleRepository,
  }) : _maintenanceRepository = maintenanceRepository,
       _vehicleRepository = vehicleRepository,
       super(RegisterServiceInitial());

  Future<void> loadVehicles() async {
    emit(RegisterServiceLoading());
    final result = await _vehicleRepository.getVehicles();
    result.fold(
      (failure) => emit(RegisterServiceError(message: failure.message)),
      (vehicles) => emit(RegisterServiceVehiclesLoaded(vehicles: vehicles)),
    );
  }

  Future<void> saveMaintenance({
    required String vehicleId,
    required DateTime date,
    required String workshop,
    required String description,
    required double value,
  }) async {
    emit(RegisterServiceLoading());
    final maintenance = MaintenanceEntity(
      vehicleId: vehicleId,
      date: date,
      workshop: workshop,
      description: description,
      value: value,
    );
    final result = await _maintenanceRepository.saveMaintenance(maintenance);
    result.fold(
      (failure) => emit(RegisterServiceError(message: failure.message)),
      (_) => emit(RegisterServiceSuccess()),
    );
  }
}
