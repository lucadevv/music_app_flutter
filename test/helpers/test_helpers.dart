import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/auth/login/domain/entities/login_request.dart';
import 'package:music_app/features/auth/register/domain/entities/register_request.dart';
import 'package:music_app/features/auth/register/domain/entities/register_response.dart';
import 'package:music_app/features/auth/register/domain/entities/user.dart';
import 'package:music_app/features/auth/data/models/oauth_request.dart';
import 'package:music_app/features/auth/data/services/oauth_service.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/home/domain/entities/chart_song.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
import 'package:music_app/features/home/domain/entities/home_section.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import 'package:music_app/features/search/domain/entities/album.dart';
import 'package:music_app/features/search/domain/entities/artist.dart';
import 'package:music_app/features/search/domain/entities/recent_search.dart';
import 'package:music_app/features/search/domain/entities/search_request.dart';
import 'package:music_app/features/search/domain/entities/search_response.dart';
import 'package:music_app/features/search/domain/entities/song.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/auth/login/domain/use_cases/oauth_sign_in_use_case.dart';

// ============ OAuth Mock Classes ============

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

class MockAppleSignInUseCase extends Mock implements AppleSignInUseCase {}

class MockOAuthService extends Mock implements OAuthService {}

// ============ Register Fallback Values ============

void registerFallbackValues() {
  registerFallbackValue(const SearchRequest(query: 'test'));
  registerFallbackValue(const LoginRequest(email: 'test@test.com', password: 'test'));
  registerFallbackValue(
    const RegisterRequest(
      email: 'test@test.com',
      password: 'test123',
      firstName: 'Test',
      lastName: 'User',
    ),
  );
  registerFallbackValue(const OAuthRequest(
    provider: 'google',
    accessToken: 'test_access_token',
  ));
  registerFallbackValue(const NetworkException('test'));
  registerFallbackValue(const ServerException('test'));
  registerFallbackValue(const AuthenticationException('test'));
  registerFallbackValue(const ValidationException('test'));
  registerFallbackValue(const UnknownException('test'));
  registerFallbackValue(Duration.zero);
}

// ============ Test Exceptions ============

AppException createTestNetworkException([String message = 'Network error']) {
  return NetworkException(message);
}

AppException createTestServerException([String message = 'Server error']) {
  return ServerException(message);
}

AppException createTestAuthException([String message = 'Auth error']) {
  return AuthenticationException(message);
}

AppException createTestValidationException([String message = 'Validation error']) {
  return ValidationException(message);
}

AppException createTestUnknownException([String message = 'Unknown error']) {
  return UnknownException(message);
}

// ============ Test Data - Thumbnails ============

List<Thumbnail> createTestThumbnails() {
  return [
    const Thumbnail(url: 'https://example.com/thumb1.jpg', width: 120, height: 120),
    const Thumbnail(url: 'https://example.com/thumb2.jpg', width: 300, height: 300),
    const Thumbnail(url: 'https://example.com/thumb3.jpg', width: 544, height: 544),
  ];
}

Thumbnail createTestThumbnail() {
  return const Thumbnail(url: 'https://example.com/thumb.jpg', width: 544, height: 544);
}

// ============ Test Data - Artists & Albums ============

List<SearchArtist> createTestArtists() {
  return [
    const SearchArtist(name: 'Test Artist 1', id: 'artist1'),
    const SearchArtist(name: 'Test Artist 2', id: 'artist2'),
  ];
}

SearchArtist createTestArtist() {
  return const SearchArtist(name: 'Test Artist', id: 'artist123');
}

SearchAlbum createTestAlbum() {
  return const SearchAlbum(name: 'Test Album', id: 'album123');
}

// ============ Test Data - Songs ============

Song createTestSong({
  String videoId = 'video123',
  String title = 'Test Song',
  String? streamUrl,
}) {
  return Song(
    title: title,
    album: createTestAlbum(),
    artists: createTestArtists(),
    videoId: videoId,
    duration: '3:45',
    durationSeconds: 225,
    views: '1000000',
    isExplicit: false,
    inLibrary: false,
    thumbnails: createTestThumbnails(),
    streamUrl: streamUrl,
    thumbnail: createTestThumbnail(),
  );
}

List<Song> createTestSongs({int count = 3}) {
  return List.generate(
    count,
    (i) => createTestSong(
      videoId: 'video$i',
      title: 'Test Song $i',
      streamUrl: 'https://example.com/stream$i.m4a',
    ),
  );
}

// ============ Test Data - Search Response ============

SearchResponse createTestSearchResponse({
  String query = 'test query',
  int resultCount = 3,
}) {
  return SearchResponse(
    results: createTestSongs(count: resultCount),
    query: query,
  );
}

// ============ Test Data - Recent Search ============

RecentSearch createTestRecentSearch({
  String id = 'search123',
  String videoId = 'video123',
}) {
  return RecentSearch(
    id: id,
    videoId: videoId,
    songData: createTestSong(videoId: videoId),
    createdAt: DateTime(2024, 1, 1, 12, 0),
    lastSearchedAt: DateTime(2024, 1, 1, 12, 0),
  );
}

List<RecentSearch> createTestRecentSearches({int count = 3}) {
  return List.generate(
    count,
    (i) => createTestRecentSearch(id: 'search$i', videoId: 'video$i'),
  );
}

// ============ Test Data - Home Response ============

MoodGenre createTestMoodGenre({
  String name = 'Test Mood',
  String params = 'test_params',
}) {
  return MoodGenre(name: name, params: params);
}

ChartSong createTestChartSong({
  String videoId = 'chart123',
  String title = 'Chart Song',
  String artist = 'Chart Artist',
}) {
  return ChartSong(
    videoId: videoId,
    title: title,
    artist: artist,
    streamUrl: 'https://example.com/stream.m4a',
    thumbnail: 'https://example.com/thumb.jpg',
  );
}

HomeContentItem createTestHomeContentItem({
  String title = 'Home Content',
  String? videoId = 'content123',
  String? playlistId,
}) {
  return HomeContentItem(
    title: title,
    videoId: videoId,
    playlistId: playlistId,
    thumbnails: createTestThumbnails(),
    isExplicit: false,
    artists: createTestArtists(),
    views: '500000',
    album: createTestAlbum(),
  );
}

HomeSection createTestHomeSection({
  String title = 'Test Section',
  int itemCount = 3,
}) {
  return HomeSection(
    title: title,
    contents: List.generate(
      itemCount,
      (i) => createTestHomeContentItem(title: 'Item $i', videoId: 'item$i'),
    ),
  );
}

Charts createTestCharts() {
  return Charts(
    topSongs: List.generate(3, (i) => createTestChartSong(videoId: 'top$i', title: 'Top Song $i')),
    trending: List.generate(3, (i) => createTestChartSong(videoId: 'trend$i', title: 'Trending $i')),
  );
}

HomeResponse createTestHomeResponse() {
  return HomeResponse(
    moods: [createTestMoodGenre(name: 'Happy', params: 'happy')],
    genres: [createTestMoodGenre(name: 'Pop', params: 'pop')],
    charts: createTestCharts(),
    sections: [createTestHomeSection(title: 'Trending Now')],
  );
}

// ============ Test Data - Downloaded Song ============

DownloadedSong createTestDownloadedSong({
  String videoId = 'downloaded123',
  String title = 'Downloaded Song',
  String artist = 'Download Artist',
  String localPath = '/path/to/song.m4a',
  int fileSize = 5000000,
}) {
  return DownloadedSong(
    videoId: videoId,
    title: title,
    artist: artist,
    album: 'Test Album',
    thumbnail: 'https://example.com/thumb.jpg',
    localPath: localPath,
    fileSize: fileSize,
    duration: const Duration(minutes: 3, seconds: 45),
    downloadedAt: DateTime(2024, 1, 1, 12, 0),
  );
}

List<DownloadedSong> createTestDownloadedSongs({int count = 3}) {
  return List.generate(
    count,
    (i) => createTestDownloadedSong(
      videoId: 'downloaded$i',
      title: 'Downloaded Song $i',
    ),
  );
}

// ============ Test Data - Auth ============

User createTestUser({
  String id = 'user123',
  String email = 'test@test.com',
  String firstName = 'Test',
  String lastName = 'User',
  bool isEmailVerified = true,
}) {
  return User(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    avatar: 'https://example.com/avatar.jpg',
    role: 'user',
    isEmailVerified: isEmailVerified,
  );
}

RegisterResponse createTestRegisterResponse({
  String accessToken = 'access_token_123',
  String refreshToken = 'refresh_token_123',
  bool isEmailVerified = true,
}) {
  return RegisterResponse(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: 3600,
    user: createTestUser(isEmailVerified: isEmailVerified),
  );
}

RegisterRequest createTestRegisterRequest({
  String email = 'test@test.com',
  String password = 'password123',
  String firstName = 'Test',
  String lastName = 'User',
}) {
  return RegisterRequest(
    email: email,
    password: password,
    firstName: firstName,
    lastName: lastName,
  );
}

LoginRequest createTestLoginRequest({
  String email = 'test@test.com',
  String password = 'password123',
}) {
  return LoginRequest(
    email: email,
    password: password,
  );
}

// ============ Test Data - Now Playing Data ============

NowPlayingData createTestNowPlayingData({
  String videoId = 'playing123',
  String title = 'Now Playing Song',
  String? streamUrl = 'https://example.com/stream.m4a',
}) {
  return NowPlayingData.fromBasic(
    videoId: videoId,
    title: title,
    artistNames: ['Artist 1', 'Artist 2'],
    albumName: 'Test Album',
    duration: '3:45',
    durationSeconds: 225,
    views: '1000000',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    streamUrl: streamUrl,
  );
}

List<NowPlayingData> createTestNowPlayingList({int count = 3}) {
  return List.generate(
    count,
    (i) => createTestNowPlayingData(
      videoId: 'playing$i',
      title: 'Song $i',
      streamUrl: 'https://example.com/stream$i.m4a',
    ),
  );
}

// ============ Helper Functions for Either Results ============

Either<AppException, T> createLeftResult<T>(AppException exception) {
  return Left(exception);
}

Either<AppException, T> createRightResult<T>(T value) {
  return Right(value);
}

// ============ Test Data - OAuth ============

OAuthRequest createTestOAuthRequest({
  String provider = 'google',
  String accessToken = 'oauth_access_token_123',
  String? idToken = 'oauth_id_token_123',
  String? email = 'test@test.com',
  String? name = 'Test User',
}) {
  return OAuthRequest(
    provider: provider,
    accessToken: accessToken,
    idToken: idToken,
    email: email,
    name: name,
  );
}

OAuthResponse createTestOAuthResponse({
  String accessToken = 'oauth_access_token_123',
  String refreshToken = 'oauth_refresh_token_123',
  int expiresIn = 3600,
  bool isNewUser = false,
  bool isEmailVerified = true,
}) {
  return OAuthResponse(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    user: createTestUser(isEmailVerified: isEmailVerified),
    isNewUser: isNewUser,
  );
}

// ============ Test Data - OAuth Result ============

OAuthResult createTestOAuthResult({
  OAuthProvider provider = OAuthProvider.google,
  String accessToken = 'test_access_token',
  String? idToken = 'test_id_token',
  String? email = 'test@gmail.com',
  String? name = 'Test User',
  String? photoUrl = 'https://example.com/photo.jpg',
}) {
  return OAuthResult(
    accessToken: accessToken,
    idToken: idToken,
    email: email,
    name: name,
    photoUrl: photoUrl,
    provider: provider,
  );
}
