import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_cubit.dart';
import 'package:autolog_app/ui/cubit/vehicle/vehicle_list_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVehicleRepository extends Mock implements IVehicleRepository {}

class MockMaintenanceRepository extends Mock implements IMaintenanceRepository {}

VehicleEntity _vehicle(String id) =>
    VehicleEntity(id: id, brand: 'Fiat', model: 'Uno', licensePlate: 'ABC1234');

MaintenanceEntity _maintenance({required String id, required String vehicleId}) =>
    MaintenanceEntity(
      id: id,
      vehicleId: vehicleId,
      date: DateTime(2026, 8, 1),
      workshop: 'Oficina Teste',
      description: 'Troca de óleo',
      value: 150,
    );

void main() {
  late MockVehicleRepository mockVehicleRepository;
  late MockMaintenanceRepository mockMaintenanceRepository;

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    mockMaintenanceRepository = MockMaintenanceRepository();
  });

  VehicleListCubit buildCubit() => VehicleListCubit(
    repository: mockVehicleRepository,
    maintenanceRepository: mockMaintenanceRepository,
  );

  group('loadVehicles', () {
    blocTest<VehicleListCubit, VehicleListState>(
      'emits [VehicleListLoading, VehicleListLoaded] when there is no cache and the fetch succeeds',
      build: () {
        when(
          () => mockVehicleRepository.getCachedVehicles(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(
          () => mockVehicleRepository.getVehicles(),
        ).thenAnswer((_) async => Right([_vehicle('1')]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadVehicles(),
      expect: () => [isA<VehicleListLoading>(), isA<VehicleListLoaded>()],
    );

    blocTest<VehicleListCubit, VehicleListState>(
      'emits [VehicleListLoading, VehicleListError] when there is no cache and the fetch fails',
      build: () {
        when(
          () => mockVehicleRepository.getCachedVehicles(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(() => mockVehicleRepository.getVehicles()).thenAnswer(
          (_) async => Left(UnexpectedFailure('mensagem de teste')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadVehicles(),
      expect: () => [
        isA<VehicleListLoading>(),
        isA<VehicleListError>().having(
          (state) => state.message,
          'message',
          'mensagem de teste',
        ),
      ],
    );

    blocTest<VehicleListCubit, VehicleListState>(
      'emits [VehicleListLoaded, VehicleListLoaded] with no loading state when cache already has data',
      build: () {
        when(
          () => mockVehicleRepository.getCachedVehicles(),
        ).thenAnswer((_) async => Right([_vehicle('cached')]));
        when(
          () => mockVehicleRepository.getVehicles(),
        ).thenAnswer((_) async => Right([_vehicle('fresh')]));
        return buildCubit();
      },
      act: (cubit) => cubit.loadVehicles(),
      expect: () => [isA<VehicleListLoaded>(), isA<VehicleListLoaded>()],
    );
  });

  group('ensureLoaded', () {
    test('does not trigger a duplicate fetch when called twice concurrently', () async {
      when(
        () => mockVehicleRepository.getCachedVehicles(),
      ).thenAnswer((_) async => Left(UnexpectedFailure()));
      when(
        () => mockVehicleRepository.getVehicles(),
      ).thenAnswer((_) async => Right([]));

      final cubit = buildCubit();

      await Future.wait([cubit.ensureLoaded(), cubit.ensureLoaded()]);

      verify(() => mockVehicleRepository.getVehicles()).called(1);
      await cubit.close();
    });
  });

  group('getLinkedRecords', () {
    test('returns only the maintenances linked to the given vehicle', () async {
      when(() => mockMaintenanceRepository.getMaintenances()).thenAnswer(
        (_) async => Right([
          _maintenance(id: 'm1', vehicleId: 'v1'),
          _maintenance(id: 'm2', vehicleId: 'v2'),
          _maintenance(id: 'm3', vehicleId: 'v1'),
        ]),
      );

      final result = await buildCubit().getLinkedRecords('v1');

      final records = result.fold((_) => null, (r) => r)!;
      expect(records.maintenances.map((m) => m.id), ['m1', 'm3']);
    });

    test('returns the failure when fetching maintenances fails', () async {
      when(() => mockMaintenanceRepository.getMaintenances()).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final result = await buildCubit().getLinkedRecords('v1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('deleteVehicleCascade', () {
    test('deletes every linked record then deletes the vehicle when all succeed', () async {
      when(
        () => mockMaintenanceRepository.deleteMaintenance('m1'),
      ).thenAnswer((_) async => Right(null));
      when(
        () => mockMaintenanceRepository.deleteMaintenance('m2'),
      ).thenAnswer((_) async => Right(null));
      when(
        () => mockVehicleRepository.deleteVehicle('v1'),
      ).thenAnswer((_) async => Right(null));
      when(
        () => mockVehicleRepository.getCachedVehicles(),
      ).thenAnswer((_) async => Left(UnexpectedFailure()));
      when(
        () => mockVehicleRepository.getVehicles(),
      ).thenAnswer((_) async => Right([]));

      final linkedRecords = VehicleLinkedRecords(
        maintenances: [
          _maintenance(id: 'm1', vehicleId: 'v1'),
          _maintenance(id: 'm2', vehicleId: 'v1'),
        ],
      );

      final result = await buildCubit().deleteVehicleCascade('v1', linkedRecords);

      verify(() => mockMaintenanceRepository.deleteMaintenance('m1')).called(1);
      verify(() => mockMaintenanceRepository.deleteMaintenance('m2')).called(1);
      verify(() => mockVehicleRepository.deleteVehicle('v1')).called(1);
      expect(result.isRight(), isTrue);
    });

    test('stops and does not delete the vehicle when a linked record fails to delete', () async {
      when(
        () => mockMaintenanceRepository.deleteMaintenance('m1'),
      ).thenAnswer((_) async => Right(null));
      when(() => mockMaintenanceRepository.deleteMaintenance('m2')).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final linkedRecords = VehicleLinkedRecords(
        maintenances: [
          _maintenance(id: 'm1', vehicleId: 'v1'),
          _maintenance(id: 'm2', vehicleId: 'v1'),
        ],
      );

      final result = await buildCubit().deleteVehicleCascade('v1', linkedRecords);

      verify(() => mockMaintenanceRepository.deleteMaintenance('m1')).called(1);
      verify(() => mockMaintenanceRepository.deleteMaintenance('m2')).called(1);
      verifyNever(() => mockVehicleRepository.deleteVehicle(any()));
      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f.message, (_) => null), 'mensagem de teste');
    });
  });
}
