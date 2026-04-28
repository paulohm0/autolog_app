class VehicleEntity {
  final String? id;
  final String brand;
  final String model;
  final String licensePlate;
  final int? year;
  final String? color;

  VehicleEntity({
    this.id,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.year,
    required this.color,
  });
}
