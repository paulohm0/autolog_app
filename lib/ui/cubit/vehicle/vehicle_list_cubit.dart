import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Registros de manutenção/óleo/bateria vinculados a um veículo específico,
/// usado pra avisar o usuário antes de excluir um veículo que já tem
/// histórico (ver [VehicleListCubit.getLinkedRecords]).
class VehicleLinkedRecords {
  final List<MaintenanceEntity> maintenances;
  final List<OilChangeEntity> oilChanges;
  final List<BatteryChangeEntity> batteryChanges;

  const VehicleLinkedRecords({
    required this.maintenances,
    required this.oilChanges,
    required this.batteryChanges,
  });

  bool get isEmpty =>
      maintenances.isEmpty && oilChanges.isEmpty && batteryChanges.isEmpty;
}

// Fonte única da lista de veículos do usuário, compartilhada por todas as
// telas (registrado como lazy singleton, não factory). Sempre que um
// veículo é criado/editado/excluído em qualquer tela, quem fez a alteração
// chama [loadVehicles] aqui pra manter as outras telas atualizadas, sem
// que cada uma precise buscar os veículos por conta própria.
class VehicleListCubit extends Cubit<VehicleListState> {
  final IVehicleRepository _repository;
  final IMaintenanceRepository _maintenanceRepository;
  final IOilChangeRepository _oilChangeRepository;
  final IBatteryChangeRepository _batteryChangeRepository;

  VehicleListCubit({
    required IVehicleRepository repository,
    required IMaintenanceRepository maintenanceRepository,
    required IOilChangeRepository oilChangeRepository,
    required IBatteryChangeRepository batteryChangeRepository,
  }) : _repository = repository,
       _maintenanceRepository = maintenanceRepository,
       _oilChangeRepository = oilChangeRepository,
       _batteryChangeRepository = batteryChangeRepository,
       super(VehicleListInitial());

  Future<void> loadVehicles() async {
    // Na primeira carga (app acabou de abrir), mostra o que já tinha em
    // cache local instantaneamente, sem esperar rede — evita o spinner
    // grande quando já existem dados de uma sessão anterior.
    if (state is VehicleListInitial) {
      final cachedResult = await _repository.getCachedVehicles();
      if (isClosed) return;
      cachedResult.fold((_) {}, (cached) {
        if (cached.isNotEmpty) emit(VehicleListLoaded(vehicles: cached));
      });
    }
    // Só mostra o spinner se ainda não tem nada na tela (nem cache). Em
    // recargas seguintes (pull-to-refresh, após criar/editar/excluir), a
    // lista anterior continua visível enquanto atualiza por trás.
    if (state is VehicleListInitial) {
      emit(VehicleListLoading());
    }
    final result = await _repository.getVehicles();
    if (isClosed) return;
    result.fold(
      (failure) => emit(VehicleListError(message: failure.message)),
      (vehicles) => emit(VehicleListLoaded(vehicles: vehicles)),
    );
  }

  /// Garante que a lista foi carregada ao menos uma vez, sem forçar um novo
  /// fetch se algum outro ponto do app já carregou.
  Future<void> ensureLoaded() async {
    if (state is VehicleListInitial) {
      await loadVehicles();
    }
  }

  Future<Either<Failure, void>> deleteVehicle(String id) async {
    final result = await _repository.deleteVehicle(id);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadVehicles();
    }
    return result;
  }

  /// Busca manutenções/trocas de óleo/trocas de bateria vinculadas a
  /// [vehicleId], pra avisar o usuário antes de excluir um veículo com
  /// histórico. Usado junto de [deleteVehicleCascade].
  Future<Either<Failure, VehicleLinkedRecords>> getLinkedRecords(
    String vehicleId,
  ) async {
    final maintenancesFuture = _maintenanceRepository.getMaintenances();
    final oilChangesFuture = _oilChangeRepository.getOilChanges();
    final batteryChangesFuture = _batteryChangeRepository.getBatteryChanges();

    final maintenancesResult = await maintenancesFuture;
    final oilChangesResult = await oilChangesFuture;
    final batteryChangesResult = await batteryChangesFuture;

    Failure? failure;
    final maintenances = maintenancesResult.fold((f) {
      failure = f;
      return const <MaintenanceEntity>[];
    }, (list) => list);
    final oilChanges = oilChangesResult.fold((f) {
      failure ??= f;
      return const <OilChangeEntity>[];
    }, (list) => list);
    final batteryChanges = batteryChangesResult.fold((f) {
      failure ??= f;
      return const <BatteryChangeEntity>[];
    }, (list) => list);

    if (failure != null) return Left(failure!);

    return Right(
      VehicleLinkedRecords(
        maintenances: maintenances
            .where((m) => m.vehicleId == vehicleId)
            .toList(),
        oilChanges: oilChanges.where((o) => o.vehicleId == vehicleId).toList(),
        batteryChanges: batteryChanges
            .where((b) => b.vehicleId == vehicleId)
            .toList(),
      ),
    );
  }

  /// Exclui o veículo e todo o histórico vinculado a ele ([linkedRecords],
  /// obtido via [getLinkedRecords]). Se algum registro falhar ao excluir, a
  /// operação para e retorna o erro sem excluir o veículo.
  Future<Either<Failure, void>> deleteVehicleCascade(
    String vehicleId,
    VehicleLinkedRecords linkedRecords,
  ) async {
    for (final maintenance in linkedRecords.maintenances) {
      final result = await _maintenanceRepository.deleteMaintenance(
        maintenance.id!,
      );
      if (result.isLeft()) return result;
    }
    for (final oilChange in linkedRecords.oilChanges) {
      final result = await _oilChangeRepository.deleteOilChange(
        oilChange.id!,
      );
      if (result.isLeft()) return result;
    }
    for (final batteryChange in linkedRecords.batteryChanges) {
      final result = await _batteryChangeRepository.deleteBatteryChange(
        batteryChange.id!,
      );
      if (result.isLeft()) return result;
    }

    return deleteVehicle(vehicleId);
  }

  /// Descarta a lista carregada. Chamado no logout — sem isso, o próximo
  /// usuário a logar no mesmo aparelho veria os veículos da conta anterior,
  /// já que este cubit é um singleton compartilhado entre todas as telas.
  void reset() {
    emit(VehicleListInitial());
  }
}
