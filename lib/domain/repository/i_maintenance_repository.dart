import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IMaintenanceRepository {
  Future<Either<Failure, void>> saveMaintenance(MaintenanceEntity maintenance);
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenances();

  /// Lê só do cache local (sem esperar rede) — usado pra mostrar dados da
  /// última sessão instantaneamente enquanto [getMaintenances] busca no
  /// servidor por trás. Retorna [Failure] se não houver nada em cache ainda.
  Future<Either<Failure, List<MaintenanceEntity>>> getCachedMaintenances();
  Future<Either<Failure, void>> updateMaintenance(
    MaintenanceEntity maintenance,
  );
  Future<Either<Failure, void>> deleteMaintenance(String id);
}
