import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel extends MaintenanceEntity {
  MaintenanceModel({
    super.id,
    super.userId,
    required super.vehicleId,
    required super.date,
    required super.workshop,
    required super.description,
    required super.value,
    super.hasOilChange,
    super.oilBrand,
    super.oilLiters,
    super.hasBatteryChange,
    super.batteryModel,
    super.batteryCapacity,
  });

  factory MaintenanceModel.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceModel(
      id: id,
      userId: map['userId'],
      vehicleId: map['vehicleId'],
      date: (map['date'] as Timestamp).toDate(),
      workshop: map['workshop'],
      description: map['description'],
      value: (map['value'] as num).toDouble(),
      hasOilChange: map['hasOilChange'] ?? false,
      oilBrand: map['oilBrand'],
      oilLiters: (map['oilLiters'] as num?)?.toDouble(),
      hasBatteryChange: map['hasBatteryChange'] ?? false,
      batteryModel: map['batteryModel'],
      batteryCapacity: map['batteryCapacity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'date': date,
      'workshop': workshop,
      'description': description,
      'value': value,
      'hasOilChange': hasOilChange,
      'oilBrand': oilBrand,
      'oilLiters': oilLiters,
      'hasBatteryChange': hasBatteryChange,
      'batteryModel': batteryModel,
      'batteryCapacity': batteryCapacity,
    };
  }
}
