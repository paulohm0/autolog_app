import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _googleSignIn = googleSignIn;

  UserEntity _toEntity(User user) => UserEntity(
    id: user.uid,
    email: user.email ?? 'e-mail não informado',
    name: user.displayName ?? 'nome não informado',
    photoUrl: user.photoURL,
  );

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return Left(ServerFailure());

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user!;
      return Right(_toEntity(user));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'signInWithGoogle failed',
        fatal: false,
      );
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return Right(null);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'signOut failed',
        fatal: false,
      );
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Left(ServerFailure());
      return Right(_toEntity(user));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'getCurrentUser failed',
        fatal: false,
      );
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Left(ServerFailure());
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        // O Firebase exige uma prova de login recente pra ações sensíveis
        // como excluir a conta — se a sessão não for recente o bastante,
        // pede confirmação de novo via Google antes de tentar de novo.
        if (e.code != 'requires-recent-login') rethrow;
        await _reauthenticate();
        await user.delete();
      }
      return Right(null);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'deleteAccount failed',
        fatal: false,
      );
      return Left(mapExceptionToFailure(e));
    }
  }

  Future<void> _reauthenticate() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
  }
}
