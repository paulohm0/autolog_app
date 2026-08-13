import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_maintenance_repository.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_cubit.dart';
import 'package:autolog_app/ui/routes/register_service/register_service_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMaintenanceRepository extends Mock implements IMaintenanceRepository {}

class MockVehicleRepository extends Mock implements IVehicleRepository {}

void main() {
  late MockMaintenanceRepository mockMaintenanceRepository;
  late MockVehicleRepository mockVehicleRepository;

  setUpAll(() {
    registerFallbackValue(
      MaintenanceEntity(
        vehicleId: 'v1',
        date: DateTime(2026, 1, 1),
        workshop: '',
        description: '',
        value: 0,
      ),
    );
  });

  setUp(() {
    mockMaintenanceRepository = MockMaintenanceRepository();
    mockVehicleRepository = MockVehicleRepository();
  });

  RegisterServiceCubit buildCubit() => RegisterServiceCubit(
    maintenanceRepository: mockMaintenanceRepository,
    vehicleRepository: mockVehicleRepository,
  );

  group('loadVehicles', () {
    blocTest<RegisterServiceCubit, RegisterServiceState>(
      'emits [RegisterServiceLoading, RegisterServiceVehiclesLoaded] when vehicles load successfully',
      build: () {
        when(() => mockVehicleRepository.getVehicles()).thenAnswer(
          (_) async => Right([
            VehicleEntity(brand: 'Fiat', model: 'Uno', licensePlate: 'ABC1234'),
          ]),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadVehicles(),
      expect: () => [
        isA<RegisterServiceLoading>(),
        isA<RegisterServiceVehiclesLoaded>(),
      ],
    );

    blocTest<RegisterServiceCubit, RegisterServiceState>(
      'emits [RegisterServiceLoading, RegisterServiceError] when loading vehicles fails',
      build: () {
        when(() => mockVehicleRepository.getVehicles()).thenAnswer(
          (_) async => Left(UnexpectedFailure('mensagem de teste')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadVehicles(),
      expect: () => [
        isA<RegisterServiceLoading>(),
        isA<RegisterServiceError>().having(
          (state) => state.message,
          'message',
          'mensagem de teste',
        ),
      ],
    );
  });

  group('saveMaintenance', () {
    test('builds a MaintenanceEntity from the form fields and saves it', () async {
      when(
        () => mockMaintenanceRepository.saveMaintenance(any()),
      ).thenAnswer((_) async => Right(null));

      final result = await buildCubit().saveMaintenance(
        vehicleId: 'v1',
        date: DateTime(2026, 8, 1),
        workshop: 'Oficina Teste',
        description: 'Troca de óleo',
        value: 150,
        hasOilChange: true,
        oilBrand: 'Mobil',
        oilLiters: 4.5,
        hasBatteryChange: false,
      );

      final captured = verify(
        () => mockMaintenanceRepository.saveMaintenance(captureAny()),
      ).captured;
      final saved = captured.single as MaintenanceEntity;
      expect(saved.vehicleId, 'v1');
      expect(saved.workshop, 'Oficina Teste');
      expect(saved.value, 150);
      expect(saved.hasOilChange, true);
      expect(saved.oilBrand, 'Mobil');
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository when saving fails', () async {
      when(() => mockMaintenanceRepository.saveMaintenance(any())).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final result = await buildCubit().saveMaintenance(
        vehicleId: 'v1',
        date: DateTime(2026, 8, 1),
        workshop: 'Oficina Teste',
        description: 'Troca de óleo',
        value: 150,
        hasOilChange: false,
        hasBatteryChange: false,
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f.message, (_) => null), 'mensagem de teste');
    });
  });

  group('updateMaintenance', () {
    test('builds a MaintenanceEntity with the given id and updates it', () async {
      when(
        () => mockMaintenanceRepository.updateMaintenance(any()),
      ).thenAnswer((_) async => Right(null));

      final result = await buildCubit().updateMaintenance(
        id: '99',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 1),
        workshop: 'Oficina Teste',
        description: 'Troca de bateria',
        value: 300,
        hasOilChange: false,
        hasBatteryChange: true,
        batteryModel: 'Moura 60Ah',
        batteryCapacity: '60Ah',
      );

      final captured = verify(
        () => mockMaintenanceRepository.updateMaintenance(captureAny()),
      ).captured;
      final updated = captured.single as MaintenanceEntity;
      expect(updated.id, '99');
      expect(updated.hasBatteryChange, true);
      expect(updated.batteryModel, 'Moura 60Ah');
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository when updating fails', () async {
      when(() => mockMaintenanceRepository.updateMaintenance(any())).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final result = await buildCubit().updateMaintenance(
        id: '99',
        vehicleId: 'v1',
        date: DateTime(2026, 8, 1),
        workshop: 'Oficina Teste',
        description: 'Troca de bateria',
        value: 300,
        hasOilChange: false,
        hasBatteryChange: false,
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f.message, (_) => null), 'mensagem de teste');
    });
  });
}
