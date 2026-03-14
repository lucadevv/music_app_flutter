// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Music App';

  @override
  String get home => 'Inicio';

  @override
  String get search => 'Buscar';

  @override
  String get library => 'Biblioteca';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get play => 'Reproducir';

  @override
  String get pause => 'Pausar';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get shuffle => 'Aleatorio';

  @override
  String get repeat => 'Repetir';

  @override
  String get download => 'Descargar';

  @override
  String get downloading => 'Descargando...';

  @override
  String get downloaded => 'Descargado';

  @override
  String get removeDownload => 'Eliminar descarga';

  @override
  String get offlineMode => 'Modo sin conexión';

  @override
  String get offline => 'Offline';

  @override
  String get noInternetConnection => 'Sin conexión a internet';

  @override
  String get errorOccurred => 'Ocurrió un error';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get retry => 'Reintentar';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get signInWithGoogle => 'Iniciar con Google';

  @override
  String get signInWithApple => 'Iniciar con Apple';

  @override
  String get favorites => 'Favoritos';

  @override
  String get playlists => 'Listas de reproducción';

  @override
  String get recentlyPlayed => 'Reproducido recientemente';

  @override
  String get noRecentlyPlayed => 'Sin reproducción reciente';

  @override
  String get songsYouListenToWillAppearHere =>
      'Las canciones que escuches aparecerán aquí';

  @override
  String get downloads => 'Descargas';

  @override
  String get noDownloadsYet => 'Sin descargas aún';

  @override
  String get downloadsWillAppearHere =>
      'Las canciones que descargues aparecerán aquí';

  @override
  String get deleteDownload => 'Eliminar descarga';

  @override
  String get downloadSettings => 'Configuración de descargas';

  @override
  String get audioQuality => 'Calidad de audio';

  @override
  String get downloadOverWifiOnly => 'Descargar solo por Wi-Fi';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get systemDefault => 'Predeterminado del sistema';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get yourLibrary => 'Tu biblioteca';

  @override
  String get likedSongs => 'Canciones que te gustan';

  @override
  String get genres => 'Géneros';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get yourLibraryIsEmpty => 'Tu biblioteca está vacía';

  @override
  String get songsAndPlaylistsWillAppearHere =>
      'Las canciones y playlists que te gusten aparecerán aquí';

  @override
  String get exploreMusic => 'Explorar música';

  @override
  String get removeFromLikedSongs => 'Quitar de Canciones que te gustan';

  @override
  String get addToPlaylist => 'Agregar a playlist';

  @override
  String get createPlaylist => 'Crear playlist';

  @override
  String get playlistName => 'Nombre de la playlist';

  @override
  String get myPlaylists => 'Mis playlists';

  @override
  String get noPlaylistsYet => 'Sin playlists aún';

  @override
  String get createPlaylistToOrganize =>
      'Crea playlists para organizar tu música';

  @override
  String get share => 'Compartir';

  @override
  String get errorLoadingLibrary => 'Error al cargar la biblioteca';

  @override
  String get musicLanguages => 'Idiomas de música';

  @override
  String get streamingQuality => 'Calidad de streaming';

  @override
  String get downloadQuality => 'Calidad de descarga';

  @override
  String get autoPlay => 'Reproducción automática';

  @override
  String get showLyricsOnPlayer => 'Mostrar letras en el reproductor';

  @override
  String get equalizer => 'Ecualizador';

  @override
  String get adjustAudioSettings => 'Ajusta la configuración de audio';

  @override
  String get connectToDevice => 'Conectar a un dispositivo';

  @override
  String get listenAndControlOnDevices =>
      'Escucha y controla música en tus dispositivos';

  @override
  String get others => 'Otros';

  @override
  String get helpAndSupport => 'Ayuda y soporte';

  @override
  String get hd => 'HD';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get exit => 'Salir';

  @override
  String get errorLoadingProfile => 'Error al cargar el perfil';

  @override
  String get provider => 'Proveedor';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get songs => 'canciones';

  @override
  String get appPreferencesAndAccountSettings =>
      'Preferencias de la app y configuración de cuenta';

  @override
  String get manageYourDownloadedMusic => 'Administra tu música descargada';

  @override
  String get changeAppLanguage => 'Cambia el idioma de la app';

  @override
  String get logoutConfirmation => 'Cerrar sesión';

  @override
  String get logoutConfirmationMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get errorUnknown => 'Error desconocido';

  @override
  String get song => 'Canción';

  @override
  String get deleteDownloadConfirmation => 'Eliminar descarga';

  @override
  String deleteDownloadMessage(String title) {
    return '¿Estás seguro de que quieres eliminar \"$title\" de tus descargas?';
  }

  @override
  String get downloadingTitle => 'Descargando';

  @override
  String get skip => 'Saltar';

  @override
  String get discoverNewMusic => 'Descubre Nueva Música';

  @override
  String get discoverNewMusicDesc =>
      'Explora millones de canciones y encuentra tu próxima obsesión musical';

  @override
  String get createYourPlaylists => 'Crea Tus Playlists';

  @override
  String get createYourPlaylistsDesc =>
      'Organiza tu música favorita y comparte tus playlists con amigos';

  @override
  String get listenWithoutLimits => 'Escucha Sin Límites';

  @override
  String get listenWithoutLimitsDesc =>
      'Disfruta de música de alta calidad sin interrupciones, donde quieras';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get enterYourCredentials => 'Ingresa tus credenciales';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get emailHint => 'tu@email.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => 'Ingresa tu contraseña';

  @override
  String get forgotYourPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get or => 'o';

  @override
  String get noAccount => '¿No tienes una cuenta?';

  @override
  String get register => 'Registrarse';

  @override
  String get welcome => 'Bienvenido a Vibeat';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get verifyYourEmail => 'Verifica tu correo';

  @override
  String get verificationEmailSent =>
      'Hemos enviado un enlace de verificación a tu correo electrónico.';

  @override
  String get openMyEmail => 'Abrir mi correo';

  @override
  String get couldNotOpenEmailApp => 'No se pudo abrir la aplicación de correo';

  @override
  String get errorClosingSession =>
      'Error al cerrar sesión. Intenta nuevamente.';

  @override
  String get onceVerifiedAccess =>
      'Una vez que verifiques tu correo, podrás acceder a todas las funciones de la aplicación.';

  @override
  String get logoutTokensWarning =>
      '¿Estás seguro de que deseas cerrar sesión? Se eliminarán todos tus tokens.';

  @override
  String get likedSongsCount => 'canciones que te gustan';

  @override
  String get noLikedSongsYet => 'Aún no hay canciones que te gusten';

  @override
  String get songsYouLikeWillAppearHere =>
      'Las canciones que te gusten aparecerán aquí';

  @override
  String get errorLoadingSongs => 'Error al cargar las canciones';

  @override
  String get errorLoadingPlaylist => 'Error al cargar la playlist';

  @override
  String get errorLoadingHome => 'Error al cargar el inicio';

  @override
  String get errorLoadingPlaylists => 'Error al cargar las playlists';

  @override
  String get monthsJan => 'Ene';

  @override
  String get monthsFeb => 'Feb';

  @override
  String get monthsMar => 'Mar';

  @override
  String get monthsApr => 'Abr';

  @override
  String get monthsMay => 'May';

  @override
  String get monthsJun => 'Jun';

  @override
  String get monthsJul => 'Jul';

  @override
  String get monthsAug => 'Ago';

  @override
  String get monthsSep => 'Sep';

  @override
  String get monthsOct => 'Oct';

  @override
  String get monthsNov => 'Nov';

  @override
  String get monthsDec => 'Dic';

  @override
  String get hi => 'Hola';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get artistName => 'Nombre del artista';

  @override
  String get monthlyListeners => 'oyentes mensuales';

  @override
  String get popular => 'Popular';

  @override
  String get relax => 'Relax';

  @override
  String get workout => 'Entrenamiento';

  @override
  String get travel => 'Viaje';

  @override
  String get focus => 'Concentración';

  @override
  String get energize => 'Energía';

  @override
  String get profileAndSettings => 'Perfil y Configuración';

  @override
  String get areYouSureYouWantToLogout =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get clear => 'Limpiar';

  @override
  String get queue => 'Cola';

  @override
  String get nowPlaying => 'Reproduciendo ahora';

  @override
  String get upNext => 'Siguiente';

  @override
  String get autoRecommendations => 'Recomendaciones automáticas';

  @override
  String get forYou => 'Para ti';

  @override
  String get mix => 'Mix';

  @override
  String get albumName => 'Nombre del álbum';

  @override
  String get songsCount => 'canciones';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get songsSimilarToThis => 'Canciones similares a esta';

  @override
  String get radio => 'Radio';

  @override
  String hello(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get selectCategories => 'Seleccionar categorías';

  @override
  String get searchFor => 'Buscar canción, artista o álbum...';

  @override
  String get all => 'Todo';

  @override
  String get diveIntoYour => 'Sumérgete en tu';

  @override
  String get vibeat => 'Vibeat.';

  @override
  String get onboardingSubtitle =>
      'Disfruta de una experiencia musical sin interrupciones,\ncreada para cada momento.';

  @override
  String get startExplore => 'Empezar a Explorar';

  @override
  String get recoverPassword => 'Recuperar contraseña';

  @override
  String get emailSent => 'Email enviado';

  @override
  String get checkInbox =>
      'Revisa tu bandeja de entrada para restablecer tu contraseña';

  @override
  String get enterEmailInstructions =>
      'Ingresa tu email y te enviaremos las instrucciones para restablecer tu contraseña';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get signUpToStart => 'Regístrate para comenzar';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get minimum8Characters => 'Mínimo 8 caracteres';

  @override
  String get repeatYourPassword => 'Repite tu contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailPlaceholder => 'tu@email.com';

  @override
  String get pleaseEnterEmail => 'Por favor ingresa tu email';

  @override
  String get enterValidEmail => 'Ingresa un email válido';

  @override
  String get sendInstructions => 'Enviar instrucciones';

  @override
  String get backToLogin => 'Volver a iniciar sesión';

  @override
  String get successfullyLoggedIn => 'Sesión iniciada exitosamente';
}
