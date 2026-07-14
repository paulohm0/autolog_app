import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/data/model/maintenance_model.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class MaintenanceRepositoryImpl implements IMaintenanceRepository {
  final FirebaseFirestore _firestoreDB;

  MaintenanceRepositoryImpl({required FirebaseFirestore firestoreDB})
    : _firestoreDB = firestoreDB;

  @override
  Future<Either<Failure, void>> saveMaintenance(
    MaintenanceEntity maintenance,
  ) async {
    try {
      final newMaintenance = MaintenanceModel(
        vehicleId: maintenance.vehicleId,
        date: maintenance.date,
        workshop: maintenance.workshop,
        description: maintenance.description,
        value: maintenance.value,
      );

      await _firestoreDB.collection('maintenances').add(newMaintenance.toJson());
      return Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceEntity>>> getMaintenances() async {
    try {
      final snapshot = await _firestoreDB
          .collection('maintenances')
          .orderBy('date', descending: true)
          .get();
      final maintenances = snapshot.docs
          .map((doc) => MaintenanceModel.fromMap(doc.data(), doc.id))
          .toList();
      return Right(maintenances);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
