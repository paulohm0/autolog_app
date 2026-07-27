import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final IVehicleRepository _vehicleRepository;
  final IMaintenanceRepository _maintenanceRepository;

  HomeCubit({
    required IVehicleRepository vehicleRepository,
    required IMaintenanceRepository maintenanceRepository,
  }) : _vehicleRepository = vehicleRepository,
       _maintenanceRepository = maintenanceRepository,
       super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    final vehiclesResult = await _vehicleRepository.getVehicles();
    final maintenancesResult = await _maintenanceRepository.getMaintenances();
    if (isClosed) return;

    vehiclesResult.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (
        vehicles,
      ) {
        maintenancesResult.fold(
          (failure) => emit(HomeError(message: failure.message)),
          (maintenances) {
            final vehiclesById = {for (final v in vehicles) v.id!: v};
            emit(
              HomeLoaded(
                vehicleCount: vehicles.length,
                maintenances: maintenances,
                vehiclesById: vehiclesById,
              ),
            );
          },
        );
      },
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

  Future<Either<Failure, void>> deleteVehicle(String id) async {
    final result = await _vehicleRepository.deleteVehicle(id);
    if (isClosed) return result;
    if (result.isRight()) {
      await loadHomeData();
    }
    return result;
  }
}
