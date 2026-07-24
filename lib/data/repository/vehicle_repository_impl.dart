import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/vehicle_model.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleRepositoryImpl implements IVehicleRepository {
  final FirebaseFirestore _firestoreDB;
  final FirebaseAuth _firebaseAuth;

  VehicleRepositoryImpl({
    required FirebaseFirestore firestoreDB,
    required FirebaseAuth firebaseAuth,
  }) : _firestoreDB = firestoreDB,
       _firebaseAuth = firebaseAuth;

  @override
  Future<Either<Failure, void>> saveVehicle(VehicleEntity vehicle) async {
    try {
      final newVehicle = VehicleModel(
        userId: _firebaseAuth.currentUser!.uid,
        brand: vehicle.brand,
        model: vehicle.model,
        licensePlate: vehicle.licensePlate,
        year: vehicle.year,
        color: vehicle.color,
      );

      await _firestoreDB.collection('vehicles').add(newVehicle.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles() async {
    try {
      final snapshot = await _firestoreDB
          .collection('vehicles')
          .where('userId', isEqualTo: _firebaseAuth.currentUser!.uid)
          .get();
      final vehicles = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(vehicles);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
