import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/ui/routes/home/home_cubit.dart';
import 'package:autolog_app/ui/routes/home/home_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceRepository extends Mock implements IMaintenanceRepository {}

MaintenanceEntity _maintenance(String id) => MaintenanceEntity(
  id: id,
  vehicleId: 'v1',
  date: DateTime(2026, 8, 1),
  workshop: 'Oficina Teste',
  description: 'Troca de óleo',
  value: 150,
);

void main() {
  late MockMaintenanceRepository mockRepository;

  setUp(() {
    mockRepository = MockMaintenanceRepository();
  });

  group('loadHomeData', () {
    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeLoaded] when there is no cache and the fetch succeeds',
      build: () {
        when(
          () => mockRepository.getCachedMaintenances(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(
          () => mockRepository.getMaintenances(),
        ).thenAnswer((_) async => Right([_maintenance('1')]));
        return HomeCubit(maintenanceRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>()],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoading, HomeError] when there is no cache and the fetch fails',
      build: () {
        when(
          () => mockRepository.getCachedMaintenances(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(() => mockRepository.getMaintenances()).thenAnswer(
          (_) async => Left(UnexpectedFailure('mensagem de teste')),
        );
        return HomeCubit(maintenanceRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [
        isA<HomeLoading>(),
        isA<HomeError>().having(
          (state) => state.message,
          'message',
          'mensagem de teste',
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [HomeLoaded, HomeLoaded] with no loading state when cache already has data',
      build: () {
        when(
          () => mockRepository.getCachedMaintenances(),
        ).thenAnswer((_) async => Right([_maintenance('cached')]));
        when(
          () => mockRepository.getMaintenances(),
        ).thenAnswer((_) async => Right([_maintenance('fresh')]));
        return HomeCubit(maintenanceRepository: mockRepository);
      },
      act: (cubit) => cubit.loadHomeData(),
      expect: () => [isA<HomeLoaded>(), isA<HomeLoaded>()],
    );
  });

  group('ensureLoaded', () {
    test('does not trigger a duplicate fetch when called twice concurrently', () async {
      when(
        () => mockRepository.getCachedMaintenances(),
      ).thenAnswer((_) async => Left(UnexpectedFailure()));
      when(
        () => mockRepository.getMaintenances(),
      ).thenAnswer((_) async => Right([]));

      final cubit = HomeCubit(maintenanceRepository: mockRepository);

      await Future.wait([cubit.ensureLoaded(), cubit.ensureLoaded()]);

      verify(() => mockRepository.getMaintenances()).called(1);
      await cubit.close();
    });
  });

  group('deleteMaintenance', () {
    blocTest<HomeCubit, HomeState>(
      'reloads the list after a successful delete',
      build: () {
        when(
          () => mockRepository.getCachedMaintenances(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(
          () => mockRepository.getMaintenances(),
        ).thenAnswer((_) async => Right([_maintenance('1')]));
        when(
          () => mockRepository.deleteMaintenance(any()),
        ).thenAnswer((_) async => Right(null));
        return HomeCubit(maintenanceRepository: mockRepository);
      },
      act: (cubit) async {
        await cubit.loadHomeData();
        await cubit.deleteMaintenance('1');
      },
      // Recarrega sem HomeLoading no meio: [loading, loaded] do 1º load,
      // + mais um HomeLoaded do reload (ver comentário em home_cubit.dart).
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>(), isA<HomeLoaded>()],
    );

    test('does not reload when delete fails', () async {
      when(
        () => mockRepository.getCachedMaintenances(),
      ).thenAnswer((_) async => Left(UnexpectedFailure()));
      when(
        () => mockRepository.getMaintenances(),
      ).thenAnswer((_) async => Right([_maintenance('1')]));
      when(() => mockRepository.deleteMaintenance(any())).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );
      final cubit = HomeCubit(maintenanceRepository: mockRepository);

      await cubit.loadHomeData();
      await cubit.deleteMaintenance('1');

      verify(() => mockRepository.getMaintenances()).called(1);
      await cubit.close();
    });
  });

  group('reset', () {
    blocTest<HomeCubit, HomeState>(
      'returns to HomeInitial',
      build: () {
        when(
          () => mockRepository.getCachedMaintenances(),
        ).thenAnswer((_) async => Left(UnexpectedFailure()));
        when(
          () => mockRepository.getMaintenances(),
        ).thenAnswer((_) async => Right([_maintenance('1')]));
        return HomeCubit(maintenanceRepository: mockRepository);
      },
      act: (cubit) async {
        await cubit.loadHomeData();
        cubit.reset();
      },
      expect: () => [isA<HomeLoading>(), isA<HomeLoaded>(), isA<HomeInitial>()],
    );
  });
}
