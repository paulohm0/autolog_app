class OilChangeEntity {
  final String? id; // id gerado pelo firestore
  final String vehicleId;
  final String brand;
  final double liters;
  final DateTime date;

  OilChangeEntity({
    this.id,
    required this.vehicleId,
    required this.brand,
    required this.liters,
    required this.date,
  });
}
