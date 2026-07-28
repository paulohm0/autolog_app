import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:autolog_app/ui/routes/oil_battery/battery_change_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BatteryChangeCubit extends Cubit<BatteryChangeState> {
  final IBatteryChangeRepository _batteryChangeRepository;

  BatteryChangeCubit({
    required IBatteryChangeRepository batteryChangeRepository,
  }) : _batteryChangeRepository = batteryChangeRepository,
       super(BatteryChangeInitial());

  Future<void> loadData() async {
    emit(BatteryChangeLoading());
    final result = await _batteryChangeRepository.getBatteryChanges();
    if (isClosed) return;
    result.fold(
      (failure) => emit(BatteryChangeError(message: failure.message)),
      (batteryChanges) =>
          emit(BatteryChangeLoaded(batteryChanges: batteryChanges)),
    );
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

  Future<Either<Failure, void>> updateBatteryChange({
    required String id,
    required String vehicleId,
    required String model,
    required DateTime date,
  }) async {
    final batteryChange = BatteryChangeEntity(
      id: id,
      vehicleId: vehicleId,
      model: model,
      date: date,
    );
    final result = await _batteryChangeRepository.updateBatteryChange(
      batteryChange,
    );
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
  }

  Future<Either<Failure, void>> deleteBatteryChange(String id) async {
    final result = await _batteryChangeRepository.deleteBatteryChange(id);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
  }
}
