import 'package:autolog_app/domain/entity/user_entity.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  ProfileLoaded({required this.user});
}

class ProfileSignedOut extends ProfileState {}

class ProfileAccountDeleted extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}
