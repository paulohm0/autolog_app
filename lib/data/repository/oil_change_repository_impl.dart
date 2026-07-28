import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/oil_change_model.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OilChangeRepositoryImpl implements IOilChangeRepository {
  final FirebaseFirestore _firestoreDB;
  final FirebaseAuth _firebaseAuth;

  OilChangeRepositoryImpl({
    required FirebaseFirestore firestoreDB,
    required FirebaseAuth firebaseAuth,
  }) : _firestoreDB = firestoreDB,
       _firebaseAuth = firebaseAuth;

  @override
  Future<Either<Failure, void>> saveOilChange(OilChangeEntity oilChange) async {
    try {
      final newOilChange = OilChangeModel(
        userId: _firebaseAuth.currentUser!.uid,
        vehicleId: oilChange.vehicleId,
        brand: oilChange.brand,
        liters: oilChange.liters,
        date: oilChange.date,
      );

      await _firestoreDB.collection('oil_changes').add(newOilChange.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<OilChangeEntity>>> getOilChanges() async {
    try {
      final snapshot = await _firestoreDB
          .collection('oil_changes')
          .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
          .orderBy('date', descending: true)
          .get();
      final oilChanges = snapshot.docs
          .map((doc) => OilChangeModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(oilChanges);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateOilChange(
    OilChangeEntity oilChange,
  ) async {
    try {
      final updated = OilChangeModel(
        userId: _firebaseAuth.currentUser!.uid,
        vehicleId: oilChange.vehicleId,
        brand: oilChange.brand,
        liters: oilChange.liters,
        date: oilChange.date,
      );

      await _firestoreDB
          .collection('oil_changes')
          .doc(oilChange.id)
          .update(updated.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOilChange(String id) async {
    try {
      await _firestoreDB.collection('oil_changes').doc(id).delete();
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
