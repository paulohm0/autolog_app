class MaintenanceEntity {
  final String? id; // id gerado pelo firestore
  final String? userId; // id do dono, atribuido pelo repositorio
  final String vehicleId;
  final DateTime date;
  final String workshop;
  final String description;
  final double value;

  // Preenchidos só quando a manutenção inclui troca de óleo/bateria — é
  // isso que faz esse registro aparecer na aba Óleo/Bateria (ver
  // OilBatteryScreen, que filtra o histórico de manutenção por essas
  // flags em vez de ter uma coleção própria).
  final bool hasOilChange;
  final String? oilBrand;
  final double? oilLiters;
  final bool hasBatteryChange;
  final String? batteryModel;
  final String? batteryCapacity;

  MaintenanceEntity({
    this.id,
    this.userId,
    required this.vehicleId,
    required this.date,
    required this.workshop,
    required this.description,
    required this.value,
    this.hasOilChange = false,
    this.oilBrand,
    this.oilLiters,
    this.hasBatteryChange = false,
    this.batteryModel,
    this.batteryCapacity,
  });
}
