import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_change_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OilChangeCubit extends Cubit<OilChangeState> {
  final IOilChangeRepository _oilChangeRepository;

  OilChangeCubit({required IOilChangeRepository oilChangeRepository})
    : _oilChangeRepository = oilChangeRepository,
      super(OilChangeInitial());

  Future<void> loadData() async {
    // Na primeira carga (app acabou de abrir), mostra o que já tinha em
    // cache local instantaneamente, sem esperar rede — evita o spinner
    // grande quando já existem dados de uma sessão anterior.
    if (state is OilChangeInitial) {
      final cachedResult = await _oilChangeRepository.getCachedOilChanges();
      if (isClosed) return;
      cachedResult.fold((_) {}, (cached) {
        if (cached.isNotEmpty) emit(OilChangeLoaded(oilChanges: cached));
      });
    }
    // Só mostra o spinner se ainda não tem nada na tela (nem cache). Em
    // recargas seguintes (pull-to-refresh, após criar/editar/excluir), a
    // lista anterior continua visível enquanto atualiza por trás.
    if (state is OilChangeInitial) {
      emit(OilChangeLoading());
    }
    final result = await _oilChangeRepository.getOilChanges();
    if (isClosed) return;
    result.fold(
      (failure) => emit(OilChangeError(message: failure.message)),
      (oilChanges) => emit(OilChangeLoaded(oilChanges: oilChanges)),
    );
  }

  Future<Either<Failure, void>> saveOilChange({
    required String vehicleId,
    required String brand,
    required double liters,
    required DateTime date,
  }) async {
    final oilChange = OilChangeEntity(
      vehicleId: vehicleId,
      brand: brand,
      liters: liters,
      date: date,
    );
    final result = await _oilChangeRepository.saveOilChange(oilChange);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
  }

  Future<Either<Failure, void>> updateOilChange({
    required String id,
    required String vehicleId,
    required String brand,
    required double liters,
    required DateTime date,
  }) async {
    final oilChange = OilChangeEntity(
      id: id,
      vehicleId: vehicleId,
      brand: brand,
      liters: liters,
      date: date,
    );
    final result = await _oilChangeRepository.updateOilChange(oilChange);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
  }

  Future<Either<Failure, void>> deleteOilChange(String id) async {
    final result = await _oilChangeRepository.deleteOilChange(id);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadData();
    }
    return result;
  }
}
