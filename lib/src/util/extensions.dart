import 'package:flutter/material.dart';

extension SDUIStringExtension on String {
  TextInputType get textInputType => switch (this) {
    'email' => TextInputType.emailAddress,
    'phone' => TextInputType.phone,
    'number' => TextInputType.number,
    'url' => TextInputType.url,
    _ => TextInputType.text,
  };

  TextInputType? get uiTextInputType {
    final normalized = trim().toLowerCase();
    switch (normalized) {
      case 'default':
        return null;
      case 'text':
        return TextInputType.text;
      case 'search':
        return TextInputType.text;
      case 'email':
        return TextInputType.emailAddress;
      case 'telephone':
      case 'tel':
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'numeric':
      case 'number':
        return TextInputType.number;
      case 'decimal':
        return const TextInputType.numberWithOptions(decimal: true);
      default:
        return null;
    }
  }

  List<String>? get uiAutofillHints {
    final parts = split(
      RegExp(r'[,\s]+'),
    ).map((value) => value.trim()).where((value) => value.isNotEmpty).toList();
    if (parts.isEmpty) return null;

    final hints = <String>[];
    for (final part in parts) {
      final normalized = part.toLowerCase();
      switch (normalized) {
        case 'email':
          hints.add(AutofillHints.email);
          break;
        case 'telephone':
        case 'tel':
        case 'phone':
          hints.add(AutofillHints.telephoneNumber);
          break;
        case 'name':
          hints.add(AutofillHints.name);
          break;
        case 'first_name':
        case 'first-name':
        case 'given_name':
        case 'given-name':
          hints.add(AutofillHints.givenName);
          break;
        case 'last_name':
        case 'last-name':
        case 'family_name':
        case 'family-name':
          hints.add(AutofillHints.familyName);
          break;
        case 'username':
          hints.add(AutofillHints.username);
          break;
        case 'password':
          hints.add(AutofillHints.password);
          break;
        case 'new_password':
        case 'new-password':
          hints.add(AutofillHints.newPassword);
          break;
        case 'one_time_code':
        case 'one-time-code':
        case 'otp':
          hints.add(AutofillHints.oneTimeCode);
          break;
        case 'address':
          hints.add(AutofillHints.fullStreetAddress);
          break;
        case 'street_address':
        case 'street-address':
          hints.add(AutofillHints.fullStreetAddress);
          break;
        case 'postal_code':
        case 'postal-code':
        case 'zip':
          hints.add(AutofillHints.postalCode);
          break;
        case 'country':
          hints.add(AutofillHints.countryName);
          break;
        case 'organization':
        case 'company':
          hints.add(AutofillHints.organizationName);
          break;
        case 'credit_card':
        case 'credit-card':
        case 'card':
          hints.add(AutofillHints.creditCardNumber);
          break;
        default:
          hints.add(part);
      }
    }

    return hints.isEmpty ? null : hints;
  }

  IconData? get sduiIconData {
    final normalized = trim().toLowerCase();
    switch (normalized) {
      case 'phone':
      case 'tel':
      case 'telephone':
        return Icons.phone;
      case 'mail':
      case 'email':
        return Icons.email;
      case 'user':
      case 'person':
      case 'account':
        return Icons.person;
      case 'search':
        return Icons.search;
      case 'lock':
      case 'password':
        return Icons.lock;
      case 'calendar':
      case 'date':
        return Icons.calendar_today;
      case 'url':
      case 'link':
      case 'website':
        return Icons.link;
      case 'bank':
        return Icons.account_balance;
      case 'money':
      case 'currency':
        return Icons.attach_money;
      case 'location':
      case 'address':
        return Icons.location_on;
      case 'company':
      case 'business':
        return Icons.business;
      case 'card':
      case 'credit':
        return Icons.credit_card;
      case 'number':
      case 'numeric':
        return Icons.format_list_numbered;
      default:
        return Icons.settings;
    }
  }

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
