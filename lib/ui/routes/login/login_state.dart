import 'package:autolog_app/domain/entity/user_entity.dart';

sealed class LoginState {}

class InitialState extends LoginState {}

class LoadingState extends LoginState {}

class SuccessState extends LoginState {
  final UserEntity user;
  SuccessState({required this.user});
}

class ErrorState extends LoginState {
  final String message;
  ErrorState({required this.message});
}
