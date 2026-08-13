import 'package:autolog_app/data/repository/auth_repository_impl.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
  });

  group('getCurrentUser', () {
    test('returns the current user when someone is signed in', () async {
      final firebaseAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'u1',
          email: 'test@test.com',
          displayName: 'Test',
        ),
        signedIn: true,
      );
      final repository = AuthRepositoryImpl(
        firebaseAuth: firebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

      final result = await repository.getCurrentUser();

      final user = result.fold((_) => null, (u) => u)!;
      expect(user.id, 'u1');
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test');
    });

    test('returns a failure when no one is signed in', () async {
      final firebaseAuth = MockFirebaseAuth(signedIn: false);
      final repository = AuthRepositoryImpl(
        firebaseAuth: firebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

      final result = await repository.getCurrentUser();

      expect(result.isLeft(), isTrue);
    });
  });

  group('signOut', () {
    test('signs out of both Google and Firebase', () async {
      final firebaseAuth = MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1'),
        signedIn: true,
      );
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      final repository = AuthRepositoryImpl(
        firebaseAuth: firebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );

      final result = await repository.signOut();

      expect(result.isRight(), isTrue);
      expect(firebaseAuth.currentUser, isNull);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}
