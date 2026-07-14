import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IBatteryChangeRepository {
  Future<Either<Failure, void>> saveBatteryChange(
    BatteryChangeEntity batteryChange,
  );
  Future<Either<Failure, List<BatteryChangeEntity>>> getBatteryChanges();
}
