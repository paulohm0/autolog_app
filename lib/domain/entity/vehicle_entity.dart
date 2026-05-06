class VehicleEntity {
  final String? id; // id gerado pelo firestore
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
    this.year,
    this.color,
  });
}
