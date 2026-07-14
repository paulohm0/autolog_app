import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceModel extends MaintenanceEntity {
  MaintenanceModel({
    super.id,
    required super.vehicleId,
    required super.date,
    required super.workshop,
    required super.description,
    required super.value,
  });

  factory MaintenanceModel.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceModel(
      id: id,
      vehicleId: map['vehicleId'],
      date: (map['date'] as Timestamp).toDate(),
      workshop: map['workshop'],
      description: map['description'],
      value: (map['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'date': date,
      'workshop': workshop,
      'description': description,
      'value': value,
    };
  }
}
