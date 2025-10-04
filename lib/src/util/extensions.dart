import 'package:flutter/material.dart';

extension SDUIStringExtension on String {
  TextInputType get textInputType => switch (this) {
    'email' => TextInputType.emailAddress,
    'phone' => TextInputType.phone,
    'number' => TextInputType.number,
    'url' => TextInputType.url,
    _ => TextInputType.text,
  };

  bool get isValidUrl {
    if (isEmpty) return false;

    try {
      String url = this;
      if (startsWith('www.')) {
        url = url.replaceFirst('www.', 'https://');
      } else if (!startsWith('http://') && !startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      if (uri.host.isEmpty) {
        return false;
      }

      // Validate host format using regex
      final hostPattern = RegExp(
        r'^'
        r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*'
        r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
        r'(?:\.[a-zA-Z]{2,})+$',
      );

      if (!hostPattern.hasMatch(uri.host)) {
        return false;
      }

      // Host should not start or end with hyphen
      if (uri.host.startsWith('-') || uri.host.endsWith('-')) {
        return false;
      }

      if (uri.host != 'localhost' && !uri.host.contains('.')) {
        return false;
      }

      final parts = uri.host.split('.');
      if (parts.length < 2) {
        return false;
      }

      final tld = parts.last;
      if (tld.length < 2) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  String get formatUrl {
    if (isEmpty) return this;
    if (startsWith('www.')) {
      return 'https://$this';
    }
    if (!startsWith('http://') && !startsWith('https://')) {
      return 'https://$this';
    }
    return this;
  }
}
