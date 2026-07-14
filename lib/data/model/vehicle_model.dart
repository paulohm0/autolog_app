import 'package:autolog_app/domain/entity/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  VehicleModel({
    super.id,
    super.userId,
    required super.brand,
    required super.model,
    required super.licensePlate,
    required super.year,
    required super.color,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map, String id) {
    return VehicleModel(
      id: id,
      userId: map['userId'],
      brand: map['brand'],
      model: map['model'],
      licensePlate: map['licensePlate'],
      year: map['year'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'licensePlate': licensePlate,
      'year': year,
      'color': color,
    };
  }
}
