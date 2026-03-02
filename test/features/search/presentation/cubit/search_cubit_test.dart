import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/search/domain/entities/search_request.dart';
import 'package:music_app/features/search/domain/entities/search_response.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/presentation/cubit/search_cubit.dart';

import '../../../../helpers/test_helpers.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SearchCubit searchCubit;
  late MockSearchRepository mockRepository;
  late SearchUseCase searchUseCase;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockSearchRepository();
    searchUseCase = SearchUseCase(mockRepository);
    searchCubit = SearchCubit(searchUseCase: searchUseCase);
  });

  tearDown(() {
    searchCubit.close();
  });

  group('SearchCubit', () {
    test('initial state should be SearchState with initial status', () {
      // Assert
      expect(searchCubit.state.status, equals(SearchStatus.initial));
      expect(searchCubit.state.errorMessage, isNull);
      expect(searchCubit.state.responseEntity, isNull);
      expect(searchCubit.state.query, isEmpty);
    });

    blocTest<SearchCubit, SearchState>(
      'should emit [loading, success] when search succeeds',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Right(createTestSearchResponse()));
        return searchCubit;
      },
      act: (cubit) => cubit.search('test query'),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading)
            .having((s) => s.query, 'query', 'test query'),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.success)
            .having((s) => s.responseEntity, 'responseEntity', isNotNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .called(1);
      },
    );

    blocTest<SearchCubit, SearchState>(
      'should emit initial state when query is empty',
      build: () => searchCubit,
      act: (cubit) => cubit.search(''),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.initial)
            .having((s) => s.query, 'query', isEmpty)
            .having((s) => s.responseEntity, 'responseEntity', isNull),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should emit initial state when query is only whitespace',
      build: () => searchCubit,
      act: (cubit) => cubit.search('   '),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.initial)
            .having((s) => s.query, 'query', isEmpty)
            .having((s) => s.responseEntity, 'responseEntity', isNull),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should emit [loading, failure] when search fails',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Left(createTestNetworkException()));
        return searchCubit;
      },
      act: (cubit) => cubit.search('test query'),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should not emit new state when already loading',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Right(createTestSearchResponse()));
        return searchCubit;
      },
      act: (cubit) async {
        await cubit.search('query 1');
        await cubit.search('query 2');
      },
      expect: () => [
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.success),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should reset state to initial when reset is called',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Right(createTestSearchResponse()));
        return searchCubit;
      },
      act: (cubit) async {
        await cubit.search('test query');
        cubit.reset();
      },
      expect: () => [
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.success),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.initial)
            .having((s) => s.query, 'query', isEmpty)
            .having((s) => s.responseEntity, 'responseEntity', isNull)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should trim whitespace from query',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Right(createTestSearchResponse()));
        return searchCubit;
      },
      act: (cubit) => cubit.search('  test query  '),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.loading)
            .having((s) => s.query, 'query', '  test query  '),
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.success),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should handle ServerException',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => Left(createTestServerException()));
        return searchCubit;
      },
      act: (cubit) => cubit.search('test query'),
      expect: () => [
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', 'Server error'),
      ],
    );

    blocTest<SearchCubit, SearchState>(
      'should handle empty results',
      build: () {
        when(() => mockRepository.search(any(that: isA<SearchRequest>())))
            .thenAnswer((_) async => const Right(SearchResponse(results: [], query: 'test')));
        return searchCubit;
      },
      act: (cubit) => cubit.search('test'),
      expect: () => [
        isA<SearchState>().having((s) => s.status, 'status', SearchStatus.loading),
        isA<SearchState>()
            .having((s) => s.status, 'status', SearchStatus.success)
            .having((s) => s.responseEntity!.results, 'results', isEmpty),
      ],
    );
  });
}
