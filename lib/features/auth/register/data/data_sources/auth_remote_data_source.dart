import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/exeptions/exception_handler.dart';
import '../../domain/entities/register_request.dart';
import '../../../login/domain/entities/login_request.dart';
import '../../../refresh_token/domain/entities/refresh_token_request.dart';
import '../models/register_response_model.dart';
import '../../../refresh_token/data/models/refresh_token_response_model.dart';

/// Data source remoto para operaciones de autenticación
abstract class AuthRemoteDataSource {
  Future<Either<AppException, RegisterResponseModel>> register(
    RegisterRequest request,
  );
  
  Future<Either<AppException, RegisterResponseModel>> login(
    LoginRequest request,
  );
  
  Future<Either<AppException, RefreshTokenResponseModel>> refreshToken(
    RefreshTokenRequest request,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiServices _apiServices;

  AuthRemoteDataSourceImpl(this._apiServices);

  @override
  Future<Either<AppException, RegisterResponseModel>> register(
    RegisterRequest request,
  ) async {
    try {
      final response = await _apiServices.post(
        '/auth/register',
        data: {
          'email': request.email,
          'password': request.password,
          'firstName': request.firstName,
          'lastName': request.lastName,
        },
      );

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        return Right(RegisterResponseModel.fromJson(responseData));
      } else {
        final exception = const ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'register');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'register');
      return Left(appException);
    }
  }

  @override
  Future<Either<AppException, RegisterResponseModel>> login(
    LoginRequest request,
  ) async {
    try {
      final response = await _apiServices.post(
        '/auth/login',
        data: {
          'email': request.email,
          'password': request.password,
        },
      );

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        return Right(RegisterResponseModel.fromJson(responseData));
      } else {
        final exception = const ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'login');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'login');
      return Left(appException);
    }
  }

  @override
  Future<Either<AppException, RefreshTokenResponseModel>> refreshToken(
    RefreshTokenRequest request,
  ) async {
    try {
      final response = await _apiServices.post(
        '/auth/refresh',
        data: {
          'refreshToken': request.refreshToken,
        },
      );

      // Dio devuelve Response, necesitamos acceder a response.data
      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        return Right(RefreshTokenResponseModel.fromJson(responseData));
      } else {
        final exception = const ServerException(
          'Respuesta del servidor en formato incorrecto',
        );
        ExceptionHandler.logException(exception, context: 'refreshToken');
        return Left(exception);
      }
    } catch (e) {
      final appException = ExceptionHandler.handleException(e);
      ExceptionHandler.logException(appException, context: 'refreshToken');
      return Left(appException);
    }
  }
}
