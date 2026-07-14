import 'package:autolog_app/domain/entity/battery_change_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class BatteryChangeState {}

class BatteryChangeInitial extends BatteryChangeState {}

class BatteryChangeLoading extends BatteryChangeState {}

class BatteryChangeLoaded extends BatteryChangeState {
  final List<VehicleEntity> vehicles;
  final List<BatteryChangeEntity> batteryChanges;

  BatteryChangeLoaded({required this.vehicles, required this.batteryChanges});

  Map<String, VehicleEntity> get vehiclesById => {
    for (final v in vehicles) v.id!: v,
  };
}

class BatteryChangeSaveSuccess extends BatteryChangeState {}

class BatteryChangeError extends BatteryChangeState {
  final String message;
  BatteryChangeError({required this.message});
}
