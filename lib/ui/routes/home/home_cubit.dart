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
    emit(HomeLoading());
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
