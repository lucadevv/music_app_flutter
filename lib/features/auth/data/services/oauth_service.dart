import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_app/core/services/logger/app_logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Enum para los proveedores de OAuth
enum OAuthProvider { google, apple }

/// Resultado de una autenticación OAuth
class OAuthResult {
  final String accessToken;
  final String? idToken;
  final String? email;
  final String? name;
  final String? photoUrl;
  final OAuthProvider provider;

  const OAuthResult({
    required this.accessToken,
    required this.provider, this.idToken,
    this.email,
    this.name,
    this.photoUrl,
  });
}

/// Interfaz abstracta para el servicio de OAuth
abstract class OAuthService {
  Future<OAuthResult?> signInWithGoogle();
  Future<OAuthResult?> signInWithApple();
  Future<void> signOut();
}

/// Implementación del servicio de OAuth
class OAuthServiceImpl implements OAuthService {
  final GoogleSignIn _googleSignIn;

  OAuthServiceImpl({
    List<String> googleScopes = const ['email', 'profile'],
  }) : _googleSignIn = GoogleSignIn(
          scopes: googleScopes,
        );

  @override
  Future<OAuthResult?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.info('Google Sign In cancelled by user');
        return null; // Usuario canceló
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      if (accessToken == null) {
        AppLogger.error('Google Sign In: access token is null');
        return null;
      }

      AppLogger.info('Google Sign In successful for ${googleUser.email}');

      return OAuthResult(
        accessToken: accessToken,
        idToken: googleAuth.idToken,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        provider: OAuthProvider.google,
      );
    } catch (e) {
      AppLogger.error('Google Sign In failed', e);
      rethrow;
    }
  }

  @override
  Future<OAuthResult?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final authorizationCode = credential.authorizationCode;

      // Construir el nombre completo
      final name =
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
              .trim();

      AppLogger.info(
          'Apple Sign In successful for ${credential.email ?? 'hidden email'}');

      return OAuthResult(
        accessToken: authorizationCode,
        idToken: credential.identityToken,
        email: credential.email,
        name: name.isEmpty ? null : name,
        provider: OAuthProvider.apple,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        AppLogger.info('Apple Sign In cancelled by user');
        return null;
      }
      AppLogger.error(
          'Apple Sign In failed with SignInWithAppleAuthorizationException', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Apple Sign In failed', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.info('OAuth signOut completed');
    } catch (e) {
      AppLogger.error('OAuth signOut failed', e);
    }
  }
}
