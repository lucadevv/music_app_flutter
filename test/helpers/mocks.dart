import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_response.dart';
import 'package:music_app/features/auth/register/domain/entities/register_request.dart';
import 'package:music_app/features/auth/register/domain/entities/register_response.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';

import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/search/domain/entities/recent_search.dart';
import 'package:music_app/features/search/domain/entities/search_request.dart';
import 'package:music_app/features/search/domain/entities/search_response.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';

// ============ Repository Mocks ============

class MockHomeRepository extends Mock implements HomeRepository {}

class MockSearchRepository extends Mock implements SearchRepository {}

class MockDownloadsRepository extends Mock implements DownloadsRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

// ============ Manager Mocks ============

class MockAuthManager extends Mock implements AuthManager {}

// ============ Repository Method Stubs ============

/// Stub para HomeRepository.getHome
void stubHomeRepositoryGetHome(
  MockHomeRepository mockRepository, {
  required Either<AppException, HomeResponse> response,
}) {
  when(() => mockRepository.getHome()).thenAnswer((_) async => response);
}

/// Stub para SearchRepository.search
void stubSearchRepositorySearch(
  MockSearchRepository mockRepository, {
  required SearchRequest request,
  required Either<AppException, SearchResponse> response,
}) {
  when(() => mockRepository.search(request)).thenAnswer((_) async => response);
}

/// Stub para SearchRepository.getRecentSearches
void stubSearchRepositoryGetRecentSearches(
  MockSearchRepository mockRepository, {
  required Either<AppException, List<RecentSearch>> response,
  int limit = 10,
}) {
  when(() => mockRepository.getRecentSearches(limit: limit))
      .thenAnswer((_) async => response);
}

/// Stub para DownloadsRepository.getDownloadedSongs
void stubDownloadsRepositoryGetDownloadedSongs(
  MockDownloadsRepository mockRepository, {
  required Either<AppException, List<DownloadedSong>> response,
}) {
  when(() => mockRepository.getDownloadedSongs())
      .thenAnswer((_) async => response);
}

/// Stub para DownloadsRepository.downloadSong
void stubDownloadsRepositoryDownloadSong(
  MockDownloadsRepository mockRepository, {
  required Either<AppException, DownloadedSong> response,
}) {
  when(() => mockRepository.downloadSong(
        videoId: any(named: 'videoId'),
        title: any(named: 'title'),
        artist: any(named: 'artist'),
        album: any(named: 'album'),
        thumbnail: any(named: 'thumbnail'),
        streamUrl: any(named: 'streamUrl'),
        duration: any(named: 'duration'),
        onProgress: any(named: 'onProgress'),
      )).thenAnswer((_) async => response);
}

/// Stub para DownloadsRepository.removeDownload
void stubDownloadsRepositoryRemoveDownload(
  MockDownloadsRepository mockRepository, {
  required Either<AppException, void> response,
}) {
  when(() => mockRepository.removeDownload(any()))
      .thenAnswer((_) async => response);
}

/// Stub para DownloadsRepository.isDownloaded
void stubDownloadsRepositoryIsDownloaded(
  MockDownloadsRepository mockRepository, {
  required Either<AppException, bool> response,
}) {
  when(() => mockRepository.isDownloaded(any()))
      .thenAnswer((_) async => response);
}

/// Stub para AuthRepository.register
void stubAuthRepositoryRegister(
  MockAuthRepository mockRepository, {
  required RegisterRequest request,
  required Either<AppException, RegisterResponse> response,
}) {
  when(() => mockRepository.register(request))
      .thenAnswer((_) async => response);
}

/// Stub para AuthRepository.login
void stubAuthRepositoryLogin(
  MockAuthRepository mockRepository, {
  required LoginRequest request,
  required Either<AppException, RegisterResponse> response,
}) {
  when(() => mockRepository.login(request))
      .thenAnswer((_) async => response);
}

/// Stub para AuthRepository.refreshToken
void stubAuthRepositoryRefreshToken(
  MockAuthRepository mockRepository, {
  required RefreshTokenRequest request,
  required Either<AppException, RefreshTokenResponse> response,
}) {
  when(() => mockRepository.refreshToken(request))
      .thenAnswer((_) async => response);
}

// ============ AuthManager Method Stubs ============

/// Stub para AuthManager.isUserLoggedIn
void stubAuthManagerIsUserLoggedIn(
  MockAuthManager mockManager, {
  required bool result,
}) {
  when(() => mockManager.isUserLoggedIn()).thenAnswer((_) async => result);
}

/// Stub para AuthManager.login
void stubAuthManagerLogin(MockAuthManager mockManager) {
  when(() => mockManager.login(
        any(),
        any(),
        isEmailVerified: any(named: 'isEmailVerified'),
        email: any(named: 'email'),
      )).thenAnswer((_) async {});
}

/// Stub para AuthManager.logout
void stubAuthManagerLogout(MockAuthManager mockManager) {
  when(() => mockManager.logout()).thenAnswer((_) async {});
}

/// Stub para AuthManager.isEmailVerified
void stubAuthManagerIsEmailVerified(
  MockAuthManager mockManager, {
  required bool? result,
}) {
  when(() => mockManager.isEmailVerified()).thenAnswer((_) async => result);
}
