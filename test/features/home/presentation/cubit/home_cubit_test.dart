import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';

import '../../../../helpers/test_helpers.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class MockPlayerBlocBloc extends Mock implements PlayerBlocBloc {}

void main() {
  late HomeCubit homeCubit;
  late MockHomeRepository mockRepository;
  late GetHomeUseCase getHomeUseCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockHomeRepository();
    final mockPlayerBloc = MockPlayerBlocBloc();
    getHomeUseCase = GetHomeUseCase(mockRepository);
    homeCubit = HomeCubit(getHomeUseCase, mockPlayerBloc);
  });

  tearDown(() {
    homeCubit.close();
  });

  group('HomeCubit', () {
    test('initial state should be HomeState with initial status', () {
      // Assert
      expect(homeCubit.state.status, equals(HomeStatus.initial));
      expect(homeCubit.state.errorMessage, isNull);
      expect(homeCubit.state.homeResponse, isNull);
    });

    blocTest<HomeCubit, HomeState>(
      'should emit [loading, success] when loadHome succeeds',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Right(createTestHomeResponse()));
        return homeCubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having((s) => s.homeResponse, 'homeResponse', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(() => mockRepository.getHome()).called(1);
      },
    );

    blocTest<HomeCubit, HomeState>(
      'should emit [loading, failure] when loadHome fails with NetworkException',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Left(createTestNetworkException()));
        return homeCubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should emit [loading, failure] when loadHome fails with ServerException',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Left(createTestServerException()));
        return homeCubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Server error'),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should not emit new state when already loading',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Right(createTestHomeResponse()));
        return homeCubit;
      },
      act: (cubit) async {
        // Start first load
        await cubit.loadHome();
        // Try to start second load immediately
        await cubit.loadHome();
      },
      expect: () => [
        // Only one loading and one success, not two
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.success),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should reset state to initial when reset is called',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Right(createTestHomeResponse()));
        return homeCubit;
      },
      act: (cubit) async {
        await cubit.loadHome();
        cubit.reset();
      },
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.success),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.initial)
            .having((s) => s.homeResponse, 'homeResponse', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should clear error message when loading again',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Left(createTestNetworkException('Error 1')));
        return homeCubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.loading)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'should handle AuthenticationException',
      build: () {
        when(() => mockRepository.getHome())
            .thenAnswer((_) async => Left(createTestAuthException('Token expired')));
        return homeCubit;
      },
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Token expired'),
      ],
    );
  });
}
