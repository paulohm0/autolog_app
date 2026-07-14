class BatteryChangeEntity {
  final String? id; // id gerado pelo firestore
  final String? userId; // id do dono, atribuido pelo repositorio
  final String vehicleId;
  final String model;
  final DateTime date;

  BatteryChangeEntity({
    this.id,
    this.userId,
    required this.vehicleId,
    required this.model,
    required this.date,
  });
}
