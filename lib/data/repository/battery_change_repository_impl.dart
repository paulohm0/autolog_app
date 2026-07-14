import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/battery_change_model.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class BatteryChangeRepositoryImpl implements IBatteryChangeRepository {
  final FirebaseFirestore _firestoreDB;

  BatteryChangeRepositoryImpl({required FirebaseFirestore firestoreDB})
    : _firestoreDB = firestoreDB;

  @override
  Future<Either<Failure, void>> saveBatteryChange(
    BatteryChangeEntity batteryChange,
  ) async {
    try {
      final newBatteryChange = BatteryChangeModel(
        vehicleId: batteryChange.vehicleId,
        model: batteryChange.model,
        date: batteryChange.date,
      );

      await _firestoreDB
          .collection('battery_changes')
          .add(newBatteryChange.toJson());
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<BatteryChangeEntity>>> getBatteryChanges() async {
    try {
      final snapshot = await _firestoreDB
          .collection('battery_changes')
          .orderBy('date', descending: true)
          .get();
      final batteryChanges = snapshot.docs
          .map((doc) => BatteryChangeModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(batteryChanges);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
