import 'package:autolog_app/data/repository/vehicle_repository_impl.dart';
import 'package:autolog_app/domain/entity/vehicle_entity.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

VehicleEntity _vehicle({String? id, String brand = 'Fiat', String model = 'Uno'}) =>
    VehicleEntity(id: id, brand: brand, model: model, licensePlate: 'ABC1234');

void main() {
  late FakeFirebaseFirestore firestore;
  late VehicleRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final firebaseAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'u1'),
      signedIn: true,
    );
    repository = VehicleRepositoryImpl(
      firestoreDB: firestore,
      firebaseAuth: firebaseAuth,
    );
  });

  group('saveVehicle', () {
    test('saves the vehicle under users/{uid}/vehicles with the user id', () async {
      final result = await repository.saveVehicle(_vehicle());

      expect(result.isRight(), isTrue);
      final snapshot = await firestore
          .collection('users')
          .doc('u1')
          .collection('vehicles')
          .get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['brand'], 'Fiat');
      expect(snapshot.docs.first.data()['userId'], 'u1');
    });
  });

  group('getVehicles', () {
    test('returns every vehicle saved for the current user', () async {
      await repository.saveVehicle(_vehicle(brand: 'Fiat'));
      await repository.saveVehicle(_vehicle(brand: 'Chevrolet'));

      final result = await repository.getVehicles();

      final vehicles = result.fold((_) => null, (v) => v)!;
      expect(vehicles, hasLength(2));
      expect(vehicles.map((v) => v.brand), containsAll(['Fiat', 'Chevrolet']));
    });

    test('does not see vehicles saved by another user', () async {
      await repository.saveVehicle(_vehicle());
      final otherUserAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u2'),
        signedIn: true,
      );
      final otherUserRepository = VehicleRepositoryImpl(
        firestoreDB: firestore,
        firebaseAuth: otherUserAuth,
      );

      final result = await otherUserRepository.getVehicles();

      expect(result.fold((_) => null, (v) => v), isEmpty);
    });
  });

  group('updateVehicle', () {
    test('updates the fields of an existing vehicle', () async {
      await repository.saveVehicle(_vehicle(model: 'Uno'));
      final saved = (await repository.getVehicles()).fold((_) => null, (v) => v)!.first;

      final result = await repository.updateVehicle(
        _vehicle(id: saved.id, model: 'Uno Mille'),
      );

      expect(result.isRight(), isTrue);
      final updated = (await repository.getVehicles()).fold((_) => null, (v) => v)!.first;
      expect(updated.model, 'Uno Mille');
    });
  });

  group('deleteVehicle', () {
    test('removes the vehicle from Firestore', () async {
      await repository.saveVehicle(_vehicle());
      final saved = (await repository.getVehicles()).fold((_) => null, (v) => v)!.first;

      final result = await repository.deleteVehicle(saved.id!);

      expect(result.isRight(), isTrue);
      final remaining = (await repository.getVehicles()).fold((_) => null, (v) => v)!;
      expect(remaining, isEmpty);
    });
  });
}
