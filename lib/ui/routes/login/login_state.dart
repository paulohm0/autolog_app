import 'package:autolog_app/domain/entity/user_entity.dart';

sealed class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;
  LoginSuccess({required this.user});
}

class LoginError extends LoginState {
  final String message;
  LoginError({required this.message});
}
