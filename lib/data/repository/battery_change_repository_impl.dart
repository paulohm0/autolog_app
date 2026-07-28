import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/battery_change_model.dart';
import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/repository/i_battery_change_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BatteryChangeRepositoryImpl implements IBatteryChangeRepository {
  final FirebaseFirestore _firestoreDB;
  final FirebaseAuth _firebaseAuth;

  BatteryChangeRepositoryImpl({
    required FirebaseFirestore firestoreDB,
    required FirebaseAuth firebaseAuth,
  }) : _firestoreDB = firestoreDB,
       _firebaseAuth = firebaseAuth;

  @override
  Future<Either<Failure, void>> saveBatteryChange(
    BatteryChangeEntity batteryChange,
  ) async {
    try {
      final newBatteryChange = BatteryChangeModel(
        userId: _firebaseAuth.currentUser!.uid,
        vehicleId: batteryChange.vehicleId,
        model: batteryChange.model,
        date: batteryChange.date,
      );

      await _firestoreDB
          .collection('battery_changes')
          .add(newBatteryChange.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<BatteryChangeEntity>>> getBatteryChanges() async {
    try {
      final snapshot = await _firestoreDB
          .collection('battery_changes')
          .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
          .orderBy('date', descending: true)
          .get();
      final batteryChanges = snapshot.docs
          .map((doc) => BatteryChangeModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(batteryChanges);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateBatteryChange(
    BatteryChangeEntity batteryChange,
  ) async {
    try {
      final updated = BatteryChangeModel(
        userId: _firebaseAuth.currentUser!.uid,
        vehicleId: batteryChange.vehicleId,
        model: batteryChange.model,
        date: batteryChange.date,
      );

      await _firestoreDB
          .collection('battery_changes')
          .doc(batteryChange.id)
          .update(updated.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBatteryChange(String id) async {
    try {
      await _firestoreDB.collection('battery_changes').doc(id).delete();
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
