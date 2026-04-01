import 'package:flutter/material.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

typedef SDUIAddressComponentValueSetter =
    void Function(String key, dynamic value);

typedef SDUIAddressComponentValuesSetter =
    void Function(Map<String, dynamic> values, {bool merge});

class SDUIAddressInputBinding {
  final SDUIField field;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final List<String>? autofillHints;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final bool isEnabled;
  final bool isCountryField;
  final String value;
  final String displayValue;
  final CountryForm? selectedCountry;
  final ValueChanged<dynamic> onChanged;
  final Future<void> Function()? pickCountry;

  const SDUIAddressInputBinding({
    required this.field,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.autofillHints,
    required this.keyboardType,
    required this.textInputAction,
    required this.maxLines,
    required this.isEnabled,
    required this.isCountryField,
    required this.value,
    required this.displayValue,
    required this.selectedCountry,
    required this.onChanged,
    required this.pickCountry,
  });
}

class SDUIAddressComponentContext {
  final SDUIField field;
  final FormManager formManager;
  final FocusNode fieldFocusNode;
  final InputDecoration baseDecoration;
  final String? errorText;
  final String? helpText;
  final bool isEnabled;
  final Map<String, String> value;
  final Map<String, String>? compactValue;
  final List<SDUIAddressInputBinding> components;
  final Map<String, SDUIAddressInputBinding> componentsByKey;
  final SDUIAddressComponentValueSetter setComponentValue;
  final SDUIAddressComponentValuesSetter setValues;
  final String? Function([Map<String, String>? value]) validate;
  final VoidCallback clearError;

  const SDUIAddressComponentContext({
    required this.field,
    required this.formManager,
    required this.fieldFocusNode,
    required this.baseDecoration,
    required this.errorText,
    required this.helpText,
    required this.isEnabled,
    required this.value,
    required this.compactValue,
    required this.components,
    required this.componentsByKey,
    required this.setComponentValue,
    required this.setValues,
    required this.validate,
    required this.clearError,
  });

  SDUIAddressInputBinding? component(String key) {
    return componentsByKey[key];
  }

  SDUIAddressInputBinding? get addressLine1 =>
      component('address_line_1') ?? component('street_address');

  SDUIAddressInputBinding? get addressLine2 => component('address_line_2');
  SDUIAddressInputBinding? get streetAddress => addressLine1;
  SDUIAddressInputBinding? get city => component('city');
  SDUIAddressInputBinding? get state => component('state');
  SDUIAddressInputBinding? get postalCode => component('postal_code');
  SDUIAddressInputBinding? get country => component('country');
}

typedef SDUIAddressComponentBuilder =
    Widget Function(
      BuildContext context,
      SDUIAddressComponentContext addressContext,
    );

class SDUIAddressComponentRegistry {
  SDUIAddressComponentRegistry._();
  static final instance = SDUIAddressComponentRegistry._();

  SDUIAddressComponentBuilder? _builder;

  bool register(SDUIAddressComponentBuilder builder, {bool override = false}) {
    if (_builder != null && !override) return false;
    _builder = builder;
    return true;
  }

  SDUIAddressComponentBuilder? get builder => _builder;

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
