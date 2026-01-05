import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

HttpClient createMyHttpClient() =>
    HttpClient()..idleTimeout = const Duration(seconds: 15);

class DioService {
  DioService._();

  static DioService? _instance;
  static Dio? _dio;

  factory DioService() {
    if (_instance == null) {
      final options = BaseOptions(
        baseUrl: 'https://fb.apexex.co/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      );
      _dio = Dio(options)
        ..interceptors.add(
          TalkerDioLogger(
            settings: const TalkerDioLoggerSettings(
              printResponseData: true,
              printRequestData: true,
              printResponseMessage: true,
              printRequestHeaders: true,
              printResponseHeaders: true,
              printErrorHeaders: true,
              printErrorData: true,
              printErrorMessage: true,
            ),
          ),
        )
        ..httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: createMyHttpClient,
        );
      _instance = DioService._();
    }
    return _instance!;
  }

  Dio get dio => _dio!;
}
