import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/cubit/vehicle_list_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Fonte única da lista de veículos do usuário, compartilhada por todas as
/// telas (registrado como lazy singleton, não factory). Sempre que um
/// veículo é criado/editado/excluído em qualquer tela, quem fez a alteração
/// chama [loadVehicles] aqui pra manter as outras telas atualizadas, sem
/// que cada uma precise buscar os veículos por conta própria.
class VehicleListCubit extends Cubit<VehicleListState> {
  final IVehicleRepository _repository;

  VehicleListCubit({required IVehicleRepository repository})
    : _repository = repository,
      super(VehicleListInitial());

  Future<void> loadVehicles() async {
    emit(VehicleListLoading());
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
}
