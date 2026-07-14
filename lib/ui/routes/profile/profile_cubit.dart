import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IAuthRepository _repository;

  ProfileCubit({required IAuthRepository repository})
    : _repository = repository,
      super(ProfileInitial());

  Future<void> loadUser() async {
    emit(ProfileLoading());
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> signOut() async {
    emit(ProfileLoading());
    final result = await _repository.signOut();
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(ProfileSignedOut()),
    );
  }
}
