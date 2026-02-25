// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i29;
import 'package:flutter/material.dart' as _i30;
import 'package:music_app/features/album/presentation/album_screen.dart' as _i1;
import 'package:music_app/features/artist/presentation/artist_screen.dart'
    as _i2;
import 'package:music_app/features/auth/email_verification/presentation/email_verification_screen.dart'
    as _i5;
import 'package:music_app/features/auth/forgot/presentation/forgot_password_screen.dart'
    as _i6;
import 'package:music_app/features/auth/login/presentation/login_screen.dart'
    as _i13;
import 'package:music_app/features/auth/register/presentation/register_screen.dart'
    as _i22;
import 'package:music_app/features/auth/social/presentation/social_login_screen.dart'
    as _i27;
import 'package:music_app/features/dashboard/presentation/dashboard_shell.dart'
    as _i3;
import 'package:music_app/features/dashboard/presentation/shells/home_shell.dart'
    as _i8;
import 'package:music_app/features/dashboard/presentation/shells/library_shell.dart'
    as _i11;
import 'package:music_app/features/dashboard/presentation/shells/search_shell.dart'
    as _i25;
import 'package:music_app/features/home/presentation/home_screen.dart' as _i7;
import 'package:music_app/features/library/presentation/library_screen.dart'
    as _i10;
import 'package:music_app/features/liked/presentation/liked_songs_screen.dart'
    as _i12;
import 'package:music_app/features/mood_genre/presentation/mood_genre_screen.dart'
    as _i15;
import 'package:music_app/features/onboarding/presentation/onboarding_screen.dart'
    as _i17;
import 'package:music_app/features/player/domain/entities/now_playing_data.dart'
    as _i31;
import 'package:music_app/features/player/presentation/player_screen.dart'
    as _i18;
import 'package:music_app/features/playlist/presentation/playlist_screen.dart'
    as _i19;
import 'package:music_app/features/profile/presentation/downloads_screen.dart'
    as _i4;
import 'package:music_app/features/profile/presentation/language_screen.dart'
    as _i9;
import 'package:music_app/features/profile/presentation/logout_screen.dart'
    as _i14;
import 'package:music_app/features/profile/presentation/my_profile_screen.dart'
    as _i16;
import 'package:music_app/features/profile/presentation/profile_screen.dart'
    as _i20;
import 'package:music_app/features/profile/presentation/settings_screen.dart'
    as _i26;
import 'package:music_app/features/profile/presentation/streaming_quality_screen.dart'
    as _i28;
import 'package:music_app/features/queue/presentation/queue_screen.dart'
    as _i21;
import 'package:music_app/features/relax/presentation/relax_screen.dart'
    as _i23;
import 'package:music_app/features/search/presentation/search_screen.dart'
    as _i24;

/// generated route for
/// [_i1.AlbumScreen]
class AlbumRoute extends _i29.PageRouteInfo<void> {
  const AlbumRoute({List<_i29.PageRouteInfo>? children})
    : super(AlbumRoute.name, initialChildren: children);

  static const String name = 'AlbumRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i1.AlbumScreen();
    },
  );
}

/// generated route for
/// [_i2.ArtistScreen]
class ArtistRoute extends _i29.PageRouteInfo<void> {
  const ArtistRoute({List<_i29.PageRouteInfo>? children})
    : super(ArtistRoute.name, initialChildren: children);

  static const String name = 'ArtistRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i2.ArtistScreen();
    },
  );
}

/// generated route for
/// [_i3.DashboardShell]
class DashboardShell extends _i29.PageRouteInfo<void> {
  const DashboardShell({List<_i29.PageRouteInfo>? children})
    : super(DashboardShell.name, initialChildren: children);

  static const String name = 'DashboardShell';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i3.DashboardShell());
    },
  );
}

/// generated route for
/// [_i4.DownloadsScreen]
class DownloadsRoute extends _i29.PageRouteInfo<void> {
  const DownloadsRoute({List<_i29.PageRouteInfo>? children})
    : super(DownloadsRoute.name, initialChildren: children);

  static const String name = 'DownloadsRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i4.DownloadsScreen();
    },
  );
}

/// generated route for
/// [_i5.EmailVerificationScreen]
class EmailVerificationRoute extends _i29.PageRouteInfo<void> {
  const EmailVerificationRoute({List<_i29.PageRouteInfo>? children})
    : super(EmailVerificationRoute.name, initialChildren: children);

  static const String name = 'EmailVerificationRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i5.EmailVerificationScreen();
    },
  );
}

/// generated route for
/// [_i6.ForgotPasswordScreen]
class ForgotPasswordRoute extends _i29.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i29.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i6.ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [_i7.HomeScreen]
class HomeRoute extends _i29.PageRouteInfo<void> {
  const HomeRoute({List<_i29.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i7.HomeScreen();
    },
  );
}

/// generated route for
/// [_i8.HomeShell]
class HomeShell extends _i29.PageRouteInfo<void> {
  const HomeShell({List<_i29.PageRouteInfo>? children})
    : super(HomeShell.name, initialChildren: children);

  static const String name = 'HomeShell';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i8.HomeShell());
    },
  );
}

/// generated route for
/// [_i9.LanguageScreen]
class LanguageRoute extends _i29.PageRouteInfo<void> {
  const LanguageRoute({List<_i29.PageRouteInfo>? children})
    : super(LanguageRoute.name, initialChildren: children);

  static const String name = 'LanguageRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i9.LanguageScreen();
    },
  );
}

/// generated route for
/// [_i10.LibraryScreen]
class LibraryRoute extends _i29.PageRouteInfo<void> {
  const LibraryRoute({List<_i29.PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i10.LibraryScreen();
    },
  );
}

/// generated route for
/// [_i11.LibraryShell]
class LibraryShell extends _i29.PageRouteInfo<void> {
  const LibraryShell({List<_i29.PageRouteInfo>? children})
    : super(LibraryShell.name, initialChildren: children);

  static const String name = 'LibraryShell';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i11.LibraryShell();
    },
  );
}

/// generated route for
/// [_i12.LikedSongsScreen]
class LikedSongsRoute extends _i29.PageRouteInfo<void> {
  const LikedSongsRoute({List<_i29.PageRouteInfo>? children})
    : super(LikedSongsRoute.name, initialChildren: children);

  static const String name = 'LikedSongsRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i12.LikedSongsScreen();
    },
  );
}

/// generated route for
/// [_i13.LoginScreen]
class LoginRoute extends _i29.PageRouteInfo<void> {
  const LoginRoute({List<_i29.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i13.LoginScreen());
    },
  );
}

/// generated route for
/// [_i14.LogoutScreen]
class LogoutRoute extends _i29.PageRouteInfo<void> {
  const LogoutRoute({List<_i29.PageRouteInfo>? children})
    : super(LogoutRoute.name, initialChildren: children);

  static const String name = 'LogoutRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i14.LogoutScreen();
    },
  );
}

/// generated route for
/// [_i15.MoodGenreScreen]
class MoodGenreRoute extends _i29.PageRouteInfo<MoodGenreRouteArgs> {
  MoodGenreRoute({
    _i30.Key? key,
    required String params,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         MoodGenreRoute.name,
         args: MoodGenreRouteArgs(key: key, params: params),
         initialChildren: children,
       );

  static const String name = 'MoodGenreRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MoodGenreRouteArgs>();
      return _i29.WrappedRoute(
        child: _i15.MoodGenreScreen(key: args.key, params: args.params),
      );
    },
  );
}

class MoodGenreRouteArgs {
  const MoodGenreRouteArgs({this.key, required this.params});

  final _i30.Key? key;

  final String params;

  @override
  String toString() {
    return 'MoodGenreRouteArgs{key: $key, params: $params}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MoodGenreRouteArgs) return false;
    return key == other.key && params == other.params;
  }

  @override
  int get hashCode => key.hashCode ^ params.hashCode;
}

/// generated route for
/// [_i16.MyProfileScreen]
class MyProfileRoute extends _i29.PageRouteInfo<void> {
  const MyProfileRoute({List<_i29.PageRouteInfo>? children})
    : super(MyProfileRoute.name, initialChildren: children);

  static const String name = 'MyProfileRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i16.MyProfileScreen();
    },
  );
}

/// generated route for
/// [_i17.OnboardingScreen]
class OnboardingRoute extends _i29.PageRouteInfo<void> {
  const OnboardingRoute({List<_i29.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i17.OnboardingScreen();
    },
  );
}

/// generated route for
/// [_i18.PlayerScreen]
class PlayerRoute extends _i29.PageRouteInfo<PlayerRouteArgs> {
  PlayerRoute({
    _i30.Key? key,
    required _i31.NowPlayingData nowPlayingData,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PlayerRoute.name,
         args: PlayerRouteArgs(key: key, nowPlayingData: nowPlayingData),
         initialChildren: children,
       );

  static const String name = 'PlayerRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlayerRouteArgs>();
      return _i18.PlayerScreen(
        key: args.key,
        nowPlayingData: args.nowPlayingData,
      );
    },
  );
}

class PlayerRouteArgs {
  const PlayerRouteArgs({this.key, required this.nowPlayingData});

  final _i30.Key? key;

  final _i31.NowPlayingData nowPlayingData;

  @override
  String toString() {
    return 'PlayerRouteArgs{key: $key, nowPlayingData: $nowPlayingData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlayerRouteArgs) return false;
    return key == other.key && nowPlayingData == other.nowPlayingData;
  }

  @override
  int get hashCode => key.hashCode ^ nowPlayingData.hashCode;
}

/// generated route for
/// [_i19.PlaylistScreen]
class PlaylistRoute extends _i29.PageRouteInfo<PlaylistRouteArgs> {
  PlaylistRoute({
    _i30.Key? key,
    required String id,
    List<_i29.PageRouteInfo>? children,
  }) : super(
         PlaylistRoute.name,
         args: PlaylistRouteArgs(key: key, id: id),
         initialChildren: children,
       );

  static const String name = 'PlaylistRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlaylistRouteArgs>();
      return _i29.WrappedRoute(
        child: _i19.PlaylistScreen(key: args.key, id: args.id),
      );
    },
  );
}

class PlaylistRouteArgs {
  const PlaylistRouteArgs({this.key, required this.id});

  final _i30.Key? key;

  final String id;

  @override
  String toString() {
    return 'PlaylistRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlaylistRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i20.ProfileScreen]
class ProfileRoute extends _i29.PageRouteInfo<void> {
  const ProfileRoute({List<_i29.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i20.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i21.QueueScreen]
class QueueRoute extends _i29.PageRouteInfo<void> {
  const QueueRoute({List<_i29.PageRouteInfo>? children})
    : super(QueueRoute.name, initialChildren: children);

  static const String name = 'QueueRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i21.QueueScreen();
    },
  );
}

/// generated route for
/// [_i22.RegisterScreen]
class RegisterRoute extends _i29.PageRouteInfo<void> {
  const RegisterRoute({List<_i29.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i22.RegisterScreen());
    },
  );
}

/// generated route for
/// [_i23.RelaxScreen]
class RelaxRoute extends _i29.PageRouteInfo<void> {
  const RelaxRoute({List<_i29.PageRouteInfo>? children})
    : super(RelaxRoute.name, initialChildren: children);

  static const String name = 'RelaxRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i23.RelaxScreen();
    },
  );
}

/// generated route for
/// [_i24.SearchScreen]
class SearchRoute extends _i29.PageRouteInfo<void> {
  const SearchRoute({List<_i29.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i24.SearchScreen();
    },
  );
}

/// generated route for
/// [_i25.SearchShell]
class SearchShell extends _i29.PageRouteInfo<void> {
  const SearchShell({List<_i29.PageRouteInfo>? children})
    : super(SearchShell.name, initialChildren: children);

  static const String name = 'SearchShell';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return _i29.WrappedRoute(child: const _i25.SearchShell());
    },
  );
}

/// generated route for
/// [_i26.SettingsScreen]
class SettingsRoute extends _i29.PageRouteInfo<void> {
  const SettingsRoute({List<_i29.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i26.SettingsScreen();
    },
  );
}

/// generated route for
/// [_i27.SocialLoginScreen]
class SocialLoginRoute extends _i29.PageRouteInfo<void> {
  const SocialLoginRoute({List<_i29.PageRouteInfo>? children})
    : super(SocialLoginRoute.name, initialChildren: children);

  static const String name = 'SocialLoginRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i27.SocialLoginScreen();
    },
  );
}

/// generated route for
/// [_i28.StreamingQualityScreen]
class StreamingQualityRoute extends _i29.PageRouteInfo<void> {
  const StreamingQualityRoute({List<_i29.PageRouteInfo>? children})
    : super(StreamingQualityRoute.name, initialChildren: children);

  static const String name = 'StreamingQualityRoute';

  static _i29.PageInfo page = _i29.PageInfo(
    name,
    builder: (data) {
      return const _i28.StreamingQualityScreen();
    },
  );
}
