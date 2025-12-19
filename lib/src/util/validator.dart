import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sdui/sdui.dart';

/// Central validation helper for SDUI forms.
///
/// Mirrors the backend (PHP) validator semantics:
/// - Non-`required*` rules pass when the current field value is empty.
/// - Supports `{field:other_key}` field references in rule parameters for
///   `before`, `after`, `gt`, `gte`, `lt`, and `lte`.
class FieldValidator {
  FieldValidator._();
  static final FieldValidator instance = FieldValidator._();

  /// Validate a single rule against the provided values.
  ///
  /// - `rawValue` lets callers pass non-string values (e.g. `num`, `List`, `Map`)
  ///   to match backend behavior for rules like `min` / `max` (count/size).
  /// - `fieldType` and `allRules` help size-based rules decide whether to treat
  ///   numeric strings as numbers (like the backend does when `numeric` is present).
  ///
  /// Returns a `String` error message if validation fails, or `null` if it succeeds.
  String? validateRequired({
    required SDUIValidation validation,
    required FormManager formManager,
    String? textValue,
    String? selectedCountryCode,
    bool? booleanValue,
    DateTime? dateValue,
    TimeOfDay? timeValue,
    Object? rawValue,
    String? fieldType,
    List<String>? allRules,
  }) {
    final rule = validation.rule.toLowerCase();
    final params = List<dynamic>.from(validation.params);

    final requiredValue =
        rawValue ?? booleanValue ?? dateValue ?? timeValue ?? textValue;

    final currentValue =
        rawValue ??
        switch (rule) {
          'boolean' => booleanValue ?? textValue,
          'date' || 'datetime' => dateValue ?? textValue,
          'time' => timeValue ?? textValue,
          'before' || 'after' => dateValue ?? timeValue ?? textValue,
          _ => textValue,
        };

    switch (rule) {
      case 'required':
        if (_isEmpty(requiredValue)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'email':
        if (_isEmpty(textValue)) return null;
        if (!validateEmail(textValue)) {
          return validation.message ?? 'Please enter a valid email address';
        }
        return null;

      case 'phone':
        if (_isEmpty(textValue)) return null;
        if (!validatePhone(textValue, selectedCountryCode)) {
          return validation.message ?? 'Please enter a valid phone number';
        }
        return null;

      case 'boolean':
        if (_isEmpty(currentValue)) return null;
        if (!validateBoolean(currentValue)) {
          return validation.message ?? 'Please enter a valid boolean value';
        }
        return null;

      case 'date':
        if (_isEmpty(currentValue)) return null;
        if (!validateDate(currentValue)) {
          return validation.message ?? 'Please enter a valid date';
        }
        return null;

      case 'time':
        if (_isEmpty(currentValue)) return null;
        if (!validateTime(currentValue)) {
          return validation.message ?? 'Please enter a valid time';
        }
        return null;

      case 'datetime':
        if (_isEmpty(currentValue)) return null;
        if (!validateDateTime(currentValue)) {
          return validation.message ?? 'Please enter a valid date and time';
        }
        return null;

      case 'numeric':
        if (_isEmpty(currentValue)) return null;
        if (!validateNumeric(currentValue)) {
          return validation.message ?? 'Value must be numeric';
        }
        return null;

      case 'string':
        if (_isEmpty(currentValue)) return null;
        if (!validateString(currentValue)) {
          return validation.message ?? 'Value must be a string';
        }
        return null;

      case 'min':
        if (_isEmpty(currentValue)) return null;
        if (!validateMin(
          params,
          currentValue,
          fieldType: fieldType,
          allRules: allRules,
        )) {
          final min = _toBytesSize(params.isNotEmpty ? params[0] : null);
          if (validation.message != null) return validation.message;
          return _minMessage(min, fieldType: fieldType);
        }
        return null;

      case 'max':
        if (_isEmpty(currentValue)) return null;
        if (!validateMax(
          params,
          currentValue,
          fieldType: fieldType,
          allRules: allRules,
        )) {
          final max = _toBytesSize(params.isNotEmpty ? params[0] : null);
          if (validation.message != null) return validation.message;
          return _maxMessage(max, fieldType: fieldType);
        }
        return null;

      case 'between':
        if (_isEmpty(currentValue)) return null;
        if (!validateBetween(
          params,
          currentValue,
          fieldType: fieldType,
          allRules: allRules,
        )) {
          if (params.length >= 2) {
            final min = _toBytesSize(params[0]);
            final max = _toBytesSize(params[1]);
            if (min != null && max != null) {
              return validation.message ??
                  'Value must be between $min and $max';
            }
          }
          return validation.message ?? 'Value is out of range';
        }
        return null;

      case 'not_between':
        if (_isEmpty(currentValue)) return null;
        if (!validateNotBetween(
          params,
          currentValue,
          fieldType: fieldType,
          allRules: allRules,
        )) {
          if (params.length >= 2) {
            final min = _toBytesSize(params[0]);
            final max = _toBytesSize(params[1]);
            if (min != null && max != null) {
              return validation.message ??
                  'Value must not be between $min and $max';
            }
          }
          return validation.message ?? 'Value is in the disallowed range';
        }
        return null;

      case 'gt':
      case 'gte':
      case 'lt':
      case 'lte':
        if (_isEmpty(currentValue)) return null;
        if (!validateNumericComparison(
          rule,
          params,
          currentValue,
          formManager,
        )) {
          return validation.message ?? 'Invalid number comparison';
        }
        return null;

      case 'regex':
        if (_isEmpty(currentValue)) return null;
        if (!validateRegex(params, currentValue)) {
          return validation.message ?? 'Invalid format';
        }
        return null;

      case 'in':
        if (_isEmpty(currentValue)) return null;
        if (!validateIn(params, currentValue)) {
          return validation.message ?? 'Invalid value';
        }
        return null;

      case 'not_in':
        if (_isEmpty(currentValue)) return null;
        if (!validateNotIn(params, currentValue)) {
          return validation.message ?? 'Invalid value';
        }
        return null;

      case 'starts_with':
        if (_isEmpty(currentValue)) return null;
        if (!validateStartsWith(params, currentValue)) {
          if (params.isNotEmpty) {
            return validation.message ??
                'Value must start with ${params[0].toString()}';
          }
          return validation.message ?? 'Value must start with a valid prefix';
        }
        return null;

      case 'ends_with':
        if (_isEmpty(currentValue)) return null;
        if (!validateEndsWith(params, currentValue)) {
          if (params.isNotEmpty) {
            return validation.message ??
                'Value must end with ${params[0].toString()}';
          }
          return validation.message ?? 'Value must end with a valid suffix';
        }
        return null;

      case 'before':
        if (_isEmpty(currentValue)) return null;
        if (!validateBefore(params, currentValue, formManager)) {
          final param = params.isNotEmpty ? params[0].toString() : '';
          return validation.message ??
              (param.isNotEmpty
                  ? 'Value must be before $param'
                  : 'Invalid date');
        }
        return null;

      case 'after':
        if (_isEmpty(currentValue)) return null;
        if (!validateAfter(params, currentValue, formManager)) {
          final param = params.isNotEmpty ? params[0].toString() : '';
          return validation.message ??
              (param.isNotEmpty
                  ? 'Value must be after $param'
                  : 'Invalid date');
        }
        return null;

      case 'required_if':
        if (!requiredIf(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_unless':
        if (!requiredUnless(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_with':
        if (!requiredWith(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_with_all':
        if (!requiredWithAll(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_without':
        if (!requiredWithout(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_without_all':
        if (!requiredWithoutAll(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_if_accepted':
        if (!requiredIfAccepted(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      case 'required_if_declined':
        if (!requiredIfDeclined(params, requiredValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;

      default:
        return null;
    }
  }

  /// Validates a field's `constraints` similarly to the PHP SubmissionValidator.
  ///
  /// Returns an error message when failing, or `null` when passing.
  String? validateConstraints({
    required String fieldType,
    Map<String, dynamic>? constraints,
    Map<String, dynamic>? optionProperties,
    Object? rawValue,
    String? textValue,
    bool? booleanValue,
    DateTime? dateValue,
    TimeOfDay? timeValue,
  }) {
    constraints ??= const <String, dynamic>{};

    final value =
        rawValue ?? booleanValue ?? dateValue ?? timeValue ?? textValue;
    if (_isEmpty(value)) return null;

    switch (fieldType) {
      case 'short-text':
      case 'text':
      case 'medium-text':
      case 'long-text':
      case 'address':
      case 'url':
        final minLen = _toInt(constraints['min_length']);
        final maxLen = _toInt(constraints['max_length']);
        final str = value.toString();

        if (minLen != null && str.length < minLen) {
          return 'Must be at least $minLen characters';
        }
        if (maxLen != null && str.length > maxLen) {
          return 'Must be at most $maxLen characters';
        }
        return null;

      case 'email':
        final str = value.toString();
        if (!validateEmail(str)) {
          return 'Please enter a valid email address';
        }

        final maxLen = _toInt(constraints['max_length']);
        if (maxLen != null && str.length > maxLen) {
          return 'Must be at most $maxLen characters';
        }

        final allowed = _stringList(constraints['allowed_domains']);
        final disallowed = _stringList(constraints['disallowed_domains']);
        if (allowed.isNotEmpty || disallowed.isNotEmpty) {
          if (!_validateEmailDomains(str, allowed, disallowed)) {
            return 'Email domain is not allowed';
          }
        }

        return null;

      case 'country':
        final str = value.toString();
        final allow = _stringList(constraints['allow_countries']);
        final exclude = _stringList(constraints['exclude_countries']);

        if (allow.isNotEmpty && !allow.contains(str)) {
          return 'Country is not allowed';
        }
        if (exclude.isNotEmpty && exclude.contains(str)) {
          return 'Country is not allowed';
        }
        return null;

      case 'number':
      case 'rating':
        final numValue = _toNumber(value);
        if (numValue == null) return 'Value must be numeric';

        final min = _toNumber(constraints['min']);
        final max = _toNumber(constraints['max']);

        if (min != null && numValue < min) return 'Minimum value is $min';
        if (max != null && numValue > max) return 'Maximum value is $max';

        if (fieldType == 'number') {
          final step = _toNumber(constraints['step']);
          if (step != null) {
            final base = _toNumber(constraints['min']) ?? 0;
            if (!_validateStep(numValue, step, base)) {
              return 'Value must be in increments of $step';
            }
          }
        }

        return null;

      case 'tag':
        final items = _normalizeListValue(value);
        final min = _toInt(constraints['min']);
        final max = _toInt(constraints['max']);

        if (min != null && items.length < min) {
          return 'Must include at least $min item(s)';
        }
        if (max != null && items.length > max) {
          return 'Must include at most $max item(s)';
        }
        return null;

      case 'file':
      case 'image':
      case 'video':
      case 'document':
        final accept = _stringList(
          constraints['accept'],
        ).map((e) => e.toLowerCase()).toList();
        final allowMultiple = constraints['allow_multiple'] == true;
        final minFiles = _toInt(constraints['min']);
        final maxFiles = _toInt(constraints['max']);
        final maxFileSize = _toInt(constraints['max_file_size']);
        final maxTotalSize = _toInt(constraints['max_total_size']);

        final files = _normalizeFiles(value);
        if (files == null) return 'Invalid file upload';

        if (!allowMultiple && files.length > 1) {
          return 'Multiple files are not allowed';
        }

        if (minFiles != null && files.length < minFiles) {
          return 'Must include at least $minFiles file(s)';
        }
        if (maxFiles != null && files.length > maxFiles) {
          return 'Must include at most $maxFiles file(s)';
        }

        int total = 0;
        for (final file in files) {
          final size = _fileSize(file);
          if (size == null) return 'Invalid file upload';
          if (maxFileSize != null && size > maxFileSize) {
            return 'A file exceeds the maximum size';
          }
          total += size;

          if (accept.isNotEmpty) {
            final mime = _fileMime(file);
            if (mime == null) return 'Invalid file upload';
            if (!accept.contains(mime.toLowerCase())) {
              return 'Invalid file type';
            }
          }
        }

        if (maxTotalSize != null && total > maxTotalSize) {
          return 'Total upload size exceeds the maximum';
        }

        return null;

      case 'options':
        if (optionProperties == null) return null;

        final optionType =
            (optionProperties['type'] as String?)?.trim() ?? 'select';

        final allowedKeys = <String>{};
        final data = optionProperties['data'];
        if (data is List) {
          for (final item in data) {
            if (item is Map && item['key'] is String) {
              final k = (item['key'] as String).trim();
              if (k.isNotEmpty) allowedKeys.add(k);
            }
          }
        }

        if (allowedKeys.isEmpty) return null;

        if (optionType == 'select' || optionType == 'radio') {
          final key = value.toString();
          return allowedKeys.contains(key) ? null : 'Invalid option selected';
        }

        if (optionType == 'multi-select' || optionType == 'checkbox') {
          final selected = _normalizeListValue(
            value,
          ).map((e) => e.toString()).toList();

          final maxSelect = _toInt(optionProperties['max_select']);
          if (maxSelect != null && selected.length > maxSelect) {
            return 'You can select at most $maxSelect option(s)';
          }

          for (final k in selected) {
            if (!allowedKeys.contains(k)) return 'Invalid option selected';
          }
          return null;
        }

        return null;

      default:
        return null;
    }
  }

  bool validateEmail(String? textValue) {
    if (_isEmpty(textValue)) return true;
    return EmailValidator.validate(textValue!.trim());
  }

  bool validatePhone(String? textValue, String? selectedCountryCode) {
    if (_isEmpty(textValue)) return true;
    if (selectedCountryCode == null || selectedCountryCode.trim().isEmpty) {
      return false;
    }

    try {
      final isoCode = IsoCode.fromJson(selectedCountryCode);
      final phoneNumber = PhoneNumber.parse(
        textValue!,
        destinationCountry: isoCode,
      );
      return phoneNumber.isValid();
    } catch (_) {
      return false;
    }
  }

  bool validateBoolean(Object? value) {
    if (_isEmpty(value)) return true;
    if (value is bool) return true;
    if (value is int) return value == 0 || value == 1;
    if (value is num) return value == 0 || value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return const {
        'true',
        'false',
        '0',
        '1',
        'y',
        'n',
        'yes',
        'no',
        'on',
        'off',
      }.contains(normalized);
    }
    return false;
  }

  bool validateDate(Object? value) {
    if (_isEmpty(value)) return true;
    if (value is DateTime) return true;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return true;
      final isDateOnly = RegExp(r'^\\d{4}-\\d{2}-\\d{2}$').hasMatch(trimmed);
      if (!isDateOnly) return false;
      return DateTime.tryParse(trimmed) != null;
    }
    return false;
  }

  bool validateTime(Object? value) {
    if (_isEmpty(value)) return true;
    if (value is TimeOfDay) return true;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return true;
      return RegExp(
            r'^([01]\\d|2[0-3]):[0-5]\\d(:[0-5]\\d)?$',
          ).hasMatch(trimmed) &&
          _toDateTime(trimmed) != null;
    }
    return false;
  }

  bool validateDateTime(Object? value) {
    if (_isEmpty(value)) return true;
    if (value is DateTime) return true;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return true;
      if (!trimmed.contains(':')) return false;
      return _toDateTime(trimmed) != null;
    }
    return false;
  }

  bool validateNumeric(Object? value) {
    if (_isEmpty(value)) return true;
    return _toNumber(value) != null;
  }

  bool validateString(Object? value) {
    if (_isEmpty(value)) return true;
    return value is String;
  }

  bool validateMin(
    List<dynamic> params,
    Object? value, {
    String? fieldType,
    List<String>? allRules,
  }) {
    if (_isEmpty(value)) return true;
    if (params.isEmpty) return false;

    final min = _toBytesSize(params[0]);
    final size = _valueSize(value, fieldType: fieldType, allRules: allRules);
    if (min == null || size == null) return false;

    return size >= min;
  }

  bool validateMax(
    List<dynamic> params,
    Object? value, {
    String? fieldType,
    List<String>? allRules,
  }) {
    if (_isEmpty(value)) return true;
    if (params.isEmpty) return false;

    final max = _toBytesSize(params[0]);
    final size = _valueSize(value, fieldType: fieldType, allRules: allRules);
    if (max == null || size == null) return false;

    return size <= max;
  }

  bool validateBetween(
    List<dynamic> params,
    Object? value, {
    String? fieldType,
    List<String>? allRules,
  }) {
    if (_isEmpty(value)) return true;
    if (params.length < 2) return false;

    final min = _toBytesSize(params[0]);
    final max = _toBytesSize(params[1]);
    final size = _valueSize(value, fieldType: fieldType, allRules: allRules);
    if (min == null || max == null || size == null) return false;

    return size >= min && size <= max;
  }

  bool validateNotBetween(
    List<dynamic> params,
    Object? value, {
    String? fieldType,
    List<String>? allRules,
  }) {
    if (_isEmpty(value)) return true;
    if (params.length < 2) return false;

    final min = _toBytesSize(params[0]);
    final max = _toBytesSize(params[1]);
    final size = _valueSize(value, fieldType: fieldType, allRules: allRules);
    if (min == null || max == null || size == null) return false;

    return size < min || size > max;
  }

  bool validateRegex(List<dynamic> params, Object? value) {
    if (_isEmpty(value)) return true;
    if (params.isEmpty) return false;

    final pattern = params[0]?.toString().trim();
    if (pattern == null || pattern.isEmpty) return true;

    final regex = _compileRegex(pattern);
    return regex.hasMatch(value.toString());
  }

  bool validateIn(List<dynamic> params, Object? value) {
    if (_isEmpty(value) || params.isEmpty) return true;

    if (value is Iterable) {
      return value.every((v) => params.any((p) => p == v));
    }

    return params.any((p) => p == value);
  }

  bool validateNotIn(List<dynamic> params, Object? value) {
    if (_isEmpty(value) || params.isEmpty) return true;

    if (value is Iterable) {
      return value.every((v) => params.every((p) => p != v));
    }

    return params.every((p) => p != value);
  }

  bool validateStartsWith(List<dynamic> params, Object? value) {
    if (_isEmpty(value) || params.isEmpty) return true;
    final str = value.toString();
    return params.map((e) => e.toString()).any(str.startsWith);
  }

  bool validateEndsWith(List<dynamic> params, Object? value) {
    if (_isEmpty(value) || params.isEmpty) return true;
    final str = value.toString();
    return params.map((e) => e.toString()).any(str.endsWith);
  }

  bool validateBefore(
    List<dynamic> params,
    Object? value,
    FormManager formManager,
  ) {
    if (_isEmpty(value) || params.isEmpty) return true;

    final lhs = _toDateTime(value);
    final target = _resolveTargetParam(params[0], formManager);
    final rhs = _toDateTime(target);

    if (lhs == null || rhs == null) return false;
    return lhs.isBefore(rhs);
  }

  bool validateAfter(
    List<dynamic> params,
    Object? value,
    FormManager formManager,
  ) {
    if (_isEmpty(value) || params.isEmpty) return true;

    final lhs = _toDateTime(value);
    final target = _resolveTargetParam(params[0], formManager);
    final rhs = _toDateTime(target);

    if (lhs == null || rhs == null) return false;
    return lhs.isAfter(rhs);
  }

  bool validateNumericComparison(
    String rule,
    List<dynamic> params,
    Object? value,
    FormManager formManager,
  ) {
    if (_isEmpty(value) || params.isEmpty) return true;

    final lhs = _toNumber(value);
    if (lhs == null) return false;

    final target = _resolveTargetParam(params[0], formManager);
    final rhs = _toNumber(target);
    if (rhs == null) return false;

    return switch (rule) {
      'gt' => lhs > rhs,
      'gte' => lhs >= rhs,
      'lt' => lhs < rhs,
      'lte' => lhs <= rhs,
      _ => false,
    };
  }

  bool requiredIf(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final fieldKey = _normalizeFieldKey(params.isNotEmpty ? params[0] : null);
    final defined = params.length > 1 ? params.sublist(1) : <dynamic>[];
    if (fieldKey == null || defined.isEmpty) return true;

    final otherValue = formManager.getFieldValue(fieldKey);
    final match = _matchesAny(otherValue, defined);
    if (!match) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredUnless(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final fieldKey = _normalizeFieldKey(params.isNotEmpty ? params[0] : null);
    final defined = params.length > 1 ? params.sublist(1) : <dynamic>[];
    if (fieldKey == null || defined.isEmpty) return true;

    final otherValue = formManager.getFieldValue(fieldKey);
    final match = _matchesAny(otherValue, defined);
    if (match) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredWith(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final keys = _normalizeFieldKeys(params);
    if (keys.isEmpty) return true;

    final anyPresent = keys.any((k) => !_isEmpty(formManager.getFieldValue(k)));
    if (!anyPresent) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredWithAll(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final keys = _normalizeFieldKeys(params);
    if (keys.isEmpty) return true;

    final allPresent = keys.every(
      (k) => !_isEmpty(formManager.getFieldValue(k)),
    );
    if (!allPresent) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredWithout(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final keys = _normalizeFieldKeys(params);
    if (keys.isEmpty) return true;

    final anyMissing = keys.any((k) => _isEmpty(formManager.getFieldValue(k)));
    if (!anyMissing) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredWithoutAll(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final keys = _normalizeFieldKeys(params);
    if (keys.isEmpty) return true;

    final allMissing = keys.every(
      (k) => _isEmpty(formManager.getFieldValue(k)),
    );
    if (!allMissing) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredIfAccepted(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final fieldKey = _normalizeFieldKey(params.isNotEmpty ? params[0] : null);
    if (fieldKey == null) return true;

    final otherValue = formManager.getFieldValue(fieldKey);
    if (!_isAccepted(otherValue)) return true;

    return !_isEmpty(currentValue);
  }

  bool requiredIfDeclined(
    List<dynamic> params,
    Object? currentValue,
    FormManager formManager,
  ) {
    final fieldKey = _normalizeFieldKey(params.isNotEmpty ? params[0] : null);
    if (fieldKey == null) return true;

    final otherValue = formManager.getFieldValue(fieldKey);
    if (!_isDeclined(otherValue)) return true;

    return !_isEmpty(currentValue);
  }

  static bool _isEmpty(Object? value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  static String? _fieldRefKey(String value) {
    final match = RegExp(r'^\\{field:(.*?)\\}$').firstMatch(value.trim());
    final key = match?.group(1);
    if (key == null) return null;
    final trimmed = key.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _normalizeFieldKey(Object? param) {
    if (param is! String) return null;
    final trimmed = param.trim();
    if (trimmed.isEmpty) return null;

    return _fieldRefKey(trimmed) ?? trimmed;
  }

  static List<String> _normalizeFieldKeys(List<dynamic> params) {
    final keys = <String>[];
    for (final p in params) {
      final key = _normalizeFieldKey(p);
      if (key != null) keys.add(key);
    }
    return keys.toSet().toList();
  }

  static Object? _resolveTargetParam(Object? param, FormManager formManager) {
    if (param is String) {
      final key = _fieldRefKey(param);
      if (key != null) {
        return formManager.getFieldValue(key);
      }
    }
    return param;
  }

  static double? _toNumber(Object? value) {
    if (_isEmpty(value)) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return null;
  }

  static int? _toInt(Object? value) {
    if (value is int) return value;
    final n = _toNumber(value);
    return n == null ? null : n.toInt();
  }

  static double? _toBytesSize(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      final match = RegExp(
        r'^(?<number>((\\d+)?\\.)?\\d+)(?<format>(B|K|M|G|T|P)B?)?\$',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (match == null) {
        return double.tryParse(trimmed);
      }

      final number = double.tryParse(match.namedGroup('number') ?? '');
      if (number == null) return null;

      final format = (match.namedGroup('format') ?? '').toUpperCase();
      switch (format) {
        case 'KB':
        case 'K':
          return number * 1024;
        case 'MB':
        case 'M':
          return number * 1024 * 1024;
        case 'GB':
        case 'G':
          return number * 1024 * 1024 * 1024;
        case 'TB':
        case 'T':
          return number * 1024 * 1024 * 1024 * 1024;
        case 'PB':
        case 'P':
          return number * 1024 * 1024 * 1024 * 1024 * 1024;
        default:
          return number;
      }
    }
    return _toNumber(value);
  }

  static double? _valueSize(
    Object? value, {
    String? fieldType,
    List<String>? allRules,
  }) {
    if (_isEmpty(value)) return null;

    final lowerRules = (allRules ?? const <String>[])
        .map((e) => e.toLowerCase())
        .toSet();

    final treatAsNumeric =
        lowerRules.contains('numeric') ||
        value is num ||
        fieldType == 'number' ||
        fieldType == 'rating';

    if (treatAsNumeric) {
      final n = _toNumber(value);
      if (n != null) return n;
    }

    if (value is String) return value.length.toDouble();
    if (value is Iterable) return value.length.toDouble();

    if (value is Map) {
      final size = value['size'];
      if (size is num) return size.toDouble();
      if (size is String) return _toNumber(size);
      if (value.isNotEmpty) return value.length.toDouble();
    }

    return null;
  }

  static String _formatLimit(double? value) {
    if (value == null) return '';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  static String _normalizeFieldType(String? fieldType) =>
      fieldType?.trim().toLowerCase() ?? '';

  String _minMessage(double? min, {required String? fieldType}) {
    final limit = _formatLimit(min);
    final normalizedType = _normalizeFieldType(fieldType);

    switch (normalizedType) {
      case 'number':
      case 'rating':
        return limit.isEmpty
            ? 'Value is below the minimum'
            : 'Minimum value is $limit';
      case 'file':
      case 'image':
      case 'video':
      case 'document':
        return limit.isEmpty
            ? 'Value is below the minimum'
            : 'Minimum file size/count is $limit';
      case 'options':
      case 'tag':
        if (limit.isEmpty) return 'Please select more options';
        final label = limit == '1' ? 'option' : 'options';
        return 'Select at least $limit $label';
      default:
        return limit.isEmpty
            ? 'Value is below the minimum'
            : 'Minimum length is $limit';
    }
  }

  String _maxMessage(double? max, {required String? fieldType}) {
    final limit = _formatLimit(max);
    final normalizedType = _normalizeFieldType(fieldType);

    switch (normalizedType) {
      case 'number':
      case 'rating':
        return limit.isEmpty
            ? 'Value exceeds the maximum'
            : 'Maximum value is $limit';
      case 'file':
      case 'image':
      case 'video':
      case 'document':
        return limit.isEmpty
            ? 'Value exceeds the maximum'
            : 'Maximum file size/count is $limit';
      case 'options':
      case 'tag':
        if (limit.isEmpty) return 'Please select fewer options';
        final label = limit == '1' ? 'option' : 'options';
        return 'Select at most $limit $label';
      default:
        return limit.isEmpty
            ? 'Value exceeds the maximum'
            : 'Maximum length is $limit';
    }
  }

  static RegExp _compileRegex(String pattern) {
    final trimmed = pattern.trim();
    if (trimmed.isEmpty) return RegExp('');

    // Support PHP-style delimiters, e.g. `/^foo$/i`
    if (trimmed.length >= 2) {
      final delimiter = trimmed[0];
      final last = trimmed.lastIndexOf(delimiter);
      if (last > 0) {
        final body = trimmed.substring(1, last);
        final flags = trimmed.substring(last + 1);

        final caseInsensitive = flags.contains('i');
        final multiLine = flags.contains('m');
        final dotAll = flags.contains('s');

        return RegExp(
          body,
          caseSensitive: !caseInsensitive,
          multiLine: multiLine,
          dotAll: dotAll,
        );
      }
    }

    return RegExp(trimmed);
  }

  static DateTime? _toDateTime(Object? value) {
    if (_isEmpty(value)) return null;

    if (value is DateTime) return value;

    if (value is TimeOfDay) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, value.hour, value.minute);
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      final dateOnly = RegExp(
        r'^(\\d{4})-(\\d{2})-(\\d{2})\$',
      ).firstMatch(trimmed);
      if (dateOnly != null) {
        final y = int.parse(dateOnly.group(1)!);
        final m = int.parse(dateOnly.group(2)!);
        final d = int.parse(dateOnly.group(3)!);
        return DateTime(y, m, d);
      }

      final timeOnly = RegExp(
        r'^([01]\\d|2[0-3]):([0-5]\\d)(:([0-5]\\d))?\$',
      ).firstMatch(trimmed);
      if (timeOnly != null) {
        final now = DateTime.now();
        final hh = int.parse(timeOnly.group(1)!);
        final mm = int.parse(timeOnly.group(2)!);
        final ss = timeOnly.group(4) != null
            ? int.parse(timeOnly.group(4)!)
            : 0;
        return DateTime(now.year, now.month, now.day, hh, mm, ss);
      }

      final normalized = trimmed.contains(' ') && !trimmed.contains('T')
          ? trimmed.replaceFirst(' ', 'T')
          : trimmed;

      return DateTime.tryParse(normalized);
    }

    return null;
  }

  static bool _validateStep(double value, double step, double base) {
    if (step <= 0) return false;
    final quotient = (value - base) / step;
    final rounded = quotient.roundToDouble();
    return (quotient - rounded).abs() < 1e-9;
  }

  static bool _isAccepted(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return const {'1', 'true', 'on', 'yes', 'y'}.contains(normalized);
    }
    return false;
  }

  static bool _isDeclined(Object? value) {
    if (value is bool) return !value;
    if (value is num) return value == 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return const {'0', 'false', 'off', 'no', 'n'}.contains(normalized);
    }
    return false;
  }

  static bool _matchesAny(Object? actual, List<dynamic> targets) {
    if (actual is Iterable) {
      for (final v in actual) {
        if (targets.any((t) => _looselyEquals(v, t))) return true;
      }
      return false;
    }

    return targets.any((t) => _looselyEquals(actual, t));
  }

  static bool _looselyEquals(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;

    final an = _toNumber(a);
    final bn = _toNumber(b);
    if (an != null && bn != null) return an == bn;

    final ab = _toBoolLike(a);
    final bb = _toBoolLike(b);
    if (ab != null && bb != null) return ab == bb;

    return a.toString() == b.toString();
  }

  static bool? _toBoolLike(Object? value) {
    if (value is bool) return value;
    if (value is num) {
      if (value == 0) return false;
      if (value == 1) return true;
    }
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (const {'1', 'true', 'yes', 'on', 'y'}.contains(v)) return true;
      if (const {'0', 'false', 'no', 'off', 'n'}.contains(v)) return false;
    }
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value == null) return const [];
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    }
    if (value is List) {
      return value
          .whereType<Object>()
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    }
    return const [];
  }

  static bool _validateEmailDomains(
    String email,
    List<String> allowed,
    List<String> disallowed,
  ) {
    final at = email.lastIndexOf('@');
    if (at <= 0) return false;
    final domain = email.substring(at + 1).trim().toLowerCase();
    if (domain.isEmpty) return false;

    final allowedSet = allowed.map((e) => e.toLowerCase()).toSet();
    final disallowedSet = disallowed.map((e) => e.toLowerCase()).toSet();

    if (allowedSet.isNotEmpty && !allowedSet.contains(domain)) return false;
    if (disallowedSet.isNotEmpty && disallowedSet.contains(domain))
      return false;

    return true;
  }

  static List<Object?> _normalizeListValue(Object? value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return const [];
      return trimmed
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [value];
  }

  static List<Object?>? _normalizeFiles(Object? value) {
    if (value == null) return const [];
    if (value is List) return value;
    if (value is Map) return [value];
    return null;
  }

  static int? _fileSize(Object? file) {
    if (file is Map) {
      final size = file['size'];
      if (size is int) return size;
      if (size is num) return size.toInt();
      if (size is String) return int.tryParse(size.trim());
    }
    return null;
  }

  static String? _fileMime(Object? file) {
    if (file is Map) {
      final type = file['type'];
      if (type is String && type.trim().isNotEmpty) return type.trim();
    }
    return null;
  }
}
