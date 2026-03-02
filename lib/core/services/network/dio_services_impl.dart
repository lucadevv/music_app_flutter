import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:music_app/core/config/app_config.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/services/security/ssl_pinning_interceptor.dart';
import 'package:music_app/features/auth/refresh_token/domain/entities/refresh_token_request.dart';
import 'package:music_app/features/auth/refresh_token/domain/use_cases/refresh_token_use_case.dart';
import 'package:music_app/main.dart';

/// SOLID: Open/Closed Principle (OCP)
///
/// Esta clase está abierta para extensión (puede agregar nuevas funcionalidades)
/// pero cerrada para modificación. Si necesitamos cambiar la implementación HTTP,
/// podemos crear otra clase que implemente ApiServices sin modificar esta.
/// La clase usa la abstracción ApiServices y puede ser reemplazada fácilmente.
class DioApiServicesImpl implements ApiServices {
  final Dio _dio;
  final String? _accessToken;
  final String _baseUrl;
  bool _isRefreshing = false;
  Completer<bool>? _refreshTokenCompleter;
  bool _isHandlingAuthError = false;
  Completer<void>? _handleAuthErrorCompleter;

  DioApiServicesImpl(String baseUrl, {String? accessToken})
      : _baseUrl = baseUrl,
        _accessToken = accessToken,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // SSL Pinning - PRIMERO (seguridad)
    if (AppConfig.enableSslPinning) {
      _dio.interceptors.add(
        SslPinningInterceptor(
          allowedSHAFingerprints: AppConfig.sslFingerprints,
          bypassInDebug: AppConfig.bypassSslPinningInDebug,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Obtener el access token actual del AuthManager
          try {
            final authManager = await getIt.getAsync<AuthManager>();
            final currentAccessToken = await authManager.getCurrentAccessToken();
            if (currentAccessToken != null && currentAccessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $currentAccessToken';
            } else if (_accessToken != null && _accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $_accessToken';
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('DioApiServicesImpl: Error obteniendo access token: $e');
            }
            // Si falla, usar el token inicial si existe
            if (_accessToken != null && _accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $_accessToken';
            }
          }

          return handler.next(options);
        },
        onError: (e, handler) async {
          final statusCode = e.response?.statusCode;

          // Solo considerar errores de token para códigos específicos
          // 404, 400, etc. NO son errores de autenticación
          final isTokenError = (statusCode == 401 || statusCode == 403) ||
              (statusCode == 500 && _isTokenRelatedError(e));

          if (isTokenError) {
            // Intentar refrescar el token antes de hacer logout
            final refreshed = await _tryRefreshToken();

            if (refreshed) {
              // Si el refresh fue exitoso, reintentar la petición original
              final requestOptions = e.requestOptions;
              final authManager = await getIt.getAsync<AuthManager>();
              final newToken = await authManager.getCurrentAccessToken();

              if (newToken != null && newToken.isNotEmpty) {
                // Actualizar el header de autorización con el nuevo token
                requestOptions.headers['Authorization'] = 'Bearer $newToken';

                // Reintentar la petición original con retries
                try {
                  final response = await _dio.fetch(requestOptions);
                  return handler.resolve(response);
                } catch (retryError) {
                  // Si el reintento falla después del refresh, verificar si es un error de token
                  final retryStatusCode = (retryError as DioException?)?.response?.statusCode;
                  if (retryStatusCode == 401 || retryStatusCode == 403) {
                    // Solo hacer logout si sigue siendo un error de autenticación
                    await _handleAuthTokenError();
                  }
                  return handler.next(e);
                }
              } else {
                // No hay token nuevo, hacer logout
                await _handleAuthTokenError();
                return handler.next(e);
              }
            } else {
              // El refresh falló - verificar si el refresh token existe
              // Si no existe, significa que el usuario realmente no está autenticado
              final authManager = await getIt.getAsync<AuthManager>();
              final refreshToken = await authManager.getCurrentRefreshToken();
              
              if (refreshToken == null || refreshToken.isEmpty) {
                // No hay refresh token, hacer logout
                await _handleAuthTokenError();
              }
              // Si hay refresh token pero el refresh falló, no hacer logout
              // Puede ser un error temporal del servidor
              return handler.next(e);
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  /// Intenta refrescar el access token usando el refresh token
  ///
  /// Retorna true si el refresh fue exitoso, false en caso contrario.
  /// Si ya hay un refresh en curso, espera a que termine y retorna el mismo resultado.
  Future<bool> _tryRefreshToken() async {
    // Si ya hay un refresh en curso, esperar a que termine
    if (_isRefreshing && _refreshTokenCompleter != null) {
      return _refreshTokenCompleter!.future;
    }

    // Iniciar un nuevo refresh
    _isRefreshing = true;
    _refreshTokenCompleter = Completer<bool>();

    try {
      final authManager = await getIt.getAsync<AuthManager>();
      final refreshToken = await authManager.getCurrentRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('DioApiServicesImpl: No hay refresh token disponible');
        }
        _isRefreshing = false;
        _refreshTokenCompleter!.complete(false);
        _refreshTokenCompleter = null;
        return false;
      }

      // Usar RefreshTokenUseCase para hacer el refresh
      final refreshTokenUseCase = getIt<RefreshTokenUseCase>();
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await refreshTokenUseCase(request);

      return await response.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('DioApiServicesImpl: Error en refresh token: $failure');
          }
          _isRefreshing = false;
          _refreshTokenCompleter!.complete(false);
          _refreshTokenCompleter = null;
          return false;
        },
        (refreshResponse) async {
          // Guardar los nuevos tokens
          await authManager.refreshTokens(
            refreshResponse.accessToken,
            refreshResponse.refreshToken,
            isEmailVerified: refreshResponse.isEmailVerified,
          );

          if (kDebugMode) {
            debugPrint('DioApiServicesImpl: Tokens refrescados exitosamente');
          }

          _isRefreshing = false;
          _refreshTokenCompleter!.complete(true);
          _refreshTokenCompleter = null;
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DioApiServicesImpl: Excepción en refresh token: $e');
      }
      _isRefreshing = false;
      _refreshTokenCompleter!.complete(false);
      _refreshTokenCompleter = null;
      return false;
    }
  }

  Future<void> _handleAuthTokenError() async {
    // Si ya hay un manejo de error de auth en curso, esperar a que termine
    if (_isHandlingAuthError && _handleAuthErrorCompleter != null) {
      return _handleAuthErrorCompleter!.future;
    }

    // Iniciar el manejo de error de auth
    _isHandlingAuthError = true;
    _handleAuthErrorCompleter = Completer<void>();

    try {
      // Limpiar datos de AuthService (LocalStorageService)
      final authService = getIt<AuthService>();
      await authService.clearAuthData();

      // Limpiar datos de TokenManager (FlutterSecureStorage + SharedPreferences)
      final authManager = await getIt.getAsync<AuthManager>();
      await authManager.logout();

      _isHandlingAuthError = false;
      _handleAuthErrorCompleter!.complete();
      _handleAuthErrorCompleter = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DioApiServicesImpl: Error en _handleAuthTokenError: $e');
      }
      // Intentar logout aunque falle clearAuthData
      try {
        final authManager = await getIt.getAsync<AuthManager>();
        await authManager.logout();
      } catch (logoutError) {
        if (kDebugMode) {
          debugPrint('DioApiServicesImpl: Error en logout: $logoutError');
        }
      }
      _isHandlingAuthError = false;
      _handleAuthErrorCompleter!.complete();
      _handleAuthErrorCompleter = null;
    }
  }

  bool _isTokenRelatedError(DioException error) {
    final responseData = error.response?.data;
    final errorMessage = responseData?.toString().toLowerCase() ?? '';
    final errorHeaders = error.response?.headers.toString().toLowerCase() ?? '';

    String message = errorMessage;
    if (responseData is Map<String, dynamic>) {
      message =
          (responseData['message']?.toString().toLowerCase() ?? '') +
          (responseData['error']?.toString().toLowerCase() ?? '');
    }

    final tokenErrorKeywords = [
      'token',
      'unauthorized',
      'forbidden',
      'access token',
      'refresh token',
      'invalid token',
      'expired token',
      'token expired',
      'authentication',
      'authorization',
      'jwt',
      'jwt expired',
      'token inválido',
      'token invalido',
      'sesión expirada',
      'session expired',
      'no autorizado',
      'acceso denegado',
    ];

    final hasTokenKeyword = tokenErrorKeywords.any(
      (keyword) =>
          message.contains(keyword.toLowerCase()) ||
          errorHeaders.contains(keyword.toLowerCase()),
    );

    if (error.response?.statusCode == 500 && hasTokenKeyword) {
      return true;
    }

    return hasTokenKeyword;
  }

  /// Ejecuta una petición con retries automáticos
  Future<Response> _executeWithRetry<T>(
    Future<Response> Function() request, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    DioException? lastError;

    while (attempts < maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        attempts++;

        // No hacer retry para errores 4xx (excepto 401 que ya se maneja en el interceptor)
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500 &&
            e.response!.statusCode != 401) {
          rethrow;
        }

        // No hacer retry si ya alcanzamos el máximo
        if (attempts >= maxRetries) {
          break;
        }

        // Esperar antes del siguiente intento
        await Future.delayed(retryDelay * attempts);
      } catch (e) {
        // Para otros tipos de errores, no hacer retry
        rethrow;
      }
    }

    // Si llegamos aquí, todos los retries fallaron
    throw lastError ?? DioException(
      requestOptions: RequestOptions(path: ''),
      error: 'Max retries exceeded',
    );
  }

  @override
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _executeWithRetry(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  @override
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
  }) async {
    return _executeWithRetry(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: isFormData ? 'multipart/form-data' : 'application/json',
          headers: headers,
        ),
      ),
    );
  }

  @override
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
  }) async {
    return _executeWithRetry(
      () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: isFormData ? 'multipart/form-data' : 'application/json',
          headers: headers,
        ),
      ),
    );
  }

  @override
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    return _executeWithRetry(
      () => _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }
}
