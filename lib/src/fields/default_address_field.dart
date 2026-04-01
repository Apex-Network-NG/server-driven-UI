import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdui/src/config/address/address_component_registry.dart';
import 'package:sdui/src/config/bottomsheet/bottomsheet_service.dart';
import 'package:sdui/src/config/country/country.dart';
import 'package:sdui/src/config/country/country_form.dart';
import 'package:sdui/src/config/country/country_service.dart';
import 'package:sdui/src/fields/country_picker_sheet.dart';
import 'package:sdui/src/fields/selector.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/theme/sdui_theme.dart';
import 'package:sdui/src/util/address_field_value.dart';
import 'package:sdui/src/util/extensions.dart';
import 'package:sdui/src/util/mask_input_formatter.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIAddressField extends SDUIBaseStatefulWidget {
  const SDUIAddressField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIBaseStatefulWidget> createState() =>
      _SDUIAddressFieldState();
}

class _SDUIAddressFieldState extends SDUIBaseState<SDUIAddressField> {
  late final List<SDUIField> _componentFields;
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, FocusNode> _focusNodes;
  final Map<String, CountryForm?> _selectedCountries = <String, CountryForm?>{};
  final List<Country> _countries = CountryService().getAll();

  @override
  void initState() {
    super.initState();
    _componentFields = resolveAddressComponentFields(widget.field);
    _controllers = <String, TextEditingController>{
      for (final componentField in _componentFields)
        componentField.key: TextEditingController(),
    };
    _focusNodes = <String, FocusNode>{
      for (final componentField in _componentFields)
        componentField.key: FocusNode(),
    };
    _syncStateFromValue(_effectiveFieldValue());
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sduiTheme = theme.extension<SDUITheme>();
    final baseDecoration =
        sduiTheme?.inputDecoration ?? const InputDecoration();

    _syncStateFromValue(_effectiveFieldValue());

    final addressContext = _buildAddressContext(baseDecoration: baseDecoration);
    final customBuilder = SDUIAddressComponentRegistry.instance.builder;

    return Focus(
      focusNode: widget.formManager.getFocusNode(widget.field.key),
      canRequestFocus: false,
      descendantsAreFocusable: true,
      child: customBuilder != null
          ? customBuilder(context, addressContext)
          : _buildDefaultField(context, addressContext),
    );
  }

  SDUIAddressComponentContext _buildAddressContext({
    required InputDecoration baseDecoration,
  }) {
    final normalized = normalizeAddressValue(
      widget.field,
      _currentAddressValue(),
    );
    final components = <SDUIAddressInputBinding>[
      for (var index = 0; index < _componentFields.length; index++)
        _buildInputBinding(_componentFields[index], index),
    ];

    return SDUIAddressComponentContext(
      field: widget.field,
      formManager: widget.formManager,
      fieldFocusNode: widget.formManager.getFocusNode(widget.field.key),
      baseDecoration: baseDecoration,
      errorText: widget.formManager.getError(widget.field.key),
      helpText: widget.field.helpText,
      isEnabled: !widget.field.readonly,
      value: normalized,
      compactValue: compactAddressValue(widget.field, normalized),
      components: components,
      componentsByKey: <String, SDUIAddressInputBinding>{
        for (final component in components) component.field.key: component,
      },
      setComponentValue: _setComponentValue,
      setValues: _setValues,
      validate: _validateAddress,
      clearError: () => widget.formManager.clearError(widget.field.key),
    );
  }

  SDUIAddressInputBinding _buildInputBinding(
    SDUIField componentField,
    int index,
  ) {
    final key = componentField.key;
    final controller = _controllers[key]!;
    final fieldType = componentField.type.trim().toLowerCase();
    final ui = componentField.ui;
    final keyboardType =
        ui?.inputMode?.uiTextInputType ?? fieldType.textInputType;
    final rawAutofillHints = ui?.autocomplete?.uiAutofillHints;
    final autofillHints =
        rawAutofillHints ?? componentField.key.uiAutofillHints;
    final country = _selectedCountries[key];
    final rawValue = _currentComponentValue(componentField);
    final displayValue = fieldType == 'country'
        ? (country?.countryName ?? controller.text.trim())
        : controller.text.trim();

    return SDUIAddressInputBinding(
      field: componentField,
      controller: controller,
      focusNode: _focusNodes[key]!,
      hintText: componentField.placeholder ?? componentField.label,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      textInputAction: index == _componentFields.length - 1
          ? TextInputAction.done
          : TextInputAction.next,
      maxLines: (ui?.multilineRows ?? 1).clamp(1, 8),
      isEnabled: !widget.field.readonly && !componentField.readonly,
      isCountryField: fieldType == 'country',
      value: rawValue,
      displayValue: displayValue,
      selectedCountry: country,
      onChanged: (value) => _handleComponentChanged(componentField, value),
      pickCountry: fieldType == 'country'
          ? () => _showCountryPicker(componentField)
          : null,
    );
  }

  Widget _buildDefaultField(
    BuildContext context,
    SDUIAddressComponentContext addressContext,
  ) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall;
    final icon = widget.field.ui?.icon?.sduiIconData;
    final helpText = addressContext.helpText?.trim();
    final componentChildren = _buildComponentLayout(context, addressContext);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.field.label.trim().isNotEmpty) ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(child: Text(widget.field.label, style: labelStyle)),
              if (requiredAddressComponentFields(widget.field).isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: labelStyle?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
        ],
        ...componentChildren,
        if (helpText != null && helpText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(helpText, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }

  List<Widget> _buildComponentLayout(
    BuildContext context,
    SDUIAddressComponentContext addressContext,
  ) {
    final children = <Widget>[];
    final buffered = <Widget>[];

    void flushRow() {
      if (buffered.isEmpty) return;
      if (buffered.length == 1) {
        children.add(buffered.removeLast());
      } else {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buffered[0]),
              const SizedBox(width: 12),
              Expanded(child: buffered[1]),
            ],
          ),
        );
        buffered.clear();
      }
      children.add(const SizedBox(height: 12));
    }

    for (final component in addressContext.components) {
      final componentWidget = _buildComponentWidget(
        context,
        component,
        addressContext,
      );

      if (_isWideComponent(component.field)) {
        flushRow();
        children.add(componentWidget);
        children.add(const SizedBox(height: 12));
        continue;
      }

      buffered.add(componentWidget);
      if (buffered.length == 2) {
        flushRow();
      }
    }

    flushRow();
    if (children.isNotEmpty && children.last is SizedBox) {
      children.removeLast();
    }
    return children;
  }

  bool _isWideComponent(SDUIField componentField) {
    final key = componentField.key.trim().toLowerCase();
    if (componentField.ui?.multilineRows != null &&
        (componentField.ui?.multilineRows ?? 1) > 1) {
      return true;
    }
    return key.contains('address') ||
        key.contains('street') ||
        key.contains('line');
  }

  Widget _buildComponentWidget(
    BuildContext context,
    SDUIAddressInputBinding input,
    SDUIAddressComponentContext addressContext,
  ) {
    if (input.isCountryField) {
      return Selector(
        header: input.field.label,
        hintText: input.hintText,
        helpText: input.field.helpText,
        errorText: null,
        title: input.displayValue.trim().isEmpty ? null : input.displayValue,
        onTap: input.isEnabled && input.pickCountry != null
            ? () {
                input.pickCountry!.call();
              }
            : () {},
      );
    }

    final theme = Theme.of(context);
    final ui = input.field.ui;
    final uiMaxLength = ui?.maxLength;
    final prefixText = ui?.prefix?.trim().isNotEmpty == true
        ? ui?.prefix
        : null;
    final suffixText = ui?.suffix?.trim().isNotEmpty == true
        ? ui?.suffix
        : null;
    final mask = ui?.mask?.trim();
    final maskFormatter = mask?.isNotEmpty == true
        ? SDUIMaskTextInputFormatter(mask: mask!, maxLength: uiMaxLength)
        : null;
    final inputFormatters = <TextInputFormatter>[
      if (maskFormatter != null) maskFormatter,
      if (maskFormatter == null && uiMaxLength != null)
        LengthLimitingTextInputFormatter(uiMaxLength),
    ];

    return TextFormField(
      controller: input.controller,
      focusNode: input.focusNode,
      enabled: input.isEnabled,
      keyboardType: input.keyboardType,
      textInputAction: input.textInputAction,
      maxLines: input.maxLines,
      autofillHints: input.autofillHints,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodySmall,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        final rawValue = maskFormatter?.unmask(value) ?? value;
        input.onChanged(rawValue);
      },
      decoration: addressContext.baseDecoration.copyWith(
        hintText: input.hintText,
        errorText: null,
        helperText: null,
        labelText: input.field.label,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixIcon: ui?.icon?.sduiIconData != null
            ? Icon(ui!.icon!.sduiIconData)
            : null,
      ),
    );
  }

  Future<void> _showCountryPicker(SDUIField componentField) async {
    final current = _selectedCountries[componentField.key];
    final selectedCountry = _findCountry(
      current?.countryCode ??
          current?.countryName ??
          _controllers[componentField.key]!.text,
    );

    final result = await BottomSheetService.showBottomSheet(
      context: context,
      child: CountryPickerSheet(
        field: componentField,
        selectedCountry: selectedCountry,
      ),
    );

    if (!mounted || result == null) return;
    if (result is! Country) return;

    final countryForm = CountryForm(
      countryCode: result.countryCode,
      countryName: result.name,
    );
    _selectedCountries[componentField.key] = countryForm;
    _syncController(_controllers[componentField.key]!, countryForm.countryName);
    _commitAddressValue(_currentAddressValue());
  }

  void _handleComponentChanged(SDUIField componentField, dynamic value) {
    _setComponentValue(componentField.key, value);
  }

  void _setComponentValue(String key, dynamic value) {
    final componentField = _componentField(key);
    if (componentField == null) return;

    if (componentField.type.trim().toLowerCase() == 'country') {
      _setCountryComponentValue(componentField, value);
    } else {
      final text = value?.toString() ?? '';
      _selectedCountries.remove(key);
      _syncController(_controllers[key]!, text);
    }

    _commitAddressValue(_currentAddressValue());
  }

  void _setValues(Map<String, dynamic> values, {bool merge = true}) {
    if (!merge) {
      for (final componentField in _componentFields) {
        if (!values.containsKey(componentField.key)) {
          _selectedCountries.remove(componentField.key);
          _syncController(_controllers[componentField.key]!, '');
        }
      }
    }

    values.forEach(_setComponentValueWithoutCommit);
    _commitAddressValue(_currentAddressValue());
  }

  void _setComponentValueWithoutCommit(String key, dynamic value) {
    final componentField = _componentField(key);
    if (componentField == null) return;

    if (componentField.type.trim().toLowerCase() == 'country') {
      _setCountryComponentValue(componentField, value);
    } else {
      _selectedCountries.remove(key);
      _syncController(_controllers[key]!, value?.toString() ?? '');
    }
  }

  void _setCountryComponentValue(SDUIField componentField, dynamic value) {
    final key = componentField.key;
    if (value == null || value.toString().trim().isEmpty) {
      _selectedCountries.remove(key);
      _syncController(_controllers[key]!, '');
      return;
    }

    if (value is CountryForm) {
      _selectedCountries[key] = value;
      _syncController(_controllers[key]!, value.countryName);
      return;
    }

    final raw = value.toString().trim();
    final country = _findCountry(raw);
    final resolved = country != null
        ? CountryForm(
            countryCode: country.countryCode,
            countryName: country.name,
          )
        : CountryForm(countryCode: raw, countryName: raw);

    _selectedCountries[key] = resolved;
    _syncController(_controllers[key]!, resolved.countryName);
  }

  void _commitAddressValue(Map<String, String> value) {
    final compactValue = compactAddressValue(widget.field, value);
    widget.onChanged?.call(widget.field.key, compactValue);
    validateField(compactValue);
  }

  String? _validateAddress([Map<String, String>? value]) {
    return validateField(
      value ?? compactAddressValue(widget.field, _currentAddressValue()),
    );
  }

  Map<String, String> _currentAddressValue() {
    final value = <String, String>{};

    for (final componentField in _componentFields) {
      value[componentField.key] = _currentComponentValue(componentField);
    }

    return value;
  }

  String _currentComponentValue(SDUIField componentField) {
    final key = componentField.key;
    if (componentField.type.trim().toLowerCase() == 'country') {
      final selected = _selectedCountries[key];
      if (selected != null && selected.countryCode.trim().isNotEmpty) {
        return selected.countryCode.trim();
      }
      return _controllers[key]!.text.trim();
    }

    final text = _controllers[key]!.text.trim();
    final mask = componentField.ui?.mask?.trim();
    if (mask == null || mask.isEmpty) return text;
    final formatter = SDUIMaskTextInputFormatter(mask: mask);
    return formatter.unmask(text).trim();
  }

  void _syncStateFromValue(Object? value) {
    final normalized = normalizeAddressValue(
      widget.field,
      value,
      includeDefaults: true,
    );

    for (final componentField in _componentFields) {
      final resolved = normalized[componentField.key] ?? '';
      if (componentField.type.trim().toLowerCase() == 'country') {
        _syncCountryValue(componentField.key, resolved);
      } else {
        _syncController(_controllers[componentField.key]!, resolved);
      }
    }
  }

  void _syncCountryValue(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _selectedCountries.remove(key);
      _syncController(_controllers[key]!, '');
      return;
    }

    final country = _findCountry(trimmed);
    final resolved = country != null
        ? CountryForm(
            countryCode: country.countryCode,
            countryName: country.name,
          )
        : CountryForm(countryCode: trimmed, countryName: trimmed);

    _selectedCountries[key] = resolved;
    _syncController(_controllers[key]!, resolved.countryName);
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  Country? _findCountry(String rawValue) {
    final normalized = rawValue.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    for (final country in _countries) {
      if (country.countryCode.toLowerCase() == normalized ||
          country.name.toLowerCase() == normalized) {
        return country;
      }
    }

    return null;
  }

  SDUIField? _componentField(String key) {
    for (final componentField in _componentFields) {
      if (componentField.key == key) return componentField;
    }
    return null;
  }

  Object? _effectiveFieldValue() {
    return widget.formManager.getFieldValue(widget.field.key) ??
        resolveAddressDefaultValue(widget.field, widget.field.defaultValue);
  }

  @override
  String? validateField(dynamic value) {
    widget.formManager.clearError(widget.field.key);
    final normalized = normalizeAddressValue(widget.field, value);
    final requiredKeys = requiredAddressComponentFields(
      widget.field,
    ).map((componentField) => componentField.key).toSet();

    for (final componentField in _componentFields) {
      final componentValue = (normalized[componentField.key] ?? '').trim();

      if (requiredKeys.contains(componentField.key) && componentValue.isEmpty) {
        final error = _componentRequiredMessage(componentField);
        widget.formManager.addError(widget.field.key, error);
        return error;
      }

      final validatorValue = componentValue.isEmpty ? null : componentValue;
      final error = FieldValidator.instance.validateField(
        field: componentField,
        formManager: widget.formManager,
        value: validatorValue,
        selectedCountryCode:
            componentField.type.trim().toLowerCase() == 'country'
            ? componentValue
            : null,
      );

      if (error != null) {
        widget.formManager.addError(widget.field.key, error);
        return error;
      }
    }

    final flattened = flattenAddressValue(widget.field, normalized);
    final topLevelValue = flattened.trim().isEmpty ? null : flattened;
    final topLevelError = FieldValidator.instance.validateField(
      field: widget.field,
      formManager: widget.formManager,
      value: topLevelValue,
    );

    if (topLevelError != null) {
      widget.formManager.addError(widget.field.key, topLevelError);
      return topLevelError;
    }

    return null;
  }

  String _componentRequiredMessage(SDUIField componentField) {
    final message = componentField.validations
        ?.firstWhere(
          (validation) => validation.rule.toLowerCase() == 'required',
          orElse: () => SDUIValidation(rule: '', params: const []),
        )
        .message;

    if (message != null && message.trim().isNotEmpty) return message;
    return '${componentField.label} is required';
  }
}
