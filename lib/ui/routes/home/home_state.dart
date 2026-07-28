import 'package:autolog_app/domain/entity/maintenance_entity.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MaintenanceEntity> maintenances;

  HomeLoaded({required this.maintenances});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
