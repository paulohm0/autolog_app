import 'package:autolog_app/domain/entity/oil_change_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class OilChangeState {}

class OilChangeInitial extends OilChangeState {}

class OilChangeLoading extends OilChangeState {}

class OilChangeLoaded extends OilChangeState {
  final List<VehicleEntity> vehicles;
  final List<OilChangeEntity> oilChanges;

  OilChangeLoaded({required this.vehicles, required this.oilChanges});

  Map<String, VehicleEntity> get vehiclesById => {
    for (final v in vehicles) v.id!: v,
  };
}

class OilChangeSaveSuccess extends OilChangeState {}

class OilChangeError extends OilChangeState {
  final String message;
  OilChangeError({required this.message});
}
