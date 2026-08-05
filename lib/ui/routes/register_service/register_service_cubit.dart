import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_state.dart';
import 'package:dartz/dartz.dart';
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
    if (isClosed) return;
    result.fold(
      (failure) => emit(RegisterServiceError(message: failure.message)),
      (vehicles) => emit(RegisterServiceVehiclesLoaded(vehicles: vehicles)),
    );
  }

  /// Não emite estado de loading/sucesso — a tela sai otimisticamente assim
  /// que o usuário toca em salvar (ver [RegisterServiceScreen._save]), então
  /// só o resultado (sucesso ou erro) importa aqui.
  Future<Either<Failure, void>> saveMaintenance({
    required String vehicleId,
    required DateTime date,
    required String workshop,
    required String description,
    required double value,
    required bool hasOilChange,
    String? oilBrand,
    double? oilLiters,
    required bool hasBatteryChange,
    String? batteryModel,
    String? batteryCapacity,
  }) {
    final maintenance = MaintenanceEntity(
      vehicleId: vehicleId,
      date: date,
      workshop: workshop,
      description: description,
      value: value,
      hasOilChange: hasOilChange,
      oilBrand: oilBrand,
      oilLiters: oilLiters,
      hasBatteryChange: hasBatteryChange,
      batteryModel: batteryModel,
      batteryCapacity: batteryCapacity,
    );
    return _maintenanceRepository.saveMaintenance(maintenance);
  }

  Future<Either<Failure, void>> updateMaintenance({
    required String id,
    required String vehicleId,
    required DateTime date,
    required String workshop,
    required String description,
    required double value,
    required bool hasOilChange,
    String? oilBrand,
    double? oilLiters,
    required bool hasBatteryChange,
    String? batteryModel,
    String? batteryCapacity,
  }) {
    final maintenance = MaintenanceEntity(
      id: id,
      vehicleId: vehicleId,
      date: date,
      workshop: workshop,
      description: description,
      value: value,
      hasOilChange: hasOilChange,
      oilBrand: oilBrand,
      oilLiters: oilLiters,
      hasBatteryChange: hasBatteryChange,
      batteryModel: batteryModel,
      batteryCapacity: batteryCapacity,
    );
    return _maintenanceRepository.updateMaintenance(maintenance);
  }
}
