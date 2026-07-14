import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BatteryChangeModel extends BatteryChangeEntity {
  BatteryChangeModel({
    super.id,
    super.userId,
    required super.vehicleId,
    required super.model,
    required super.date,
  });

  factory BatteryChangeModel.fromMap(Map<String, dynamic> map, String id) {
    return BatteryChangeModel(
      id: id,
      userId: map['userId'],
      vehicleId: map['vehicleId'],
      model: map['model'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'model': model,
      'date': date,
    };
  }
}
