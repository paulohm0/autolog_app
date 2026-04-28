import 'package:autolog_app/data/model/vehicle_model.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepositoryImpl implements IVehicleRepository {
  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;

  @override
  Future<void> saveVehicle(VehicleEntity vehicle) async {
    try {
      final newVehicle = VehicleModel(
        brand: vehicle.brand,
        model: vehicle.model,
        licensePlate: vehicle.licensePlate,
        year: vehicle.year,
        color: vehicle.color,
      );

      await _firestoreDB.collection('vehicles').add(newVehicle.toJson());
    } catch (e) {
      throw Exception('Falha ao salvar veículo');
    }
  }

  @override
  Future<List<VehicleEntity>> getVehicles() {
    // TODO: implement getVehicles
    throw UnimplementedError();
  }
}
