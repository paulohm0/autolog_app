import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/vehicle_model.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class VehicleRepositoryImpl implements IVehicleRepository {
  final FirebaseFirestore _firestoreDB;

  VehicleRepositoryImpl({required FirebaseFirestore firestoreDB})
    : _firestoreDB = firestoreDB;

  @override
  Future<Either<Failure, void>> saveVehicle(VehicleEntity vehicle) async {
    try {
      final newVehicle = VehicleModel(
        brand: vehicle.brand,
        model: vehicle.model,
        licensePlate: vehicle.licensePlate,
        year: vehicle.year,
        color: vehicle.color,
      );

      await _firestoreDB.collection('vehicles').add(newVehicle.toJson());
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<VehicleEntity>>> getVehicles() {
    // TODO: implement getVehicles
    throw UnimplementedError();
  }
}
