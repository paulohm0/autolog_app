import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OilChangeModel extends OilChangeEntity {
  OilChangeModel({
    super.id,
    required super.vehicleId,
    required super.brand,
    required super.liters,
    required super.date,
  });

  factory OilChangeModel.fromMap(Map<String, dynamic> map, String id) {
    return OilChangeModel(
      id: id,
      vehicleId: map['vehicleId'],
      brand: map['brand'],
      liters: (map['liters'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'brand': brand,
      'liters': liters,
      'date': date,
    };
  }
}
