class MaintenanceEntity {
  final String? id; // id gerado pelo firestore
  final String vehicleId;
  final DateTime date;
  final String workshop;
  final String description;
  final double value;

  MaintenanceEntity({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.workshop,
    required this.description,
    required this.value,
  });
}
