import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';

import '../../../../helpers/test_helpers.dart';

class MockHomeRepositoryForUseCase extends Mock implements HomeRepository {}

void main() {
  late GetHomeUseCase useCase;
  late MockHomeRepositoryForUseCase mockRepository;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockRepository = MockHomeRepositoryForUseCase();
    useCase = GetHomeUseCase(mockRepository);
  });

  group('GetHomeUseCase', () {
    test('should be instantiated with HomeRepository', () {
      // Assert
      expect(useCase, isNotNull);
    });

    test('should return HomeResponse on successful call', () async {
      // Arrange
      final expectedResponse = createTestHomeResponse();
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Right(expectedResponse));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold((error) => fail('Should not return error'), (response) {
        expect(response, equals(expectedResponse));
        expect(response.moods.length, equals(1));
        expect(response.genres.length, equals(1));
        expect(response.sections.length, equals(1));
      });
      verify(() => mockRepository.getHome()).called(1);
    });

    test('should return NetworkException when network fails', () async {
      // Arrange
      final exception = createTestNetworkException('No internet connection');
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((error) {
        expect(error, isA<NetworkException>());
        expect(error.message, equals('No internet connection'));
      }, (response) => fail('Should not return response'));
      verify(() => mockRepository.getHome()).called(1);
    });

    test('should return ServerException when server fails', () async {
      // Arrange
      final exception = createTestServerException('Internal server error');
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((error) {
        expect(error, isA<ServerException>());
        expect(error.message, equals('Internal server error'));
      }, (response) => fail('Should not return response'));
    });

    test('should return AuthenticationException when unauthorized', () async {
      // Arrange
      final exception = createTestAuthException('Unauthorized access');
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((error) {
        expect(error, isA<AuthenticationException>());
        expect(error.message, equals('Unauthorized access'));
      }, (response) => fail('Should not return response'));
    });

    test('should handle HomeResponse with empty sections', () async {
      // Arrange
      final response = HomeResponse(
        moods: [createTestMoodGenre()],
        genres: [createTestMoodGenre()],
        charts: createTestCharts(),
        sections: [],
      );
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Right(response));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold((error) => fail('Should not return error'), (response) {
        expect(response.sections, isEmpty);
      });
    });

    test('should handle HomeResponse with multiple sections', () async {
      // Arrange
      final response = HomeResponse(
        moods: [],
        genres: [],
        charts: createTestCharts(),
        sections: [
          createTestHomeSection(title: 'Section 1'),
          createTestHomeSection(title: 'Section 2'),
          createTestHomeSection(title: 'Section 3'),
        ],
      );
      when(
        () => mockRepository.getHome(),
      ).thenAnswer((_) async => Right(response));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold((error) => fail('Should not return error'), (response) {
        expect(response.sections.length, equals(3));
      });
    });
  });
}
