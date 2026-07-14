class BatteryChangeEntity {
  final String? id; // id gerado pelo firestore
  final String vehicleId;
  final String model;
  final DateTime date;

  BatteryChangeEntity({
    this.id,
    required this.vehicleId,
    required this.model,
    required this.date,
  });
}
