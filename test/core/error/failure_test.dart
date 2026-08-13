import 'package:autolog_app/core/error/failure.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'mapExceptionToFailure',
    () {
      test(
        'switch case -> case 1 - code [permission-denied] becomes PermissionFailure',
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
        'switch case -> case 2 - code [unavailable] becomes NetworkFailure',
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
        'switch case -> case 3 - code [deadline-exceeded] becomes NetworkFailure',
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
        'switch case -> default - unmapped code becomes ServerFailure',
        () {
          final error = FirebaseException(
            plugin: 'firebase_auth',
            code: 'some-unmapped-code',
          );
          final result = mapExceptionToFailure(error);
          expect(result, isA<ServerFailure>());
        },
      );

      test('when the error is not a FirebaseException', () {
        final error = Exception();
        final result = mapExceptionToFailure(error);
        expect(result, isA<UnexpectedFailure>());
      });
    },
  );
}
