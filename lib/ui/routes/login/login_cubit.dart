import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final IAuthRepository _repository;

  LoginCubit({required IAuthRepository repository})
    : _repository = repository,
      super(InitialState());

  Future<void> signIn() async {
    emit(LoadingState());
    final result = await _repository.signInWithGoogle();
    result.fold(
      (failure) => emit(ErrorState(message: failure.message)),
      (success) => emit(SuccessState(user: success)),
    );
  }

  Future<void> signOut() async {
    emit(LoadingState());
    final result = await _repository.signOut();
    result.fold(
      (failure) => emit(ErrorState(message: failure.message)),
      (success) => emit(InitialState()),
    );
  }
}
