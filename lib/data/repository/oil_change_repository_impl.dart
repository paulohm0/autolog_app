import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/oil_change_model.dart';
import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/repository/i_oil_change_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class OilChangeRepositoryImpl implements IOilChangeRepository {
  final FirebaseFirestore _firestoreDB;

  OilChangeRepositoryImpl({required FirebaseFirestore firestoreDB})
    : _firestoreDB = firestoreDB;

  @override
  Future<Either<Failure, void>> saveOilChange(OilChangeEntity oilChange) async {
    try {
      final newOilChange = OilChangeModel(
        vehicleId: oilChange.vehicleId,
        brand: oilChange.brand,
        liters: oilChange.liters,
        date: oilChange.date,
      );

      await _firestoreDB.collection('oil_changes').add(newOilChange.toJson());
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<OilChangeEntity>>> getOilChanges() async {
    try {
      final snapshot = await _firestoreDB
          .collection('oil_changes')
          .orderBy('date', descending: true)
          .get();
      final oilChanges = snapshot.docs
          .map((doc) => OilChangeModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(oilChanges);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
