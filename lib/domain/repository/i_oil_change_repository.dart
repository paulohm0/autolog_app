import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:dartz/dartz.dart';

abstract class IOilChangeRepository {
  Future<Either<Failure, void>> saveOilChange(OilChangeEntity oilChange);
  Future<Either<Failure, List<OilChangeEntity>>> getOilChanges();

  /// Lê só do cache local (sem esperar rede) — usado pra mostrar dados da
  /// última sessão instantaneamente enquanto [getOilChanges] busca no
  /// servidor por trás. Retorna [Failure] se não houver nada em cache ainda.
  Future<Either<Failure, List<OilChangeEntity>>> getCachedOilChanges();
  Future<Either<Failure, void>> updateOilChange(OilChangeEntity oilChange);
  Future<Either<Failure, void>> deleteOilChange(String id);
}
