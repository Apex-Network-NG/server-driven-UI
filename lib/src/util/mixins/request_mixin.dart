import 'package:dio/dio.dart';
import 'package:sdui/src/core/service/service_locator.dart';

mixin ApiRequestMixin on ServiceLocator {
  final Map<String, CancelToken> _cancelTokens = {};

  Future<ApiResponse> executeRequest<T>({
    required String requestKey,
    required Future<T> Function(CancelToken cancelToken) call,
    bool shouldCancel = true,
  }) async {
    CancelToken cancelToken;

    if (shouldCancel) {
      _cancelTokens[requestKey]?.cancel();
      cancelToken = CancelToken();
      _cancelTokens[requestKey] = cancelToken;
    } else {
      cancelToken = _cancelTokens[requestKey] ?? CancelToken();
      _cancelTokens[requestKey] = cancelToken;
    }

    try {
      final result = await call(cancelToken);
      if (result == null) return ApiResponse.error(message: "Result is null");
      return ApiResponse(data: result, isSuccess: true);
    } on DioException catch (e) {
      return _handleDioException(e);
    } on FormatException catch (_) {
      return ApiResponse.error(message: "Format error");
    } catch (e) {
      return ApiResponse.error(message: "Unknown error");
    }
  }

  ApiResponse _handleDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.badResponse:
        return ApiResponse.error(message: exception.response?.data["message"]);
      case DioExceptionType.connectionError:
        return ApiResponse.socketError();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(message: "Timeout");
      case DioExceptionType.cancel:
        return ApiResponse.cancel();
      case DioExceptionType.unknown:
      case DioExceptionType.badCertificate:
        try {
          return ApiResponse.error(
            message: exception.response?.data["message"],
          );
        } catch (err) {
          return ApiResponse.error(message: "Unknown error");
        }
    }
  }

  void cancelRequest(String requestKey) => _cancelTokens[requestKey]?.cancel();
  void cancelAllRequests() {
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    _cancelTokens.clear();
  }
}

class ApiResponse<T> {
  final String? message;
  final bool? isSuccess;
  final bool? isCancel;
  final bool? isSocketError;
  final T? data;
  final T? meta;
  final DioExceptionType? type;

  ApiResponse({
    this.message,
    this.isSuccess,
    this.isSocketError,
    this.data,
    this.isCancel,
    this.meta,
    this.type,
  });

  @override
  String toString() {
    return '''ApiResponse<$T>{
      message: $message,
      data: $data,
      isSocketError: $isSocketError,
      isSuccess: $isSuccess,
      meta: $meta,
      type: $type,
    }''';
  }

  factory ApiResponse.error({
    String? message,
    dynamic errors,
    DioExceptionType? type,
  }) {
    return ApiResponse<T>(
      message: message,
      isSuccess: false,
      data: errors,
      type: type,
    );
  }

  factory ApiResponse.cancel() {
    return ApiResponse<T>(isCancel: true, isSuccess: false);
  }

  factory ApiResponse.socketError() {
    return ApiResponse<T>(isSocketError: true, isSuccess: false);
  }
}
