import 'package:dio/dio.dart';

class FormService {
  FormService(this.dio);
  final Dio dio;

  Future<dynamic> getForm({required String formId}) async {
    final extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final headers = <String, dynamic>{};
    const Map<String, dynamic>? data = null;
    final options = _setStreamType<dynamic>(
      Options(method: 'GET', headers: headers, extra: extra)
          .compose(
            dio.options,
            '/forms/$formId',
            queryParameters: queryParameters,
            data: data,
          )
          .copyWith(baseUrl: dio.options.baseUrl),
    );
    final result = await dio.fetch<Map<String, dynamic>>(options);
    return result.data;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
