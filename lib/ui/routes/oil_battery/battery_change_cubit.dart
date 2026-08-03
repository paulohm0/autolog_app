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
    // Na primeira carga (app acabou de abrir), mostra o que já tinha em
    // cache local instantaneamente, sem esperar rede — evita o spinner
    // grande quando já existem dados de uma sessão anterior.
    if (state is BatteryChangeInitial) {
      final cachedResult = await _batteryChangeRepository
          .getCachedBatteryChanges();
      if (isClosed) return;
      cachedResult.fold((_) {}, (cached) {
        if (cached.isNotEmpty) {
          emit(BatteryChangeLoaded(batteryChanges: cached));
        }
      });
    }
    // Só mostra o spinner se ainda não tem nada na tela (nem cache). Em
    // recargas seguintes (pull-to-refresh, após criar/editar/excluir), a
    // lista anterior continua visível enquanto atualiza por trás.
    if (state is BatteryChangeInitial) {
      emit(BatteryChangeLoading());
    }
    final result = await _batteryChangeRepository.getBatteryChanges();
    if (isClosed) return;
    result.fold(
      (failure) => emit(BatteryChangeError(message: failure.message)),
      (batteryChanges) =>
          emit(BatteryChangeLoaded(batteryChanges: batteryChanges)),
    );
  }

  Future<Either<Failure, void>> saveBatteryChange({
    required String vehicleId,
    required String model,
    required DateTime date,
  }) async {
    final batteryChange = BatteryChangeEntity(
      vehicleId: vehicleId,
      model: model,
      date: date,
    );
    final result = await _batteryChangeRepository.saveBatteryChange(
      batteryChange,
    );
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
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
