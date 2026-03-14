// ignore_for_file: unawaited_futures
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/features/auth/data/models/oauth_request.dart';
import 'package:music_app/features/auth/data/services/oauth_service.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/login/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/login/domain/use_cases/oauth_sign_in_use_case.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';

import '../../../../helpers/test_helpers.dart';

// ============ Mock Classes ============

class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthManager extends Mock implements AuthManager {}

class MockOAuthService extends Mock implements OAuthService {}

void main() {
  late LoginCubit loginCubit;
  late MockAuthRepository mockRepository;
  late MockAuthManager mockAuthManager;
  late MockOAuthService mockOAuthService;
  late LoginUseCase loginUseCase;
  late GoogleSignInUseCase googleSignInUseCase;
  late AppleSignInUseCase appleSignInUseCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockAuthRepository();
    mockAuthManager = MockAuthManager();
    mockOAuthService = MockOAuthService();

    loginUseCase = LoginUseCase(mockRepository);
    googleSignInUseCase = GoogleSignInUseCase(mockRepository, mockOAuthService);
    appleSignInUseCase = AppleSignInUseCase(mockRepository, mockOAuthService);

    loginCubit = LoginCubit(
      loginUseCase: loginUseCase,
      googleSignInUseCase: googleSignInUseCase,
      appleSignInUseCase: appleSignInUseCase,
    );
  });

  tearDown(() {
    loginCubit.close();
  });

  group('LoginCubit', () {
    test('initial state should be LoginState with initial status', () {
      // Assert
      expect(loginCubit.state.status, equals(LoginStatus.initial));
      expect(loginCubit.state.errorMessage, isNull);
      expect(loginCubit.state.responseEntity, isNull);
    });

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, success] when login succeeds',
      setUp: () {
        // Register mock AuthManager in GetIt
        if (!GetIt.instance.isRegistered<AuthManager>()) {
          GetIt.instance.registerSingletonAsync<AuthManager>(
            () async => mockAuthManager,
          );
        }
      },
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
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
        return loginCubit;
      },
      act: (cubit) => cubit.login(createTestLoginRequest()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.responseEntity, 'responseEntity', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when login fails with NetworkException',
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).thenAnswer((_) async => Left(createTestNetworkException()));
        return loginCubit;
      },
      act: (cubit) => cubit.login(createTestLoginRequest()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when login fails with AuthenticationException',
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).thenAnswer(
          (_) async => Left(createTestAuthException('Invalid credentials')),
        );
        return loginCubit;
      },
      act: (cubit) => cubit.login(createTestLoginRequest()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Invalid credentials',
            ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should not emit new state when already loading',
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).thenAnswer((_) async => Right(createTestRegisterResponse()));
        return loginCubit;
      },
      act: (cubit) async {
        cubit.login(createTestLoginRequest());
        cubit.login(createTestLoginRequest());
      },
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.success,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should reset state to initial when reset is called',
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).thenAnswer((_) async => Right(createTestRegisterResponse()));
        return loginCubit;
      },
      act: (cubit) async {
        await cubit.login(createTestLoginRequest());
        cubit.reset();
      },
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.success,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.initial)
            .having((s) => s.responseEntity, 'responseEntity', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should handle ValidationException',
      build: () {
        when(
          () => mockRepository.login(any(that: isA<LoginRequest>())),
        ).thenAnswer(
          (_) async => Left(createTestValidationException('Invalid email')),
        );
        return loginCubit;
      },
      act: (cubit) => cubit.login(createTestLoginRequest()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Invalid email'),
      ],
    );
  });

  // ============ Google Sign In Tests ============

  group('Google Sign In', () {
    blocTest<LoginCubit, LoginState>(
      'should emit [loading, success] when Google sign in succeeds',
      setUp: () {
        if (!GetIt.instance.isRegistered<AuthManager>()) {
          GetIt.instance.registerSingletonAsync<AuthManager>(
            () async => mockAuthManager,
          );
        }
      },
      build: () {
        when(
          () => mockOAuthService.signInWithGoogle(),
        ).thenAnswer((_) async => createTestOAuthResult());
        when(
          () => mockRepository.signInWithGoogle(any(that: isA<OAuthRequest>())),
        ).thenAnswer((_) async => Right(createTestOAuthResponse()));
        when(
          () => mockAuthManager.login(
            any(),
            any(),
            isEmailVerified: any(named: 'isEmailVerified'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.responseEntity, 'responseEntity', isNotNull),
      ],
      verify: (_) {
        verify(() => mockOAuthService.signInWithGoogle()).called(1);
        verify(
          () => mockRepository.signInWithGoogle(any(that: isA<OAuthRequest>())),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when Google sign in is cancelled',
      build: () {
        when(
          () => mockOAuthService.signInWithGoogle(),
        ).thenAnswer((_) async => null);
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when Google sign in fails',
      build: () {
        when(
          () => mockOAuthService.signInWithGoogle(),
        ).thenAnswer((_) async => createTestOAuthResult());
        when(
          () => mockRepository.signInWithGoogle(any(that: isA<OAuthRequest>())),
        ).thenAnswer(
          (_) async => Left(createTestAuthException('Google auth failed')),
        );
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithGoogle(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('failed')),
      ],
    );
  });

  // ============ Apple Sign In Tests ============

  group('Apple Sign In', () {
    blocTest<LoginCubit, LoginState>(
      'should emit [loading, success] when Apple sign in succeeds',
      setUp: () {
        if (!GetIt.instance.isRegistered<AuthManager>()) {
          GetIt.instance.registerSingletonAsync<AuthManager>(
            () async => mockAuthManager,
          );
        }
      },
      build: () {
        when(() => mockOAuthService.signInWithApple()).thenAnswer(
          (_) async => createTestOAuthResult(provider: OAuthProvider.apple),
        );
        when(
          () => mockRepository.signInWithApple(any(that: isA<OAuthRequest>())),
        ).thenAnswer((_) async => Right(createTestOAuthResponse()));
        when(
          () => mockAuthManager.login(
            any(),
            any(),
            isEmailVerified: any(named: 'isEmailVerified'),
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async {});
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithApple(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.responseEntity, 'responseEntity', isNotNull),
      ],
      verify: (_) {
        verify(() => mockOAuthService.signInWithApple()).called(1);
        verify(
          () => mockRepository.signInWithApple(any(that: isA<OAuthRequest>())),
        ).called(1);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when Apple sign in is cancelled',
      build: () {
        when(
          () => mockOAuthService.signInWithApple(),
        ).thenAnswer((_) async => null);
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithApple(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'should emit [loading, failure] when Apple sign in fails',
      build: () {
        when(() => mockOAuthService.signInWithApple()).thenAnswer(
          (_) async => createTestOAuthResult(provider: OAuthProvider.apple),
        );
        when(
          () => mockRepository.signInWithApple(any(that: isA<OAuthRequest>())),
        ).thenAnswer((_) async => Left(createTestNetworkException()));
        return loginCubit;
      },
      act: (cubit) => cubit.signInWithApple(),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}

// Note: createTestOAuthResult and createTestOAuthResponse are defined in test_helpers.dart

// Note: createTestOAuthResult and createTestOAuthResponse are defined in test_helpers.dart
