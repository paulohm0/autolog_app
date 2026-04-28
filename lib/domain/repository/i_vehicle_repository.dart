import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IVehicleRepository {
  Future<Either<Failure, void>> saveVehicle(VehicleEntity vehicle);
  Future<Either<Failure, List<VehicleEntity>>> getVehicles();
}
