import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IMaintenanceRepository {
  Future<Either<Failure, void>> saveMaintenance(MaintenanceEntity maintenance);
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenances();
  Future<Either<Failure, void>> updateMaintenance(
    MaintenanceEntity maintenance,
  );
  Future<Either<Failure, void>> deleteMaintenance(String id);
}
