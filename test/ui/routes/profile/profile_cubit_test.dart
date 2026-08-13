import 'package:autolog_app/core/error/failure.dart';
import 'package:autolog_app/domain/entity/user_entity.dart';
import 'package:autolog_app/domain/repository/i_auth_repository.dart';
import 'package:autolog_app/ui/routes/profile/profile_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_state.dart';
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
  group(
    'ProfileCubit',
    () {
      group(
        'loadUser',
        () {
          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileLoaded] when user info loads successfully',
            build: () {
              when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
                (_) async => Right(
                  UserEntity(id: '1', name: 'Test', email: 'test@test.com'),
                ),
              );
              return ProfileCubit(repository: mockAuthRepository);
            },
            act: (cubit) => cubit.loadUser(),
            expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
          );

          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileError] when loading user info fails',
            build: () {
              when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
                (_) async => Left(UnexpectedFailure('mensagem de teste')),
              );
              return ProfileCubit(repository: mockAuthRepository);
            },
            act: (cubit) => cubit.loadUser(),
            expect: () => [
              isA<ProfileLoading>(),
              isA<ProfileError>().having(
                (state) => state.message,
                'message',
                'mensagem de teste',
              ),
            ],
          );
        },
      );

      group(
        'signOut',
        () {
          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileSignedOut] when sign-out succeeds',
            build: () {
              when(() => mockAuthRepository.signOut()).thenAnswer(
                (_) async => Right(null),
              );
              return ProfileCubit(repository: mockAuthRepository);
            },
            act: (cubit) => cubit.signOut(),
            expect: () => [isA<ProfileLoading>(), isA<ProfileSignedOut>()],
          );

          blocTest<ProfileCubit, ProfileState>(
            'emits [ProfileLoading, ProfileError] when sign-out fails',
            build: () {
              when(() => mockAuthRepository.signOut()).thenAnswer(
                (_) async => Left(UnexpectedFailure('mensagem de teste')),
              );
              return ProfileCubit(repository: mockAuthRepository);
            },
            act: (cubit) => cubit.signOut(),
            expect: () => [
              isA<ProfileLoading>(),
              isA<ProfileError>().having(
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
