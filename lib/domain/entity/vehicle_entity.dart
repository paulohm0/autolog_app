class VehicleEntity {
  final String? id; // id gerado pelo firestore
  final String? userId; // id do dono, atribuido pelo repositorio
  final String brand;
  final String model;
  final String licensePlate;
  final int? year;
  final String? color;

  VehicleEntity({
    this.id,
    this.userId,
    required this.brand,
    required this.model,
    required this.licensePlate,
    this.year,
    this.color,
  });
}
