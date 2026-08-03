import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final IMaintenanceRepository _maintenanceRepository;

  HomeCubit({required IMaintenanceRepository maintenanceRepository})
    : _maintenanceRepository = maintenanceRepository,
      super(HomeInitial());

  Future<void> loadHomeData() async {
    // Na primeira carga (app acabou de abrir), mostra o que já tinha em
    // cache local instantaneamente, sem esperar rede — evita o spinner
    // grande quando já existem dados de uma sessão anterior.
    if (state is HomeInitial) {
      final cachedResult = await _maintenanceRepository
          .getCachedMaintenances();
      if (isClosed) return;
      cachedResult.fold((_) {}, (cached) {
        if (cached.isNotEmpty) emit(HomeLoaded(maintenances: cached));
      });
    }
    // Só mostra o spinner se ainda não tem nada na tela (nem cache). Em
    // recargas seguintes (pull-to-refresh, após criar/editar/excluir), a
    // lista anterior continua visível enquanto atualiza por trás.
    if (state is HomeInitial) {
      emit(HomeLoading());
    }
    final maintenancesResult = await _maintenanceRepository.getMaintenances();
    if (isClosed) return;

    maintenancesResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (maintenances) => emit(HomeLoaded(maintenances: maintenances)),
    );
  }

  Future<Either<Failure, void>> deleteMaintenance(String id) async {
    final result = await _maintenanceRepository.deleteMaintenance(id);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadHomeData();
    }
    return result;
  }
}
