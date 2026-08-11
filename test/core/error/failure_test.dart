import 'package:autolog_app/core/error/failure.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'mapExceptionToFailure',
    () {
      test(
        'swtich case -> case 1 - Firestore code [permission-denied] se torna PermissionFailure',
        () {
          final error = FirebaseException(
            plugin: 'firebase_auth',
            code: 'permission-denied',
          );
          final result = mapExceptionToFailure(error);
          expect(result, isA<PermissionFailure>());
        },
      );

      test(
        'swtich case -> case 2 - Firestore code [unavailable] se torna NetworkFailure',
        () {
          final error = FirebaseException(
            plugin: 'firebase_auth',
            code: 'unavailable',
          );
          final result = mapExceptionToFailure(error);
          expect(result, isA<NetworkFailure>());
        },
      );

      test(
        'swtich case -> case 3 - Firestore code [deadline-exceeded] se torna NetworkFailure',
        () {
          final error = FirebaseException(
            plugin: 'firebase_auth',
            code: 'deadline-exceeded',
          );
          final result = mapExceptionToFailure(error);
          expect(result, isA<NetworkFailure>());
        },
      );

      test(
        'swtich case -> default - Firestore code [erro não listado] se torna ServerFailure',
        () {
          final error = FirebaseException(
            plugin: 'firebase_auth',
            code: 'erro não listado',
          );
          final result = mapExceptionToFailure(error);
          expect(result, isA<ServerFailure>());
        },
      );

      test('se o erro não for um FirebaseException', () {
        final error = Exception();
        final result = mapExceptionToFailure(error);
        expect(result, isA<UnexpectedFailure>());
      });
    },
  );
}
