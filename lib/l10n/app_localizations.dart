import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Music App'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove Download'**
  String get removeDownload;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get playlists;

  /// No description provided for @recentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'Recently Played'**
  String get recentlyPlayed;

  /// No description provided for @noRecentlyPlayed.
  ///
  /// In en, this message translates to:
  /// **'No recently played'**
  String get noRecentlyPlayed;

  /// No description provided for @songsYouListenToWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Songs you listen to will appear here'**
  String get songsYouListenToWillAppearHere;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @downloadsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Songs you download will appear here'**
  String get downloadsWillAppearHere;

  /// No description provided for @deleteDownload.
  ///
  /// In en, this message translates to:
  /// **'Delete Download'**
  String get deleteDownload;

  /// No description provided for @downloadSettings.
  ///
  /// In en, this message translates to:
  /// **'Download Settings'**
  String get downloadSettings;

  /// No description provided for @audioQuality.
  ///
  /// In en, this message translates to:
  /// **'Audio Quality'**
  String get audioQuality;

  /// No description provided for @downloadOverWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download over Wi-Fi only'**
  String get downloadOverWifiOnly;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @yourLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your Library'**
  String get yourLibrary;

  /// No description provided for @likedSongs.
  ///
  /// In en, this message translates to:
  /// **'Liked Songs'**
  String get likedSongs;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @yourLibraryIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get yourLibraryIsEmpty;

  /// No description provided for @songsAndPlaylistsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Songs and playlists you like will appear here'**
  String get songsAndPlaylistsWillAppearHere;

  /// No description provided for @exploreMusic.
  ///
  /// In en, this message translates to:
  /// **'Explore Music'**
  String get exploreMusic;

  /// No description provided for @removeFromLikedSongs.
  ///
  /// In en, this message translates to:
  /// **'Remove from Liked Songs'**
  String get removeFromLikedSongs;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to Playlist'**
  String get addToPlaylist;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create Playlist'**
  String get createPlaylist;

  /// No description provided for @playlistName.
  ///
  /// In en, this message translates to:
  /// **'Playlist name'**
  String get playlistName;

  /// No description provided for @myPlaylists.
  ///
  /// In en, this message translates to:
  /// **'My Playlists'**
  String get myPlaylists;

  /// No description provided for @noPlaylistsYet.
  ///
  /// In en, this message translates to:
  /// **'No playlists yet'**
  String get noPlaylistsYet;

  /// No description provided for @createPlaylistToOrganize.
  ///
  /// In en, this message translates to:
  /// **'Create playlists to organize your music'**
  String get createPlaylistToOrganize;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @errorLoadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Error loading library'**
  String get errorLoadingLibrary;

  /// No description provided for @musicLanguages.
  ///
  /// In en, this message translates to:
  /// **'Music Language(s)'**
  String get musicLanguages;

  /// No description provided for @streamingQuality.
  ///
  /// In en, this message translates to:
  /// **'Streaming Quality'**
  String get streamingQuality;

  /// No description provided for @downloadQuality.
  ///
  /// In en, this message translates to:
  /// **'Download Quality'**
  String get downloadQuality;

  /// No description provided for @autoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto-Play'**
  String get autoPlay;

  /// No description provided for @showLyricsOnPlayer.
  ///
  /// In en, this message translates to:
  /// **'Show Lyrics on Player'**
  String get showLyricsOnPlayer;

  /// No description provided for @equalizer.
  ///
  /// In en, this message translates to:
  /// **'Equalizer'**
  String get equalizer;

  /// No description provided for @adjustAudioSettings.
  ///
  /// In en, this message translates to:
  /// **'Adjust audio settings'**
  String get adjustAudioSettings;

  /// No description provided for @connectToDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect to a Device'**
  String get connectToDevice;

  /// No description provided for @listenAndControlOnDevices.
  ///
  /// In en, this message translates to:
  /// **'Listen to and control music on your devices'**
  String get listenAndControlOnDevices;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @hd.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get hd;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'songs'**
  String get songs;

  /// No description provided for @appPreferencesAndAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'App preferences and account settings'**
  String get appPreferencesAndAccountSettings;

  /// No description provided for @manageYourDownloadedMusic.
  ///
  /// In en, this message translates to:
  /// **'Manage your downloaded music'**
  String get manageYourDownloadedMusic;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmation;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnknown;

  /// No description provided for @song.
  ///
  /// In en, this message translates to:
  /// **'Song'**
  String get song;

  /// No description provided for @deleteDownloadConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete download'**
  String get deleteDownloadConfirmation;

  /// No description provided for @deleteDownloadMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\" from your downloads?'**
  String deleteDownloadMessage(String title);

  /// No description provided for @downloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading'**
  String get downloadingTitle;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @discoverNewMusic.
  ///
  /// In en, this message translates to:
  /// **'Discover New Music'**
  String get discoverNewMusic;

  /// No description provided for @discoverNewMusicDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore millions of songs and find your next musical obsession'**
  String get discoverNewMusicDesc;

  /// No description provided for @createYourPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Create Your Playlists'**
  String get createYourPlaylists;

  /// No description provided for @createYourPlaylistsDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize your favorite music and share your playlists with friends'**
  String get createYourPlaylistsDesc;

  /// No description provided for @listenWithoutLimits.
  ///
  /// In en, this message translates to:
  /// **'Listen Without Limits'**
  String get listenWithoutLimits;

  /// No description provided for @listenWithoutLimitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy high-quality music without interruptions, wherever you are'**
  String get listenWithoutLimitsDesc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @enterYourCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials'**
  String get enterYourCredentials;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'We have sent a verification link to your email address.'**
  String get verificationEmailSent;

  /// No description provided for @openMyEmail.
  ///
  /// In en, this message translates to:
  /// **'Open my email'**
  String get openMyEmail;

  /// No description provided for @couldNotOpenEmailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open email application'**
  String get couldNotOpenEmailApp;

  /// No description provided for @errorClosingSession.
  ///
  /// In en, this message translates to:
  /// **'Error closing session. Please try again.'**
  String get errorClosingSession;

  /// No description provided for @onceVerifiedAccess.
  ///
  /// In en, this message translates to:
  /// **'Once you verify your email, you will be able to access all app features.'**
  String get onceVerifiedAccess;

  /// No description provided for @logoutTokensWarning.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout? All your tokens will be deleted.'**
  String get logoutTokensWarning;

  /// No description provided for @likedSongsCount.
  ///
  /// In en, this message translates to:
  /// **'liked songs'**
  String get likedSongsCount;

  /// No description provided for @noLikedSongsYet.
  ///
  /// In en, this message translates to:
  /// **'No liked songs yet'**
  String get noLikedSongsYet;

  /// No description provided for @songsYouLikeWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Songs you like will appear here'**
  String get songsYouLikeWillAppearHere;

  /// No description provided for @errorLoadingSongs.
  ///
  /// In en, this message translates to:
  /// **'Error loading songs'**
  String get errorLoadingSongs;

  /// No description provided for @errorLoadingPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Error loading playlist'**
  String get errorLoadingPlaylist;

  /// No description provided for @errorLoadingHome.
  ///
  /// In en, this message translates to:
  /// **'Error loading home'**
  String get errorLoadingHome;

  /// No description provided for @errorLoadingPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Error loading playlists'**
  String get errorLoadingPlaylists;

  /// No description provided for @monthsJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthsJan;

  /// No description provided for @monthsFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthsFeb;

  /// No description provided for @monthsMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthsMar;

  /// No description provided for @monthsApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthsApr;

  /// No description provided for @monthsMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthsMay;

  /// No description provided for @monthsJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthsJun;

  /// No description provided for @monthsJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthsJul;

  /// No description provided for @monthsAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthsAug;

  /// No description provided for @monthsSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthsSep;

  /// No description provided for @monthsOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthsOct;

  /// No description provided for @monthsNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthsNov;

  /// No description provided for @monthsDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthsDec;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hi'**
  String get hi;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @artistName.
  ///
  /// In en, this message translates to:
  /// **'Artist Name'**
  String get artistName;

  /// No description provided for @monthlyListeners.
  ///
  /// In en, this message translates to:
  /// **'monthly listeners'**
  String get monthlyListeners;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @relax.
  ///
  /// In en, this message translates to:
  /// **'Relax'**
  String get relax;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @energize.
  ///
  /// In en, this message translates to:
  /// **'Energize'**
  String get energize;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @areYouSureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queue;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// No description provided for @autoRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Auto-Recommendations'**
  String get autoRecommendations;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @mix.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get mix;

  /// No description provided for @albumName.
  ///
  /// In en, this message translates to:
  /// **'Album Name'**
  String get albumName;

  /// No description provided for @songsCount.
  ///
  /// In en, this message translates to:
  /// **'songs'**
  String get songsCount;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @songsSimilarToThis.
  ///
  /// In en, this message translates to:
  /// **'Songs similar to this'**
  String get songsSimilarToThis;

  /// No description provided for @radio.
  ///
  /// In en, this message translates to:
  /// **'Radio'**
  String get radio;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
