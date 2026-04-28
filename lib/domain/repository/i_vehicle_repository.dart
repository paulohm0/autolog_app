import 'package:autolog_app/domain/entity/vehicle_entity.dart';

abstract class IVehicleRepository {
  Future<void> saveVehicle(VehicleEntity vehicle);
  Future<List<VehicleEntity>> getVehicles();
}
