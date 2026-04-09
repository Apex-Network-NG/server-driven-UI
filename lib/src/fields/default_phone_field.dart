import 'dart:math' as math;

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:sdui/src/config/bottomsheet/bottomsheet_service.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_service.dart';
import 'package:sdui/src/config/phone/phone_field_registry.dart';
import 'package:sdui/src/fields/country_picker_sheet.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/extensions.dart';
import 'package:sdui/src/util/phone_field_support.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIPhoneField extends SDUIBaseStatefulWidget {
  const SDUIPhoneField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() => _SDUIPhoneFieldState();
}

class _SDUIPhoneFieldState extends SDUIBaseState<SDUIPhoneField> {
  final CountryService _countryService = CountryService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureInitialCountrySelection();
      _applyDefaultValue();
    });
  }

  @override
  String? validateField(dynamic value) {
    widget.formManager.clearError(widget.field.key);
    final rawValue = value?.toString();
    final selectedCountryCode = _selectedCountry?.countryCode;
    final error = FieldValidator.instance.validateField(
      field: widget.field,
      formManager: widget.formManager,
      value: rawValue,
      selectedCountryCode: selectedCountryCode,
    );
    if (error != null) {
      widget.formManager.addError(widget.field.key, error);
    }
    return error;
  }

  Country? get _selectedCountry => selectedPhoneCountryForField(
    widget.field,
    widget.formManager,
    countryService: _countryService,
  );

  List<Country> get _availableCountries => availablePhoneCountriesForField(
    widget.field,
    countryService: _countryService,
  );

  void _ensureInitialCountrySelection() {
    if (widget.formManager.getSelectedCountry(widget.field.key) != null) return;
    final initialCountry = initialPhoneCountryForField(
      widget.field,
      widget.formManager,
      countryService: _countryService,
    );
    if (initialCountry == null) return;
    widget.formManager.updateSelectedCountry(
      widget.field.key,
      countryFormForPhoneCountry(initialCountry),
    );
  }

  void _applyDefaultValue() {
    final defaultValue = widget.field.defaultValue;
    if (defaultValue == null) return;

    final controller = widget.formManager.getController(widget.field.key);
    if (controller.text.isNotEmpty) return;

    final rawValue = defaultValue.toString().trim();
    if (rawValue.isEmpty) return;

    controller.text = formatPhoneDisplayValueForField(widget.field, rawValue);
    final normalizedValue = normalizedPhoneValueForField(
      widget.field,
      rawValue,
      selectedCountryCode: _selectedCountry?.countryCode,
    );
    widget.formManager.setFieldValue(
      widget.field.key,
      normalizedValue ?? rawValue,
    );
  }

  Future<void> _showCountryPicker() async {
    if (widget.field.readonly) return;

    final country = await BottomSheetService.showBottomSheet(
      context: context,
      child: CountryPickerSheet(
        field: widget.field,
        selectedCountry: _selectedCountry,
      ),
    );

    if (!mounted || !context.mounted) return;
    if (country is! Country) return;

    _setCountry(country);
  }

  void _setCountry(Country? country) {
    widget.formManager.updateSelectedCountry(
      widget.field.key,
      countryFormForPhoneCountry(country),
    );
    _syncPhoneValue();
  }

  void _setCountryCode(String? countryCode) {
    final country = resolvePhoneCountryByCode(
      countryCode,
      codeType: widget.field.constraints?.codeType,
      countryService: _countryService,
      availableCountries: _availableCountries,
    );
    _setCountry(country);
  }

  void _setControllerText(String value) {
    final controller = widget.formManager.getController(widget.field.key);
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  void _syncPhoneValue([String? displayValue]) {
    final inputValue =
        displayValue ?? widget.formManager.getController(widget.field.key).text;
    final rawValue = unmaskPhoneValueForField(widget.field, inputValue);
    final error = validateField(rawValue);
    final outgoingValue = error == null
        ? (normalizedPhoneValueForField(
                widget.field,
                rawValue,
                selectedCountryCode: _selectedCountry?.countryCode,
              ) ??
              rawValue)
        : rawValue;

    widget.onChanged?.call(widget.field.key, outgoingValue);
  }

  SDUIPhoneFieldContext _buildPhoneContext(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final controller = widget.formManager.getController(widget.field.key);
    final focusNode = widget.formManager.getFocusNode(widget.field.key);
    final displayValue = controller.text;
    final rawValue = unmaskPhoneValueForField(widget.field, displayValue);
    final selectedCountry = _selectedCountry;
    final selectedCountryCode = selectedCountry?.countryCode;
    final keyboardType =
        widget.field.ui?.inputMode?.uiTextInputType ??
        widget.field.type.textInputType;
    final parsedValue = parsePhoneValueForField(
      widget.field,
      rawValue,
      selectedCountryCode: selectedCountryCode,
    );

    return SDUIPhoneFieldContext(
      field: widget.field,
      formManager: widget.formManager,
      controller: controller,
      focusNode: focusNode,
      baseDecoration: sduiTheme?.inputDecoration ?? const InputDecoration(),
      errorText: widget.formManager.getError(widget.field.key),
      helpText: widget.field.helpText,
      labelText: widget.field.label,
      hintText: widget.field.placeholder ?? widget.field.label,
      isEnabled: !widget.field.readonly,
      keyboardType: keyboardType,
      autofillHints: widget.field.ui?.autocomplete?.uiAutofillHints,
      inputFormatters: phoneInputFormattersForField(widget.field),
      availableCountries: _availableCountries,
      selectedCountry: selectedCountry,
      selectedCountryForm: widget.formManager.getSelectedCountry(
        widget.field.key,
      ),
      codeType: normalizePhoneCodeType(widget.field.constraints?.codeType),
      format: normalizePhoneFormat(widget.field.constraints?.format),
      displayValue: displayValue,
      rawValue: rawValue,
      parsedValue: parsedValue,
      internationalValue: internationalPhoneValueForField(
        widget.field,
        rawValue,
        selectedCountryCode: selectedCountryCode,
      ),
      nationalValue: nationalPhoneValueForField(
        widget.field,
        rawValue,
        selectedCountryCode: selectedCountryCode,
      ),
      normalizedValue: normalizedPhoneValueForField(
        widget.field,
        rawValue,
        selectedCountryCode: selectedCountryCode,
      ),
      onChanged: (value) {
        _setControllerText(value);
        _syncPhoneValue(value);
      },
      setCountry: _setCountry,
      setCountryCode: _setCountryCode,
      pickCountry: _showCountryPicker,
      validate: ([value]) {
        return validateField(
          value == null
              ? unmaskPhoneValueForField(widget.field, controller.text)
              : unmaskPhoneValueForField(widget.field, value),
        );
      },
      normalize: ([value]) {
        final nextRawValue = value == null
            ? unmaskPhoneValueForField(widget.field, controller.text)
            : unmaskPhoneValueForField(widget.field, value);
        return normalizedPhoneValueForField(
          widget.field,
          nextRawValue,
          selectedCountryCode: _selectedCountry?.countryCode,
        );
      },
      parse: ([value]) {
        final nextRawValue = value == null
            ? unmaskPhoneValueForField(widget.field, controller.text)
            : unmaskPhoneValueForField(widget.field, value);
        return parsePhoneValueForField(
          widget.field,
          nextRawValue,
          selectedCountryCode: _selectedCountry?.countryCode,
        );
      },
      clearError: clearError,
    );
  }

  Widget _buildDefaultPhoneField(
    BuildContext context,
    SDUIPhoneFieldContext phoneContext,
  ) {
    final theme = Theme.of(context);
    final selectedCountryCode = phoneContext.selectedCountry?.countryCode ?? '';

    return TextFormField(
      controller: phoneContext.controller,
      focusNode: phoneContext.focusNode,
      enabled: phoneContext.isEnabled,
      maxLines: widget.field.ui?.multilineRows,
      keyboardType: phoneContext.keyboardType,
      autofillHints: phoneContext.autofillHints,
      inputFormatters: phoneContext.inputFormatters,
      style: theme.textTheme.bodySmall,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: phoneContext.onChanged,
      decoration: phoneContext.baseDecoration.copyWith(
        hintText: phoneContext.hintText,
        errorText: phoneContext.errorText,
        labelText: phoneContext.labelText,
        helperText: phoneContext.helpText,
        prefixText: widget.field.ui?.prefix?.trim().isNotEmpty == true
            ? widget.field.ui?.prefix
            : null,
        suffixText: widget.field.ui?.suffix?.trim().isNotEmpty == true
            ? widget.field.ui?.suffix
            : null,
        prefixIcon: InkWell(
          onTap: phoneContext.isEnabled ? phoneContext.pickCountry : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                child: CircleFlag(selectedCountryCode, size: 24),
              ),
              Transform.rotate(
                angle: math.pi / 2,
                child: const Icon(
                  Icons.chevron_right_rounded,
                  semanticLabel: 'Dropdown indicator',
                ),
              ),
              const SizedBox(width: 8),
              const VerticalDivider(),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneContext = _buildPhoneContext(context);
    final customBuilder = SDUIPhoneFieldRegistry.instance.builder;
    if (customBuilder != null) {
      return customBuilder(context, phoneContext);
    }

    return _buildDefaultPhoneField(context, phoneContext);
  }
}
