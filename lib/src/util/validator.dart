import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sdui/sdui.dart';

/// A comprehensive validation class for handling various types of input fields.
///
/// The `FieldValidator` provides a centralized set of methods to validate different
/// data types and rules, from simple "required" checks to complex conditional logic
/// dependent on other fields' values.
class FieldValidator {
  FieldValidator._();
  static final FieldValidator instance = FieldValidator._();

  /// The main validation method that orchestrates all validation checks.
  ///
  /// It takes a `validation` object containing the rule and parameters, and checks it
  /// against the provided value (`textValue`, `dateValue`, etc.).
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
  }) {
    final rule = validation.rule.toLowerCase();
    final params = validation.params;
    switch (rule) {
      case "required":
        if (textValue == null || textValue.isEmpty) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case "email":
        if (!validateEmail(textValue)) {
          return validation.message ?? 'Please enter a valid email address';
        }
        return null;
      case "phone":
        if (!validatePhone(textValue, selectedCountryCode)) {
          return validation.message ?? 'Please enter a valid email address';
        }
        return null;
      case "boolean":
        if (!validateBoolean(booleanValue)) {
          return validation.message ?? 'Please enter a valid boolean value';
        }
        return null;

      case ("date" || "datetime"):
        if (!validateDate(dateValue)) {
          return validation.message ?? 'Please enter a valid date';
        }
        return null;
      case "time":
        if (!validateTime(timeValue)) {
          return validation.message ?? 'Please enter a valid time';
        }
        return null;

      case 'numeric':
        if (!validateNumeric(textValue)) {
          return validation.message ?? 'Value must be numeric';
        }
        return null;
      case 'string':
        break;
      case 'min':
        if (!validateMin(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final min = params[0] as num;
            return validation.message ?? 'Minimum value is $min';
          }
          return validation.message;
        }
        return null;
      case 'max':
        if (!validateMax(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final max = params[0] as num;
            return validation.message ?? 'Maximum value is $max';
          }
          return validation.message;
        }
        return null;
      case 'between':
        if (!validateBetween(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final min = params[0] as num;
            final max = params[1] as num;
            return validation.message ?? 'Value must be between $min and $max';
          }
          return validation.message;
        }
        return null;
      case 'not_between':
        if (!validateNotBetween(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final min = params[0] as num;
            final max = params[1] as num;
            return validation.message ??
                'Value must not be between $min and $max';
          }
          return validation.message;
        }
        return null;
      case 'regex':
        if (!validateRegex(params, textValue)) {
          return validation.message ?? 'Invalid format';
        }
        return null;
      case 'in':
        if (!validateIn(params, textValue)) {
          return validation.message ?? 'Invalid value';
        }
        return null;
      case 'not_in':
        if (!validateNotIn(params, textValue)) {
          return validation.message ?? 'Invalid value';
        }
        return null;
      case 'starts_with':
        if (!validateStartsWith(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final prefix = params[0] as String;
            return validation.message ?? 'Value must start with $prefix';
          }
          return validation.message;
        }
        return null;
      case 'ends_with':
        if (!validateEndsWith(params, textValue)) {
          final check = params.isNotEmpty;
          if (check) {
            final suffix = params[0] as String;
            return validation.message ?? 'Value must end with $suffix';
          }
          return validation.message;
        }
        return null;

      case 'before':
        if (!validateBefore(params, textValue, formManager)) {
          final check = params.isNotEmpty;
          if (check) {
            final param = params[0] as String;
            return validation.message ?? 'Value must be before $param';
          }
          return validation.message;
        }
        return null;
      case 'after':
        if (!validateAfter(params, textValue, formManager)) {
          final check = params.isNotEmpty;
          if (check) {
            final param = params[0] as String;
            return validation.message ?? 'Value must be after $param';
          }
          return validation.message;
        }
        return null;
      case 'required_if':
        if (!requiredIf(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_unless':
        if (!requiredUnless(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_with':
        if (!requiredWith(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_without':
        if (!requiredWithout(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_with_all':
        if (!requiredWith(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_without_all':
        if (!requiredWithout(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_if_accepted':
        if (!requiredIfAccepted(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      case 'required_if_declined':
        if (!requiredIfDeclined(params, textValue, formManager)) {
          return validation.message ?? 'This field is required';
        }
        return null;
      default:
    }
    return null;
  }

  /// Validates that a `String` is a well-formed email address.
  bool validateEmail(String? textValue) {
    if (textValue == null || textValue.isEmpty) return false;
    return EmailValidator.validate(textValue);
  }

  /// Validates a phone number against a given country code.
  bool validatePhone(String? textValue, String? selectedCountryCode) {
    if (textValue == null || textValue.isEmpty || selectedCountryCode == null) {
      return false;
    }
    final isoCode = IsoCode.fromJson(selectedCountryCode);
    final phoneNumber = PhoneNumber.parse(
      textValue,
      destinationCountry: isoCode,
    );
    return phoneNumber.isValid();
  }

  /// Validates that a boolean value is not null.
  bool validateBoolean(bool? booleanValue) {
    if (booleanValue == null) return false;
    return true;
  }

  /// Validates that a `DateTime` value is not null.
  bool validateDate(DateTime? dateValue) {
    if (dateValue == null) return false;
    return true;
  }

  /// Validates that a `TimeOfDay` value is not null.
  bool validateTime(TimeOfDay? timeValue) {
    if (timeValue == null) return false;
    return true;
  }

  /// Validates that a string can be parsed as a number.
  bool validateNumeric(String? textValue) {
    if (textValue == null || textValue.isEmpty) return false;
    return double.tryParse(textValue) != null;
  }

  /// Validates that a value is a non-empty string.
  bool validateString(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.runtimeType == String;
  }

  /// Validates that a numeric value is greater than or equal to a minimum.
  /// `params[0]` is expected to be the minimum numeric value.
  bool validateMin(List<dynamic> params, String? value) {
    if (params.isNotEmpty && value != null) {
      final numValue = double.tryParse(value);
      if (numValue == null) return false;
      final min = params[0] as num;
      return numValue >= min;
    }
    return true;
  }

  /// Validates that a numeric value is less than or equal to a maximum.
  /// `params[0]` is expected to be the maximum numeric value.
  bool validateMax(List<dynamic> params, String? value) {
    if (params.isNotEmpty && value != null) {
      final numValue = double.tryParse(value);
      if (numValue == null) return false;
      final max = params[0] as num;
      return numValue <= max;
    }
    return true;
  }

  /// Validates that a numeric value is within a given range (inclusive).
  /// `params[0]` is the minimum, `params[1]` is the maximum.
  bool validateBetween(List<dynamic> params, String? value) {
    if (params.isNotEmpty && value != null) {
      final numValue = double.tryParse(value);
      if (numValue == null) return false;
      final min = params[0] as num;
      final max = params[1] as num;
      return numValue >= min && numValue <= max;
    }
    return true;
  }

  /// Validates that a numeric value is outside a given range.
  /// `params[0]` is the minimum, `params[1]` is the maximum.
  bool validateNotBetween(List<dynamic> params, String? value) {
    if (params.isNotEmpty && value != null) {
      final numValue = double.tryParse(value);
      if (numValue == null) return false;
      final min = params[0] as num;
      final max = params[1] as num;
      return numValue < min || numValue > max;
    }
    return true;
  }

  /// Validates that a string matches a regular expression.
  /// `params[0]` is expected to be the regex pattern.
  bool validateRegex(List<dynamic> params, String? value) {
    if (params.isNotEmpty && value != null) {
      final regex = RegExp(params[0].toString());
      return regex.hasMatch(value);
    }
    return true;
  }

  /// Validates that the input string contains at least one of the substrings in `params`.
  bool validateIn(List<dynamic> params, String? value) {
    if (params.isEmpty || value == null) return true;
    return params
        .map((e) => e.toString())
        .any((eachValue) => value.contains(eachValue));
  }

  /// Validates that the input string does not contain any of the substrings in `params`.
  bool validateNotIn(List<dynamic> params, String? value) {
    if (params.isEmpty || value == null) return true;
    return params
        .map((e) => e.toString())
        .any((eachValue) => !value.contains(eachValue));
  }

  /// Validates that the input string starts with one of the prefixes in `params`.
  bool validateStartsWith(List<dynamic> params, String? value) {
    if (params.isEmpty || value == null) return true;

    return params
        .map((e) => e.toString())
        .any((prefix) => value.startsWith(prefix));
  }

  /// Validates that the input string ends with one of the suffixes in `params`.
  bool validateEndsWith(List<dynamic> params, String? value) {
    if (params.isEmpty || value == null) return true;
    return params
        .map((e) => e.toString())
        .any((suffix) => value.endsWith(suffix));
  }

  /// Validates that the field's date value is before a specified date.
  /// The parameter in `params[0]` can be a date string or a field reference
  /// (e.g., "{field:other_date_field}").
  bool validateBefore(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    return params.map((e) => e.toString()).any((param) {
      final isDate = DateTime.tryParse(param);
      if (isDate == null) {
        //fields
        final field = params[0] as String;
        final regex = RegExp(r'\{field:(.*?)\}');
        final match = regex.firstMatch(field);
        final result = match?.group(1);
        if (result != null) {
          final fieldValue = formManager.getFieldValue(result);
          if (fieldValue == null) return true;
          return false;
        }
        return false;
      } else {
        final now = DateTime.now();
        final nowDate = DateTime(now.year, now.month, now.day);
        final isValid = (nowDate.isBefore(isDate));
        return isValid;
      }
    });
  }

  /// Validates that the field's date value is after a specified date.
  /// The parameter in `params[0]` can be a date string or a field reference.
  bool validateAfter(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    return params.map((e) => e.toString()).any((param) {
      final isDate = DateTime.tryParse(param);
      if (isDate == null) {
        //fields
        final field = params[0] as String;
        final regex = RegExp(r'\{field:(.*?)\}');
        final match = regex.firstMatch(field);
        final result = match?.group(1);
        if (result != null) {
          final fieldValue = formManager.getFieldValue(result);
          if (fieldValue == null) return false;
          return true;
        }
        return false;
      } else {
        final now = DateTime.now();
        final nowDate = DateTime(now.year, now.month, now.day);
        final isValid = (nowDate.isAfter(isDate));
        return isValid;
      }
    });
  }

  /// Makes the field required if another field contains one of the specified values.
  /// `params[0]` should be the field reference, and subsequent params are the values to check for.
  bool requiredIf(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return true;

    return params.map((e) => e.toString()).any((param) {
      final match = regex.firstMatch(param);
      if (match == null) {
        final fieldValue = formManager.getFieldValue(field.group(1)!);
        if (fieldValue == null) return false;
        if (fieldValue.contains(param)) {
          if (value.isEmpty) return false;
        }
        return true;
      }
      return false;
    });
  }

  /// Makes the field required unless another field contains one of the specified values.
  bool requiredUnless(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return true;

    return params.map((e) => e.toString()).any((param) {
      final match = regex.firstMatch(param);
      if (match == null) {
        final fieldValue = formManager.getFieldValue(field.group(1)!);
        if (fieldValue == null) return false;
        if (fieldValue.contains(param)) return true;
        if (value.isEmpty) return false;
      }
      return false;
    });
  }

  /// Makes the field required if another specified field has any value.
  bool requiredWith(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return false;
    final fieldValue = formManager.getFieldValue(field.group(1)!);
    if (fieldValue != null) {
      if (value.isEmpty) return false;
    }
    return true;
  }

  /// Makes the field required if another specified field is empty.
  bool requiredWithout(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return false;
    final fieldValue = formManager.getFieldValue(field.group(1)!);
    if (fieldValue == null) {
      if (value.isEmpty) return false;
    }
    return true;
  }

  /// Makes the field required if another field is considered "accepted" (has a value and no errors).
  bool requiredIfAccepted(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return false;
    final fieldValue = formManager.getFieldValue(field.group(1)!);
    final errorValue = formManager.getError(field.group(1)!);
    if (fieldValue != null && errorValue == null) {
      if (value.isEmpty) return false;
    }
    return true;
  }

  /// Makes the field required if another field is considered "declined" (has no value or has an error).
  bool requiredIfDeclined(
    List<dynamic> params,
    String? value,
    FormManager formManager,
  ) {
    if (params.isEmpty || value == null) return true;
    final regex = RegExp(r'\{field:(.*?)\}');
    final field = regex.firstMatch(params[0] as String);
    if (field == null || field.group(1) == null) return false;
    final fieldValue = formManager.getFieldValue(field.group(1)!);
    final errorValue = formManager.getError(field.group(1)!);
    if (fieldValue == null || errorValue != null) {
      if (value.isEmpty) return false;
    }
    return true;
  }
}
