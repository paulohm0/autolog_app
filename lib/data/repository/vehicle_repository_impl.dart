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

  CollectionReference<Map<String, dynamic>> get _vehiclesCollection =>
      _firestoreDB
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .collection('vehicles');

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

      await _vehiclesCollection.add(newVehicle.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles() async {
    try {
      final snapshot = await _vehiclesCollection.get();
      final vehicles = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(vehicles);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getCachedVehicles() async {
    try {
      final snapshot = await _vehiclesCollection.get(
        const GetOptions(source: Source.cache),
      );
      final vehicles = snapshot.docs
          .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(vehicles);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateVehicle(VehicleEntity vehicle) async {
    try {
      final updated = VehicleModel(
        userId: _firebaseAuth.currentUser!.uid,
        brand: vehicle.brand,
        model: vehicle.model,
        licensePlate: vehicle.licensePlate,
        year: vehicle.year,
        color: vehicle.color,
      );

      await _vehiclesCollection.doc(vehicle.id).update(updated.toJson());
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String id) async {
    try {
      await _vehiclesCollection.doc(id).delete();
      return Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
