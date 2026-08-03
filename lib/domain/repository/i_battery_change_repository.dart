import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IBatteryChangeRepository {
  Future<Either<Failure, void>> saveBatteryChange(
    BatteryChangeEntity batteryChange,
  );
  Future<Either<Failure, List<BatteryChangeEntity>>> getBatteryChanges();

  /// Lê só do cache local (sem esperar rede) — usado pra mostrar dados da
  /// última sessão instantaneamente enquanto [getBatteryChanges] busca no
  /// servidor por trás. Retorna [Failure] se não houver nada em cache ainda.
  Future<Either<Failure, List<BatteryChangeEntity>>> getCachedBatteryChanges();
  Future<Either<Failure, void>> updateBatteryChange(
    BatteryChangeEntity batteryChange,
  );
  Future<Either<Failure, void>> deleteBatteryChange(String id);
}
