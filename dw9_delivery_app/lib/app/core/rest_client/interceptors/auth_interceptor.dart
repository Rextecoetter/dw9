import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dw9_delivery_app/app/core/global/global_context.dart';
import 'package:dw9_delivery_app/app/core/rest_client/custom_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../exceptions/expire_token_exception.dart';

class AuthInterceptor extends Interceptor {
  final CustomDio dio;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final sp = await SharedPreferences.getInstance();
    final accsessToken = sp.getString('accessToken');
    options.headers['Authorization'] = 'Bearer $accsessToken';

    handler.next(options);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        if (err.requestOptions.path != '/auth/refresh') {
          await _refreshToken(err);
          await _retryRequest(err, handler);
        } else {
          GlobalContext.i.loginExpired();
        }
      } catch (e) {
        GlobalContext.i.loginExpired();
      }
    } else {
      handler.next(err);
    }
  }

  Future<void> _refreshToken(DioError err) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final refreshToken = sp.getString('refreshtoken');
      if (refreshToken == null) {
        return;
      }

      final resultRefresh = await dio.auth().put('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      sp.setString('accessToken', resultRefresh.data['access_token']);
      sp.setString('refreshToken', resultRefresh.data['access_token']);
    } on DioError catch (e, s) {
      log('Error ao realizar refresh token', error: e, stackTrace: s);
      throw ExpireTokenException();
    }
  }

  Future<void> _retryRequest(DioError err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    final result = await dio.request(
      requestOptions.path,
      options: Options(
        headers: requestOptions.headers,
        method: requestOptions.method,
      ),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );

    handler.resolve(
      Response(
        requestOptions: requestOptions,
        data: result.data,
        statusCode: result.statusCode,
        statusMessage: result.statusMessage,
      ),
    );
  }
}
