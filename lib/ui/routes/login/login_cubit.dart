import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/login/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final IAuthRepository _repository;

  LoginCubit({required IAuthRepository repository})
    : _repository = repository,
      super(LoginInitial());

  Future<void> signIn() async {
    emit(LoginLoading());
    final result = await _repository.signInWithGoogle();
    if (isClosed) return;
    result.fold(
      (failure) => emit(LoginError(message: failure.message)),
      (success) => emit(LoginSuccess(user: success)),
    );
  }

  Future<void> signOut() async {
    emit(LoginLoading());
    final result = await _repository.signOut();
    if (isClosed) return;
    result.fold(
      (failure) => emit(LoginError(message: failure.message)),
      (success) => emit(LoginInitial()),
    );
  }
}
