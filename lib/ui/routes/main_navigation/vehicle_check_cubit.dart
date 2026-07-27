import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VehicleCheckCubit extends Cubit<VehicleCheckState> {
  final IVehicleRepository _vehicleRepository;

  VehicleCheckCubit({required IVehicleRepository vehicleRepository})
    : _vehicleRepository = vehicleRepository,
      super(VehicleCheckLoading());

  Future<void> checkVehicles() async {
    emit(VehicleCheckLoading());
    final result = await _vehicleRepository.getVehicles();
    if (isClosed) return;
    result.fold(
      (failure) => emit(VehicleCheckError(message: failure.message)),
      (vehicles) => emit(
        vehicles.isEmpty ? VehicleCheckNoVehicles() : VehicleCheckHasVehicles(),
      ),
    );
  }
}
