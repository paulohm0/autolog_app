import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/oil_battery/battery_change_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryChangeCubit extends Cubit<BatteryChangeState> {
  final IBatteryChangeRepository _batteryChangeRepository;
  final IVehicleRepository _vehicleRepository;

  BatteryChangeCubit({
    required IBatteryChangeRepository batteryChangeRepository,
    required IVehicleRepository vehicleRepository,
  }) : _batteryChangeRepository = batteryChangeRepository,
       _vehicleRepository = vehicleRepository,
       super(BatteryChangeInitial());

  Future<void> loadData() async {
    emit(BatteryChangeLoading());
    final vehiclesResult = await _vehicleRepository.getVehicles();
    final batteryChangesResult = await _batteryChangeRepository
        .getBatteryChanges();
    if (isClosed) return;

    vehiclesResult.fold((failure) => emit(BatteryChangeError(message: failure.message)), (
      vehicles,
    ) {
      batteryChangesResult.fold(
        (failure) => emit(BatteryChangeError(message: failure.message)),
        (batteryChanges) => emit(
          BatteryChangeLoaded(vehicles: vehicles, batteryChanges: batteryChanges),
        ),
      );
    });
  }

  Future<void> saveBatteryChange({
    required String vehicleId,
    required String model,
    required DateTime date,
  }) async {
    emit(BatteryChangeLoading());
    final batteryChange = BatteryChangeEntity(
      vehicleId: vehicleId,
      model: model,
      date: date,
    );
    final result = await _batteryChangeRepository.saveBatteryChange(
      batteryChange,
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(BatteryChangeError(message: failure.message)),
      (_) => emit(BatteryChangeSaveSuccess()),
    );
  }
}
