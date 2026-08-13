import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:autolog_app/domain/repository/i_vehicle_repository.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_cubit.dart';
import 'package:autolog_app/ui/routes/main_navigation/vehicle_check_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVehicleRepository extends Mock implements IVehicleRepository {}

void main() {
  late MockVehicleRepository mockVehicleRepository;
  late VehicleEntity vehicleMock;
  late List<VehicleEntity> vehicleList;

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    vehicleMock = VehicleEntity(
      brand: 'brand_test',
      model: 'model_test',
      licensePlate: 'licensePlate_test',
    );
  });

  group(
    'VehicleCheckCubit',
    () {
      group(
        'checkVehicles',
        () {
          blocTest<VehicleCheckCubit, VehicleCheckState>(
            'emits [VehicleCheckLoading, VehicleCheckHasVehicles] when the user has registered vehicles',
            build: () {
              vehicleList = [vehicleMock]; // mock 1 veículo cadastrado
              when(() => mockVehicleRepository.getVehicles()).thenAnswer(
                (_) async => Right(vehicleList),
              );
              return VehicleCheckCubit(
                vehicleRepository: mockVehicleRepository,
              );
            },
            act: (cubit) => cubit.checkVehicles(),
            expect: () => [
              isA<VehicleCheckLoading>(),
              isA<VehicleCheckHasVehicles>(),
            ],
          );

          blocTest<VehicleCheckCubit, VehicleCheckState>(
            "emits [VehicleCheckLoading, VehicleCheckNoVehicles] when the user doesn't have registered vehicles",
            build: () {
              vehicleList = []; // mock 0 veículos cadastrados
              when(() => mockVehicleRepository.getVehicles()).thenAnswer(
                (_) async => Right(vehicleList),
              );
              return VehicleCheckCubit(
                vehicleRepository: mockVehicleRepository,
              );
            },
            act: (cubit) => cubit.checkVehicles(),
            expect: () => [
              isA<VehicleCheckLoading>(),
              isA<VehicleCheckNoVehicles>(),
            ],
          );

          blocTest<VehicleCheckCubit, VehicleCheckState>(
            "emits [VehicleCheckLoading, VehicleCheckError] when fetching registered vehicles fails",
            build: () {
              when(() => mockVehicleRepository.getVehicles()).thenAnswer(
                (_) async => Left(UnexpectedFailure('mensagem de teste')),
              );
              return VehicleCheckCubit(
                vehicleRepository: mockVehicleRepository,
              );
            },
            act: (cubit) => cubit.checkVehicles(),
            expect: () => [
              isA<VehicleCheckLoading>(),
              isA<VehicleCheckError>().having(
                (state) => state.message,
                'message',
                'mensagem de teste',
              ),
            ],
          );
        },
      );
    },
  );
}
