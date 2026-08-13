import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/login/login_cubit.dart';
import 'package:autolog_app/ui/routes/login/login_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('LoginCubit', () {
    group('SignIn', () {
      blocTest<LoginCubit, LoginState>(
        'emits [LoginLoading, LoginSuccess] when sign-in succeeds',
        build: () {
          when(() => mockAuthRepository.signInWithGoogle()).thenAnswer(
            (_) async => Right(
              UserEntity(id: '1', name: 'Test', email: 'test@test.com'),
            ),
          );
          return LoginCubit(repository: mockAuthRepository);
        },
        act: (cubit) => cubit.signIn(),
        expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [LoginLoading, LoginError] when sign-in fails',
        build: () {
          when(
            () => mockAuthRepository.signInWithGoogle(),
          ).thenAnswer((_) async => Left(UnexpectedFailure('mensagem de teste')));
          return LoginCubit(repository: mockAuthRepository);
        },
        act: (cubit) => cubit.signIn(),
        expect: () => [
          isA<LoginLoading>(),
          isA<LoginError>().having(
            (state) => state.message,
            'message',
            'mensagem de teste',
          ),
        ],
      );
    });

    group('SignOut', () {
      blocTest<LoginCubit, LoginState>(
        'emits [LoginLoading, LoginInitial] when sign-out succeeds',
        build: () {
          when(() => mockAuthRepository.signOut()).thenAnswer(
            (_) async => Right(null),
          );
          return LoginCubit(repository: mockAuthRepository);
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [isA<LoginLoading>(), isA<LoginInitial>()],
      );

      blocTest<LoginCubit, LoginState>(
        'emits [LoginLoading, LoginError] when sign-out fails',
        build: () {
          when(
            () => mockAuthRepository.signOut(),
          ).thenAnswer((_) async => Left(UnexpectedFailure('mensagem de teste')));
          return LoginCubit(repository: mockAuthRepository);
        },
        act: (cubit) => cubit.signOut(),
        expect: () => [
          isA<LoginLoading>(),
          isA<LoginError>().having(
            (state) => state.message,
            'message',
            'mensagem de teste',
          ),
        ],
      );
    });
  });
}
