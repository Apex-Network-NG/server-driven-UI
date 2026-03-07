import 'package:dio/dio.dart';

class SDUIAutofillApiHeader {
  final String name;
  final String? value;
  final String Function()? resolver;

  const SDUIAutofillApiHeader({required this.name, this.value, this.resolver});

  String? resolveValue() => resolver?.call() ?? value;
}

class SDUIAutofillApiConfig {
  final String? baseUrl;
  final Map<String, SDUIAutofillApiHeader> headers;
  final Map<String, String> defaultHeaders;
  final Dio? dio;

  const SDUIAutofillApiConfig({
    this.baseUrl,
    this.headers = const {},
    this.defaultHeaders = const {},
    this.dio,
  });

  Map<String, String> resolveHeaders(List<String> requested) {
    final resolved = <String, String>{};
    resolved.addAll(defaultHeaders);

    for (final key in requested) {
      final header = headers[key];
      final value = header?.resolveValue();
      if (header != null && value != null) {
        resolved[header.name] = value;
      }
    }

    return resolved;
  }
}

class SDUIAutofillApiRegistry {
  SDUIAutofillApiRegistry._();

  static SDUIAutofillApiConfig _config = const SDUIAutofillApiConfig();

  static SDUIAutofillApiConfig get config => _config;

  static void register(SDUIAutofillApiConfig config) {
    _config = config;
  }
}
