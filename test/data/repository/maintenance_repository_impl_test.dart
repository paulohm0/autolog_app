import 'package:autolog_app/data/repository/maintenance_repository_impl.dart';
import 'package:autolog_app/domain/entity/maintenance_entity.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

MaintenanceEntity _maintenance({
  String? id,
  DateTime? date,
  String workshop = 'Oficina Teste',
}) => MaintenanceEntity(
  id: id,
  vehicleId: 'v1',
  date: date ?? DateTime(2026, 8, 1),
  workshop: workshop,
  description: 'Troca de óleo',
  value: 150,
);

void main() {
  late FakeFirebaseFirestore firestore;
  late MaintenanceRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final firebaseAuth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'u1'),
      signedIn: true,
    );
    repository = MaintenanceRepositoryImpl(
      firestoreDB: firestore,
      firebaseAuth: firebaseAuth,
    );
  });

  group('saveMaintenance', () {
    test('saves the maintenance under users/{uid}/maintenances with the user id', () async {
      final result = await repository.saveMaintenance(_maintenance());

      expect(result.isRight(), isTrue);
      final snapshot = await firestore
          .collection('users')
          .doc('u1')
          .collection('maintenances')
          .get();
      expect(snapshot.docs, hasLength(1));
      expect(snapshot.docs.first.data()['workshop'], 'Oficina Teste');
      expect(snapshot.docs.first.data()['userId'], 'u1');
    });
  });

  group('getMaintenances', () {
    test('returns maintenances ordered by date, most recent first', () async {
      await repository.saveMaintenance(_maintenance(date: DateTime(2026, 1, 1)));
      await repository.saveMaintenance(_maintenance(date: DateTime(2026, 6, 1)));
      await repository.saveMaintenance(_maintenance(date: DateTime(2026, 3, 1)));

      final result = await repository.getMaintenances();

      final maintenances = result.fold((_) => null, (m) => m)!;
      expect(maintenances.map((m) => m.date), [
        DateTime(2026, 6, 1),
        DateTime(2026, 3, 1),
        DateTime(2026, 1, 1),
      ]);
    });
  });

  group('updateMaintenance', () {
    test('updates the fields of an existing maintenance', () async {
      await repository.saveMaintenance(_maintenance(workshop: 'Oficina A'));
      final saved = (await repository.getMaintenances()).fold((_) => null, (m) => m)!.first;

      final result = await repository.updateMaintenance(
        _maintenance(id: saved.id, workshop: 'Oficina B'),
      );

      expect(result.isRight(), isTrue);
      final updated = (await repository.getMaintenances()).fold((_) => null, (m) => m)!.first;
      expect(updated.workshop, 'Oficina B');
    });
  });

  group('deleteMaintenance', () {
    test('removes the maintenance from Firestore', () async {
      await repository.saveMaintenance(_maintenance());
      final saved = (await repository.getMaintenances()).fold((_) => null, (m) => m)!.first;

      final result = await repository.deleteMaintenance(saved.id!);

      expect(result.isRight(), isTrue);
      final remaining = (await repository.getMaintenances()).fold((_) => null, (m) => m)!;
      expect(remaining, isEmpty);
    });
  });
}
