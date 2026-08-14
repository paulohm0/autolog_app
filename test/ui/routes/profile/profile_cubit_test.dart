import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockVehicleRepository extends Mock implements IVehicleRepository {}

class MockMaintenanceRepository extends Mock implements IMaintenanceRepository {}

MaintenanceEntity _maintenance(String id) => MaintenanceEntity(
  id: id,
  vehicleId: 'v1',
  date: DateTime(2026, 8, 1),
  workshop: 'Oficina Teste',
  description: 'Troca de óleo',
  value: 150,
);

VehicleEntity _vehicle(String id) =>
    VehicleEntity(id: id, brand: 'Fiat', model: 'Uno', licensePlate: 'ABC1234');

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockVehicleRepository mockVehicleRepository;
  late MockMaintenanceRepository mockMaintenanceRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockVehicleRepository = MockVehicleRepository();
    mockMaintenanceRepository = MockMaintenanceRepository();
  });

  ProfileCubit buildCubit() => ProfileCubit(
    repository: mockAuthRepository,
    vehicleRepository: mockVehicleRepository,
    maintenanceRepository: mockMaintenanceRepository,
  );

  group(
    'ProfileCubit',
    () {
      group(
        'loadUser',
        () {
          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileLoaded] when user info loads successfully',
            build: () {
              when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
                (_) async => Right(
                  UserEntity(id: '1', name: 'Test', email: 'test@test.com'),
                ),
              );
              return buildCubit();
            },
            act: (cubit) => cubit.loadUser(),
            expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
          );

          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileError] when loading user info fails',
            build: () {
              when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
                (_) async => Left(UnexpectedFailure('mensagem de teste')),
              );
              return buildCubit();
            },
            act: (cubit) => cubit.loadUser(),
            expect: () => [
              isA<ProfileLoading>(),
              isA<ProfileError>().having(
                (state) => state.message,
                'message',
                'mensagem de teste',
              ),
            ],
          );
        },
      );

      group(
        'signOut',
        () {
          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileSignedOut] when sign-out succeeds',
            build: () {
              when(() => mockAuthRepository.signOut()).thenAnswer(
                (_) async => Right(null),
              );
              return buildCubit();
            },
            act: (cubit) => cubit.signOut(),
            expect: () => [isA<ProfileLoading>(), isA<ProfileSignedOut>()],
          );

          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileError] when sign-out fails',
            build: () {
              when(() => mockAuthRepository.signOut()).thenAnswer(
                (_) async => Left(UnexpectedFailure('mensagem de teste')),
              );
              return buildCubit();
            },
            act: (cubit) => cubit.signOut(),
            expect: () => [
              isA<ProfileLoading>(),
              isA<ProfileError>().having(
                (state) => state.message,
                'message',
                'mensagem de teste',
              ),
            ],
          );
        },
      );

      group('deleteAccount', () {
        blocTest<ProfileCubit, ProfileState>(
          'emits [ProfileLoading, ProfileAccountDeleted] when everything is deleted successfully',
          build: () {
            when(
              () => mockMaintenanceRepository.getMaintenances(),
            ).thenAnswer((_) async => Right([_maintenance('m1')]));
            when(
              () => mockMaintenanceRepository.deleteMaintenance('m1'),
            ).thenAnswer((_) async => Right(null));
            when(
              () => mockVehicleRepository.getVehicles(),
            ).thenAnswer((_) async => Right([_vehicle('v1')]));
            when(
              () => mockVehicleRepository.deleteVehicle('v1'),
            ).thenAnswer((_) async => Right(null));
            when(
              () => mockAuthRepository.deleteAccount(),
            ).thenAnswer((_) async => Right(null));
            return buildCubit();
          },
          act: (cubit) => cubit.deleteAccount(),
          expect: () => [isA<ProfileLoading>(), isA<ProfileAccountDeleted>()],
        );

        blocTest<ProfileCubit, ProfileState>(
          'stops and does not delete the account when deleting a maintenance fails',
          build: () {
            when(
              () => mockMaintenanceRepository.getMaintenances(),
            ).thenAnswer((_) async => Right([_maintenance('m1')]));
            when(() => mockMaintenanceRepository.deleteMaintenance('m1'))
                .thenAnswer(
              (_) async => Left(UnexpectedFailure('mensagem de teste')),
            );
            return buildCubit();
          },
          act: (cubit) => cubit.deleteAccount(),
          expect: () => [
            isA<ProfileLoading>(),
            isA<ProfileError>().having(
              (state) => state.message,
              'message',
              'mensagem de teste',
            ),
          ],
          verify: (_) {
            verifyNever(() => mockVehicleRepository.getVehicles());
            verifyNever(() => mockAuthRepository.deleteAccount());
          },
        );

        blocTest<ProfileCubit, ProfileState>(
          'emits an error when every Firestore record is deleted but the account deletion itself fails',
          build: () {
            when(
              () => mockMaintenanceRepository.getMaintenances(),
            ).thenAnswer((_) async => Right([]));
            when(
              () => mockVehicleRepository.getVehicles(),
            ).thenAnswer((_) async => Right([]));
            when(() => mockAuthRepository.deleteAccount()).thenAnswer(
              (_) async => Left(UnexpectedFailure('mensagem de teste')),
            );
            return buildCubit();
          },
          act: (cubit) => cubit.deleteAccount(),
          expect: () => [
            isA<ProfileLoading>(),
            isA<ProfileError>().having(
              (state) => state.message,
              'message',
              'mensagem de teste',
            ),
          ],
        );
      });
    },
  );
}
