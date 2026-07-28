import 'package:autolog_app/domain/entity/oil_change_entity.dart';

sealed class OilChangeState {}

class OilChangeInitial extends OilChangeState {}

class OilChangeLoading extends OilChangeState {}

class OilChangeLoaded extends OilChangeState {
  final List<OilChangeEntity> oilChanges;

  OilChangeLoaded({required this.oilChanges});
}

class OilChangeSaveSuccess extends OilChangeState {}

class OilChangeError extends OilChangeState {
  final String message;
  OilChangeError({required this.message});
}
