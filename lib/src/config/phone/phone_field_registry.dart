import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIPhoneFieldContext {
  final SDUIField field;
  final FormManager formManager;
  final TextEditingController controller;
  final FocusNode focusNode;
  final InputDecoration baseDecoration;
  final String? errorText;
  final String? helpText;
  final String labelText;
  final String hintText;
  final bool isEnabled;
  final TextInputType keyboardType;
  final List<String>? autofillHints;
  final List<TextInputFormatter> inputFormatters;
  final List<Country> availableCountries;
  final Country? selectedCountry;
  final CountryForm? selectedCountryForm;
  final String codeType;
  final String format;
  final String displayValue;
  final String rawValue;
  final PhoneNumber? parsedValue;
  final String? internationalValue;
  final String? nationalValue;
  final String? normalizedValue;
  final ValueChanged<String> onChanged;
  final ValueChanged<Country?> setCountry;
  final ValueChanged<String?> setCountryCode;
  final Future<void> Function() pickCountry;
  final String? Function([String? value]) validate;
  final String? Function([String? value]) normalize;
  final PhoneNumber? Function([String? value]) parse;
  final VoidCallback clearError;

  const SDUIPhoneFieldContext({
    required this.field,
    required this.formManager,
    required this.controller,
    required this.focusNode,
    required this.baseDecoration,
    required this.errorText,
    required this.helpText,
    required this.labelText,
    required this.hintText,
    required this.isEnabled,
    required this.keyboardType,
    required this.autofillHints,
    required this.inputFormatters,
    required this.availableCountries,
    required this.selectedCountry,
    required this.selectedCountryForm,
    required this.codeType,
    required this.format,
    required this.displayValue,
    required this.rawValue,
    required this.parsedValue,
    required this.internationalValue,
    required this.nationalValue,
    required this.normalizedValue,
    required this.onChanged,
    required this.setCountry,
    required this.setCountryCode,
    required this.pickCountry,
    required this.validate,
    required this.normalize,
    required this.parse,
    required this.clearError,
  });

  bool get hasSelectedCountry => selectedCountry != null;
  bool get canSelectCountry => availableCountries.isNotEmpty;
}

typedef SDUIPhoneFieldBuilder =
    Widget Function(BuildContext context, SDUIPhoneFieldContext phoneContext);

class SDUIPhoneFieldRegistry {
  SDUIPhoneFieldRegistry._();
  static final instance = SDUIPhoneFieldRegistry._();

  SDUIPhoneFieldBuilder? _builder;

  bool register(SDUIPhoneFieldBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIPhoneFieldBuilder? get builder => _builder;

  bool get hasBuilder => _builder != null;

  bool unregister() {
    final existed = _builder != null;
    _builder = null;
    return existed;
  }

  void clear() {
    _builder = null;
  }
}
