import 'package:autolog_app/domain/entity/battery_change_entity.dart';

sealed class BatteryChangeState {}

class BatteryChangeInitial extends BatteryChangeState {}

class BatteryChangeLoading extends BatteryChangeState {}

class BatteryChangeLoaded extends BatteryChangeState {
  final List<BatteryChangeEntity> batteryChanges;

  BatteryChangeLoaded({required this.batteryChanges});
}

class BatteryChangeError extends BatteryChangeState {
  final String message;
  BatteryChangeError({required this.message});
}
