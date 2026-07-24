import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/oil_battery/oil_change_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OilChangeCubit extends Cubit<OilChangeState> {
  final IOilChangeRepository _oilChangeRepository;
  final IVehicleRepository _vehicleRepository;

  OilChangeCubit({
    required IOilChangeRepository oilChangeRepository,
    required IVehicleRepository vehicleRepository,
  }) : _oilChangeRepository = oilChangeRepository,
       _vehicleRepository = vehicleRepository,
       super(OilChangeInitial());

  Future<void> loadData() async {
    emit(OilChangeLoading());
    final vehiclesResult = await _vehicleRepository.getVehicles();
    final oilChangesResult = await _oilChangeRepository.getOilChanges();
    if (isClosed) return;

    vehiclesResult.fold((failure) => emit(OilChangeError(message: failure.message)), (
      vehicles,
    ) {
      oilChangesResult.fold(
        (failure) => emit(OilChangeError(message: failure.message)),
        (oilChanges) => emit(
          OilChangeLoaded(vehicles: vehicles, oilChanges: oilChanges),
        ),
      );
    });
  }

  Future<void> saveOilChange({
    required String vehicleId,
    required String brand,
    required double liters,
    required DateTime date,
  }) async {
    emit(OilChangeLoading());
    final oilChange = OilChangeEntity(
      vehicleId: vehicleId,
      brand: brand,
      liters: liters,
      date: date,
    );
    final result = await _oilChangeRepository.saveOilChange(oilChange);
    if (isClosed) return;
    result.fold(
      (failure) => emit(OilChangeError(message: failure.message)),
      (_) => emit(OilChangeSaveSuccess()),
    );
  }
}
