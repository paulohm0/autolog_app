import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final IAuthRepository _repository;
  final IVehicleRepository _vehicleRepository;
  final IMaintenanceRepository _maintenanceRepository;

  ProfileCubit({
    required IAuthRepository repository,
    required IVehicleRepository vehicleRepository,
    required IMaintenanceRepository maintenanceRepository,
  }) : _repository = repository,
       _vehicleRepository = vehicleRepository,
       _maintenanceRepository = maintenanceRepository,
       super(ProfileInitial());

  Future<void> loadUser() async {
    emit(ProfileLoading());
    final result = await _repository.getCurrentUser();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> signOut() async {
    emit(ProfileLoading());
    final result = await _repository.signOut();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(ProfileSignedOut()),
    );
  }

  /// Apaga todo o histórico de manutenção e os veículos do usuário antes de
  /// excluir a conta em si — o Firebase Auth e o Firestore são sistemas
  /// independentes, excluir a conta não apaga os dados salvos sozinho.
  Future<void> deleteAccount() async {
    emit(ProfileLoading());

    final maintenancesResult = await _maintenanceRepository.getMaintenances();
    if (isClosed) return;
    final maintenances = maintenancesResult.fold((failure) {
      emit(ProfileError(message: failure.message));
      return null;
    }, (list) => list);
    if (maintenances == null) return;

    for (final maintenance in maintenances) {
      final result = await _maintenanceRepository.deleteMaintenance(
        maintenance.id!,
      );
      if (isClosed) return;
      final failed = result.fold((failure) {
        emit(ProfileError(message: failure.message));
        return true;
      }, (_) => false);
      if (failed) return;
    }

    final vehiclesResult = await _vehicleRepository.getVehicles();
    if (isClosed) return;
    final vehicles = vehiclesResult.fold((failure) {
      emit(ProfileError(message: failure.message));
      return null;
    }, (list) => list);
    if (vehicles == null) return;

    for (final vehicle in vehicles) {
      final result = await _vehicleRepository.deleteVehicle(vehicle.id!);
      if (isClosed) return;
      final failed = result.fold((failure) {
        emit(ProfileError(message: failure.message));
        return true;
      }, (_) => false);
      if (failed) return;
    }

    final result = await _repository.deleteAccount();
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(ProfileAccountDeleted()),
    );
  }
}
