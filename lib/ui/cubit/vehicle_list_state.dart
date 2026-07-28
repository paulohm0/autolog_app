import 'package:autolog_app/domain/entity/vehicle_entity.dart';

sealed class VehicleListState {}

class VehicleListInitial extends VehicleListState {}

class VehicleListLoading extends VehicleListState {}

class VehicleListLoaded extends VehicleListState {
  final List<VehicleEntity> vehicles;

  VehicleListLoaded({required this.vehicles});

  Map<String, VehicleEntity> get vehiclesById => {
    for (final v in vehicles) v.id!: v,
  };
}

class VehicleListError extends VehicleListState {
  final String message;
  VehicleListError({required this.message});
}
