import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/register_vehicle/register_vehicle_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVehicleRepository extends Mock implements IVehicleRepository {}

void main() {
  late MockVehicleRepository mockRepository;
  late RegisterVehicleService service;

  setUpAll(() {
    registerFallbackValue(
      VehicleEntity(brand: '', model: '', licensePlate: ''),
    );
  });

  setUp(() {
    mockRepository = MockVehicleRepository();
    service = RegisterVehicleService(repository: mockRepository);
  });

  group('saveVehicleFromForm', () {
    test('builds a VehicleEntity from the form fields and saves it', () async {
      when(
        () => mockRepository.saveVehicle(any()),
      ).thenAnswer((_) async => Right(null));

      final result = await service.saveVehicleFromForm(
        brand: 'Fiat',
        model: 'Uno',
        licensePlate: 'ABC1234',
        year: '2020',
        color: 'Prata',
      );

      final captured = verify(
        () => mockRepository.saveVehicle(captureAny()),
      ).captured;
      final savedVehicle = captured.single as VehicleEntity;
      expect(savedVehicle.brand, 'Fiat');
      expect(savedVehicle.model, 'Uno');
      expect(savedVehicle.licensePlate, 'ABC1234');
      expect(savedVehicle.year, 2020);
      expect(savedVehicle.color, 'Prata');
      expect(result.isRight(), isTrue);
    });

    test('parses a non-numeric year as null', () async {
      when(
        () => mockRepository.saveVehicle(any()),
      ).thenAnswer((_) async => Right(null));

      await service.saveVehicleFromForm(
        brand: 'Fiat',
        model: 'Uno',
        licensePlate: 'ABC1234',
        year: 'not-a-year',
        color: 'Prata',
      );

      final captured = verify(
        () => mockRepository.saveVehicle(captureAny()),
      ).captured;
      final savedVehicle = captured.single as VehicleEntity;
      expect(savedVehicle.year, null);
    });

    test('returns the failure from the repository when saving fails', () async {
      when(() => mockRepository.saveVehicle(any())).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final result = await service.saveVehicleFromForm(
        brand: 'Fiat',
        model: 'Uno',
        licensePlate: 'ABC1234',
        year: '2020',
        color: 'Prata',
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f.message, (_) => null), 'mensagem de teste');
    });
  });

  group('updateVehicleFromForm', () {
    test('builds a VehicleEntity with the given id and updates it', () async {
      when(
        () => mockRepository.updateVehicle(any()),
      ).thenAnswer((_) async => Right(null));

      final result = await service.updateVehicleFromForm(
        id: '42',
        brand: 'Chevrolet',
        model: 'Onix',
        licensePlate: 'XYZ5678',
        year: '2022',
        color: 'Preto',
      );

      final captured = verify(
        () => mockRepository.updateVehicle(captureAny()),
      ).captured;
      final updatedVehicle = captured.single as VehicleEntity;
      expect(updatedVehicle.id, '42');
      expect(updatedVehicle.brand, 'Chevrolet');
      expect(updatedVehicle.model, 'Onix');
      expect(updatedVehicle.licensePlate, 'XYZ5678');
      expect(updatedVehicle.year, 2022);
      expect(updatedVehicle.color, 'Preto');
      expect(result.isRight(), isTrue);
    });

    test('returns the failure from the repository when updating fails', () async {
      when(() => mockRepository.updateVehicle(any())).thenAnswer(
        (_) async => Left(UnexpectedFailure('mensagem de teste')),
      );

      final result = await service.updateVehicleFromForm(
        id: '42',
        brand: 'Chevrolet',
        model: 'Onix',
        licensePlate: 'XYZ5678',
        year: '2022',
        color: 'Preto',
      );

      expect(result.isLeft(), isTrue);
      expect(result.fold((f) => f.message, (_) => null), 'mensagem de teste');
    });
  });

  group('saveVehicle', () {
    test('forwards the given entity directly to the repository', () async {
      final vehicle = VehicleEntity(
        brand: 'Fiat',
        model: 'Uno',
        licensePlate: 'ABC1234',
      );
      when(
        () => mockRepository.saveVehicle(vehicle),
      ).thenAnswer((_) async => Right(null));

      final result = await service.saveVehicle(vehicle);

      verify(() => mockRepository.saveVehicle(vehicle)).called(1);
      expect(result.isRight(), isTrue);
    });
  });
}
