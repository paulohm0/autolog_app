import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IOilChangeRepository {
  Future<Either<Failure, void>> saveOilChange(OilChangeEntity oilChange);
  Future<Either<Failure, List<OilChangeEntity>>> getOilChanges();
}
