import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/features/auth/register/domain/entities/register_request.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/register/domain/use_cases/register_use_case.dart';
import 'package:music_app/features/auth/register/presentation/cubit/register_cubit.dart';

import '../../../../helpers/test_helpers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthManager extends Mock implements AuthManager {}

void main() {
  late RegisterCubit registerCubit;
  late MockAuthRepository mockRepository;
  late MockAuthManager mockAuthManager;
  late RegisterUseCase registerUseCase;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    mockAuthManager = MockAuthManager();
    registerUseCase = RegisterUseCase(mockRepository);
    registerCubit = RegisterCubit(registerUseCase: registerUseCase);
  });

  tearDown(() {
    registerCubit.close();
  });

  group('RegisterCubit', () {
    test('initial state should be RegisterState with initial status', () {
      // Assert
      expect(registerCubit.state.status, equals(RegisterStatus.initial));
      expect(registerCubit.state.errorMessage, isNull);
      expect(registerCubit.state.responseEntity, isNull);
    });

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, success] when register succeeds',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Right(createTestRegisterResponse()));
        when(
          () => mockAuthManager.login(
            any(),
            any(),
            isEmailVerified: any(named: 'isEmailVerified'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});
        when(
          () => mockAuthManager.isEmailVerified(),
        ).thenAnswer((_) async => true);
        return registerCubit;
      },
      act: (cubit) => cubit.register(createTestRegisterRequest()),
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.success)
            .having((s) => s.responseEntity, 'responseEntity', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).called(1);
      },
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, failure] when register fails with NetworkException',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Left(createTestNetworkException()));
        return registerCubit;
      },
      act: (cubit) => cubit.register(createTestRegisterRequest()),
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should emit [loading, failure] when register fails with ValidationException',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer(
          (_) async =>
              Left(createTestValidationException('Email already exists')),
        );
        return registerCubit;
      },
      act: (cubit) => cubit.register(createTestRegisterRequest()),
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Email already exists',
            ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should not emit new state when already loading',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Right(createTestRegisterResponse()));
        return registerCubit;
      },
      act: (cubit) async {
        cubit.register(createTestRegisterRequest());
        cubit.register(createTestRegisterRequest());
      },
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.success,
        ),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should reset state to initial when reset is called',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Right(createTestRegisterResponse()));
        return registerCubit;
      },
      act: (cubit) async {
        await cubit.register(createTestRegisterRequest());
        cubit.reset();
      },
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.success,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.initial)
            .having((s) => s.responseEntity, 'responseEntity', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should handle AuthenticationException',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Left(createTestAuthException()));
        return registerCubit;
      },
      act: (cubit) => cubit.register(createTestRegisterRequest()),
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<RegisterCubit, RegisterState>(
      'should handle ServerException',
      build: () {
        when(
          () => mockRepository.register(any(that: isA<RegisterRequest>())),
        ).thenAnswer((_) async => Left(createTestServerException()));
        return registerCubit;
      },
      act: (cubit) => cubit.register(createTestRegisterRequest()),
      expect: () => [
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Server error'),
      ],
    );
  });
}
