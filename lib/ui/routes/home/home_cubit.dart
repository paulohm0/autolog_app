import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Fonte única do histórico de manutenção (inclui os itens de óleo/bateria,
// que são manutenções marcadas — ver MaintenanceEntity), compartilhada
// entre Home e a aba Óleo/Bateria. Registrado como lazy singleton, não
// factory, pra editar/criar/excluir em qualquer tela refletir na outra sem
// plumbing extra.
class HomeCubit extends Cubit<HomeState> {
  final IMaintenanceRepository _maintenanceRepository;

  HomeCubit({required IMaintenanceRepository maintenanceRepository})
    : _maintenanceRepository = maintenanceRepository,
      super(HomeInitial());

  /// Garante que a lista foi carregada ao menos uma vez, sem forçar um novo
  /// fetch se algum outro ponto do app já carregou.
  Future<void> ensureLoaded() async {
    if (state is HomeInitial) {
      await loadHomeData();
    }
  }

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

  /// Descarta a lista carregada. Chamado no logout — sem isso, o próximo
  /// usuário a logar no mesmo aparelho veria o histórico da conta anterior,
  /// já que este cubit é um singleton compartilhado entre todas as telas.
  void reset() {
    emit(HomeInitial());
  }
}
