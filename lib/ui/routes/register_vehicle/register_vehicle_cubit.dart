import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:dartz/dartz.dart';

/// Não é um Cubit — a tela sai otimisticamente assim que o usuário toca em
/// salvar (ver [RegisterVehicleScreen._save]), então não existe estado de
/// loading/sucesso pra observar, só o resultado da gravação em si.
class RegisterVehicleCubit {
  final IVehicleRepository _repository;

  RegisterVehicleCubit({required IVehicleRepository repository})
    : _repository = repository;

  Future<Either<Failure, void>> saveVehicleFromForm({
    required String brand,
    required String model,
    required String licensePlate,
    required String year,
    required String color,
  }) {
    final vehicle = VehicleEntity(
      brand: brand,
      model: model,
      licensePlate: licensePlate,
      year: int.tryParse(year),
      color: color,
    );
    return saveVehicle(vehicle);
  }

  Future<Either<Failure, void>> saveVehicle(VehicleEntity vehicle) {
    return _repository.saveVehicle(vehicle);
  }

  Future<Either<Failure, void>> updateVehicleFromForm({
    required String id,
    required String brand,
    required String model,
    required String licensePlate,
    required String year,
    required String color,
  }) {
    final vehicle = VehicleEntity(
      id: id,
      brand: brand,
      model: model,
      licensePlate: licensePlate,
      year: int.tryParse(year),
      color: color,
    );
    return _repository.updateVehicle(vehicle);
  }
}
